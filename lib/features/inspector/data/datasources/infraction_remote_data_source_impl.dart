import 'dart:io';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
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
          .map((doc) => InfractionModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
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

      return InfractionModel.fromJson({
        ...docSnapshot.data()!,
        'id': docSnapshot.id,
      });
    } catch (e) {
      throw ServerFailure('Error al cargar infracción: ${e.toString()}');
    }
  }

  @override
  Future<InfractionModel> createInfraction(InfractionModel infraction) async {
    try {
      final infractionId = uuid.v4();
      
      final infractionData = infraction.copyWith(
        id: infractionId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await firestore.collection('infractions').doc(infractionId).set(infractionData.toJson());

      return infractionData;
    } catch (e) {
      throw ServerFailure('Error al crear infracción: ${e.toString()}');
    }
  }

  @override
  Future<InfractionModel> updateInfraction(InfractionModel infraction) async {
    try {
      await firestore
          .collection('infractions')
          .doc(infraction.id)
          .update({
            ...infraction.toJson(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      return infraction;
    } catch (e) {
      throw ServerFailure('Error al actualizar infracción: ${e.toString()}');
    }
  }

  @override
  Future<void> updateInfractionStatus(String infractionId, String status) async {
    try {
      // Obtener infracción actual para el historial
      final infractionDoc = await firestore.collection('infractions').doc(infractionId).get();
      final infractionData = infractionDoc.data();
      
      if (infractionData == null) {
        throw const ServerFailure('Infracción no encontrada');
      }

      // Crear nuevo item de historial
      final historyItem = {
        'timestamp': DateTime.now(),
        'status': status,
        'comment': 'Estado actualizado',
        'userId': infractionData['inspectorId'],
        'userName': 'Inspector',
      };

      // Actualizar infracción
      await firestore.collection('infractions').doc(infractionId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        'historyLog': FieldValue.arrayUnion([historyItem]),
      });
    } catch (e) {
      throw ServerFailure('Error al actualizar estado: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadEvidenceImage(String infractionId, File image) async {
    try {
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
      
      return downloadUrl;
    } catch (e) {
      throw ServerFailure('Error al subir imagen: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadSignature(String infractionId, String signatureData) async {
    try {
      final fileName = 'signature_${DateTime.now().millisecondsSinceEpoch}.png';
      final ref = storage.ref().child('infractions/$infractionId/signatures/$fileName');
      
      // Convertir base64 a bytes y subir
      final bytes = Uri.parse(signatureData).data!.contentAsBytes();
      final uploadTask = await ref.putData(bytes);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw ServerFailure('Error al subir firma: ${e.toString()}');
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
    return degrees * (math.pi / 180);
  }
}

// Extension para operaciones matemáticas
extension DoubleExtensions on double {
  double sin() => math.sin(this);
  double cos() => math.cos(this);
  double sqrt() => math.sqrt(this);
  double asin() => math.asin(this);
}