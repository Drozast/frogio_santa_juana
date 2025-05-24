// lib/features/inspector/data/datasources/infraction_remote_data_source_impl.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/infraction_entity.dart';
import '../models/infraction_model.dart';
import 'infraction_remote_data_source.dart';

class InfractionRemoteDataSourceImpl implements InfractionRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final Uuid uuid;

  InfractionRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
    required this.uuid,
  });

  @override
  Future<List<InfractionModel>> getInfractionsByInspector(String inspectorId) async {
    try {
      final querySnapshot = await firestore
          .collection('infractions')
          .where('inspectorId', isEqualTo: inspectorId)
          .orderBy('updatedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => InfractionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerFailure('Error al cargar infracciones: ${e.toString()}');
    }
  }

  @override
  Future<InfractionModel> getInfractionById(String infractionId) async {
    try {
      final docSnapshot = await firestore.collection('infractions').doc(infractionId).get();

      if (!docSnapshot.exists) {
        throw const ServerFailure('Infracción no encontrada');
      }

      return InfractionModel.fromFirestore(docSnapshot);
    } catch (e) {
      throw ServerFailure('Error al cargar infracción: ${e.toString()}');
    }
  }

  @override
  Future<String> createInfraction({
    required String title,
    required String description,
    required String ordinanceRef,
    required LocationDataModel location,
    required String offenderId,
    required String offenderName,
    required String offenderDocument,
    required String inspectorId,
    required List<File> evidence,
  }) async {
    try {
      // Crear ID único para la infracción
      final infractionId = uuid.v4();
      
      // Obtener datos del inspector
      final inspectorDoc = await firestore.collection('users').doc(inspectorId).get();
      final inspectorData = inspectorDoc.data();
      final muniId = inspectorData?['muniId'] ?? 'default_muni';

      // Subir evidencia primero
      List<String> evidenceUrls = [];
      if (evidence.isNotEmpty) {
        evidenceUrls = await uploadInfractionImages(evidence, infractionId);
      }

      // Crear historial inicial
      final initialHistory = InfractionHistoryItemModel(
        timestamp: DateTime.now(),
        status: InfractionStatus.created,
        comment: 'Infracción creada',
        userId: inspectorId,
        userName: inspectorData?['displayName'] ?? 'Inspector',
      );

      // Crear la infracción
      final infractionData = InfractionModel(
        id: infractionId,
        title: title,
        description: description,
        ordinanceRef: ordinanceRef,
        location: location,
        offenderId: offenderId,
        offenderName: offenderName,
        offenderDocument: offenderDocument,
        inspectorId: inspectorId,
        muniId: muniId,
        evidence: evidenceUrls,
        signatures: const [],
        status: InfractionStatus.created,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        historyLog: [initialHistory],
      );

      // Guardar en Firestore
      await firestore.collection('infractions').doc(infractionId).set(infractionData.toFirestore());

      return infractionId;
    } catch (e) {
      throw ServerFailure('Error al crear infracción: ${e.toString()}');
    }
  }

  @override
  Future<void> updateInfractionStatus(String infractionId, String status, String? comment) async {
    try {
      // Obtener infracción actual para el historial
      final infractionDoc = await firestore.collection('infractions').doc(infractionId).get();
      final infractionData = infractionDoc.data();
      
      if (infractionData == null) {
        throw const ServerFailure('Infracción no encontrada');
      }

      // Crear nuevo item de historial
      final historyItem = InfractionHistoryItemModel(
        timestamp: DateTime.now(),
        status: InfractionStatus.values.firstWhere(
          (s) => s.name == status,
          orElse: () => InfractionStatus.created,
        ),
        comment: comment,
        userId: infractionData['inspectorId'],
        userName: 'Inspector',
      );

      // Actualizar infracción
      await firestore.collection('infractions').doc(infractionId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        'historyLog': FieldValue.arrayUnion([historyItem.toMap()]),
      });
    } catch (e) {
      throw ServerFailure('Error al actualizar estado: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteInfraction(String infractionId) async {
    try {
      // Eliminar archivos de storage
      try {
        final storageRef = storage.ref().child('infractions/$infractionId');
        final listResult = await storageRef.listAll();
        
        for (var item in listResult.items) {
          await item.delete();
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error al eliminar archivos: ${e.toString()}');
        }
      }

      // Eliminar documento
      await firestore.collection('infractions').doc(infractionId).delete();
    } catch (e) {
      throw ServerFailure('Error al eliminar infracción: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> uploadInfractionImages(List<File> images, String infractionId) async {
    try {
      final uploadedUrls = <String>[];
      
      for (var i = 0; i < images.length; i++) {
        final image = images[i];
        final fileName = path.basename(image.path);
        final fileId = uuid.v4();
        final storagePath = 'infractions/$infractionId/$fileId-$fileName';
        
        // Comprimir imagen
        File imageToUpload = image;
        try {
          imageToUpload = await _compressImage(image);
        } catch (e) {
          // Si falla la compresión, usar la original
          imageToUpload = image;
        }
        
        // Subir archivo
        final storageRef = storage.ref().child(storagePath);
        final uploadTask = await storageRef.putFile(imageToUpload);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        
        uploadedUrls.add(downloadUrl);
      }
      
      return uploadedUrls;
    } catch (e) {
      throw ServerFailure('Error al subir imágenes: ${e.toString()}');
    }
  }

  @override
  Future<void> addSignature(String infractionId, String signatureUrl) async {
    try {
      await firestore.collection('infractions').doc(infractionId).update({
        'signatures': FieldValue.arrayUnion([signatureUrl]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerFailure('Error al agregar firma: ${e.toString()}');
    }
  }

  @override
  Future<List<InfractionModel>> getInfractionsByStatus(String status, {String? muniId}) async {
    try {
      Query query = firestore.collection('infractions').where('status', isEqualTo: status);
      
      if (muniId != null) {
        query = query.where('muniId', isEqualTo: muniId);
      }
      
      final querySnapshot = await query.orderBy('updatedAt', descending: true).get();
      
      return querySnapshot.docs
          .map((doc) => InfractionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerFailure('Error al cargar infracciones por estado: ${e.toString()}');
    }
  }

  @override
  Future<List<InfractionModel>> getInfractionsByLocation({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? muniId,
  }) async {
    try {
      // Firebase no soporta consultas geoespaciales complejas directamente
      Query query = firestore.collection('infractions');
      
      if (muniId != null) {
        query = query.where('muniId', isEqualTo: muniId);
      }
      
      final querySnapshot = await query.get();
      final infractions = querySnapshot.docs
          .map((doc) => InfractionModel.fromFirestore(doc))
          .toList();
      
      // Filtrar por distancia
      return infractions.where((infraction) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          infraction.location.latitude,
          infraction.location.longitude,
        );
        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      throw ServerFailure('Error al cargar infracciones por ubicación: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, int>> getInfractionStatistics(String muniId) async {
    try {
      final querySnapshot = await firestore
          .collection('infractions')
          .where('muniId', isEqualTo: muniId)
          .get();

      final stats = <String, int>{};
      
      for (final doc in querySnapshot.docs) {
        final status = doc.data()['status'] as String;
        stats[status] = (stats[status] ?? 0) + 1;
      }
      
      return stats;
    } catch (e) {
      throw ServerFailure('Error al obtener estadísticas: ${e.toString()}');
    }
  }

  @override
  Stream<List<InfractionModel>> watchInfractionsByInspector(String inspectorId) {
    return firestore
        .collection('infractions')
        .where('inspectorId', isEqualTo: inspectorId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InfractionModel.fromFirestore(doc))
            .toList());
  }

  // Métodos auxiliares

  Future<File> _compressImage(File file) async {
    try {
      final dir = path.dirname(file.path);
      final ext = path.extension(file.path);
      final fileName = path.basenameWithoutExtension(file.path);
      final targetPath = path.join(dir, '${fileName}_compressed$ext');

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70,
        minWidth: 1024,
        minHeight: 1024,
      );

      return result != null ? File(result.path) : file;
    } catch (e) {
      return file; // Return original if compression fails
    }
  }

  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    // Fórmula de Haversine simplificada
    const double earthRadius = 6371; // Radio de la Tierra en km
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLng = _degreesToRadians(lng2 - lng1);
    
    final double a = (dLat / 2).sin() * (dLat / 2).sin() +
        _degreesToRadians(lat1).cos() * _degreesToRadians(lat2).cos() *
        (dLng / 2).sin() * (dLng / 2).sin();
    
    final double c = 2 * a.sqrt().asin();
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.141592653589793 / 180);
  }
}