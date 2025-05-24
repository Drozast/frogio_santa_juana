// lib/features/citizen/data/datasources/enhanced_report_remote_data_source_impl.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/enhanced_report_entity.dart';
import '../../domain/repositories/enhanced_report_repository.dart';
import '../models/enhanced_report_model.dart';
import 'enhanced_report_remote_data_source.dart';

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final Uuid uuid;

  ReportRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
    required this.uuid,
  });

  @override
  Future<List<ReportModel>> getReportsByUser(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('reports')
          .where('citizenId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerFailure('Error al cargar reportes: ${e.toString()}');
    }
  }

  @override
  Future<ReportModel> getReportById(String reportId) async {
    try {
      final docSnapshot = await firestore.collection('reports').doc(reportId).get();

      if (!docSnapshot.exists) {
        throw const ServerFailure('Reporte no encontrado');
      }

      return ReportModel.fromFirestore(docSnapshot);
    } catch (e) {
      throw ServerFailure('Error al cargar reporte: ${e.toString()}');
    }
  }

  @override
  Future<String> createReport(CreateReportParams params) async {
    try {
      // Crear ID único para el reporte
      final reportId = uuid.v4();
      
      // Obtener datos del usuario
      final userDoc = await firestore.collection('users').doc(params.userId).get();
      final userData = userDoc.data();
      final muniId = userData?['muniId'] ?? 'default_muni';

      // Subir archivos multimedia primero
      List<MediaAttachment> attachments = [];
      if (params.attachments.isNotEmpty) {
        attachments = await uploadMedia(
          reportId: reportId,
          files: params.attachments,
          type: MediaType.image, // Por simplicidad, asumimos que son imágenes
        );
      }

      // Crear historial inicial
      final initialHistory = StatusHistoryItemModel(
        timestamp: DateTime.now(),
        status: ReportStatus.submitted,
        comment: 'Denuncia creada',
        userId: params.userId,
        userName: userData?['displayName'] ?? 'Usuario',
      );

      // Crear el reporte
      final reportData = ReportModel(
        id: reportId,
        title: params.title,
        description: params.description,
        category: params.category,
        references: params.references,
        location: params.location,
        citizenId: params.userId,
        muniId: muniId,
        status: ReportStatus.submitted,
        priority: params.priority,
        attachments: attachments,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        statusHistory: [initialHistory],
        responses: const [],
      );

      // Guardar en Firestore
      await firestore.collection('reports').doc(reportId).set(reportData.toFirestore());

      return reportId;
    } catch (e) {
      throw ServerFailure('Error al crear reporte: ${e.toString()}');
    }
  }

  @override
  Future<void> updateReport(String reportId, UpdateReportParams params) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (params.title != null) updateData['title'] = params.title;
      if (params.description != null) updateData['description'] = params.description;
      if (params.category != null) updateData['category'] = params.category;
      if (params.references != null) updateData['references'] = params.references;
      if (params.location != null) {
        updateData['location'] = LocationDataModel.fromEntity(params.location!).toMap();
      }
      if (params.priority != null) updateData['priority'] = params.priority!.name;
      
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await firestore.collection('reports').doc(reportId).update(updateData);
    } catch (e) {
      throw ServerFailure('Error al actualizar reporte: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteReport(String reportId) async {
    try {
      // Eliminar archivos de storage
      try {
        final storageRef = storage.ref().child('reports/$reportId');
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
      await firestore.collection('reports').doc(reportId).delete();
    } catch (e) {
      throw ServerFailure('Error al eliminar reporte: ${e.toString()}');
    }
  }

  @override
  Future<void> updateReportStatus({
    required String reportId,
    required ReportStatus status,
    String? comment,
    required String userId,
  }) async {
    try {
      // Obtener datos del usuario
      final userDoc = await firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();

      // Crear nuevo item de historial
      final historyItem = StatusHistoryItemModel(
        timestamp: DateTime.now(),
        status: status,
        comment: comment,
        userId: userId,
        userName: userData?['displayName'] ?? 'Usuario',
      );

      // Actualizar reporte
      await firestore.collection('reports').doc(reportId).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
        'statusHistory': FieldValue.arrayUnion([historyItem.toMap()]),
      });
    } catch (e) {
      throw ServerFailure('Error al actualizar estado: ${e.toString()}');
    }
  }

  @override
  Future<void> addResponse({
    required String reportId,
    required String responderId,
    required String responderName,
    required String message,
    List<File>? attachments,
    bool isPublic = true,
  }) async {
    try {
      final responseId = uuid.v4();
      
      // Subir archivos si los hay
      List<MediaAttachment> responseAttachments = [];
      if (attachments != null && attachments.isNotEmpty) {
        responseAttachments = await uploadMedia(
          reportId: '$reportId/responses/$responseId',
          files: attachments,
          type: MediaType.image,
        );
      }

      // Crear respuesta
      final response = ReportResponseModel(
        id: responseId,
        responderId: responderId,
        responderName: responderName,
        message: message,
        attachments: responseAttachments,
        isPublic: isPublic,
        createdAt: DateTime.now(),
      );

      // Añadir a Firestore
      await firestore.collection('reports').doc(reportId).update({
        'responses': FieldValue.arrayUnion([response.toMap()]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerFailure('Error al agregar respuesta: ${e.toString()}');
    }
  }

  @override
  Future<List<MediaAttachment>> uploadMedia({
    required String reportId,
    required List<File> files,
    required MediaType type,
  }) async {
    try {
      final attachments = <MediaAttachment>[];
      
      for (var i = 0; i < files.length; i++) {
        final file = files[i];
        final fileName = path.basename(file.path);
        final fileId = uuid.v4();
        final storagePath = 'reports/$reportId/$fileId-$fileName';
        
        // Comprimir imagen si es necesario
        File fileToUpload = file;
        if (type == MediaType.image) {
          fileToUpload = await _compressImage(file);
        }
        
        // Subir archivo
        final storageRef = storage.ref().child(storagePath);
        final uploadTask = await storageRef.putFile(fileToUpload);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        
        // Obtener tamaño del archivo
        final fileSize = await fileToUpload.length();
        
        // Crear attachment
        final attachment = MediaAttachmentModel(
          id: fileId,
          url: downloadUrl,
          fileName: fileName,
          type: type,
          fileSize: fileSize,
          uploadedAt: DateTime.now(),
        );
        
        attachments.add(attachment);
      }
      
      return attachments;
    } catch (e) {
      throw ServerFailure('Error al subir archivos: ${e.toString()}');
    }
  }

  @override
  Future<List<ReportModel>> getReportsByStatus(
    ReportStatus status, {
    String? muniId,
    String? assignedTo,
  }) async {
    try {
      Query query = firestore.collection('reports').where('status', isEqualTo: status.name);
      
      if (muniId != null) {
        query = query.where('muniId', isEqualTo: muniId);
      }
      
      if (assignedTo != null) {
        query = query.where('assignedToId', isEqualTo: assignedTo);
      }
      
      final querySnapshot = await query.orderBy('updatedAt', descending: true).get();
      
      return querySnapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerFailure('Error al cargar reportes por estado: ${e.toString()}');
    }
  }

  @override
  Future<List<ReportModel>> getReportsByCategory(
    String category, {
    String? muniId,
  }) async {
    try {
      Query query = firestore.collection('reports').where('category', isEqualTo: category);
      
      if (muniId != null) {
        query = query.where('muniId', isEqualTo: muniId);
      }
      
      final querySnapshot = await query.orderBy('updatedAt', descending: true).get();
      
      return querySnapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerFailure('Error al cargar reportes por categoría: ${e.toString()}');
    }
  }

  @override
  Future<List<ReportModel>> getReportsByLocation({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? muniId,
  }) async {
    try {
      // Firebase no soporta consultas geoespaciales complejas directamente
      // Por simplicidad, obtenemos todos los reportes y filtramos en cliente
      Query query = firestore.collection('reports');
      
      if (muniId != null) {
        query = query.where('muniId', isEqualTo: muniId);
      }
      
      final querySnapshot = await query.get();
      final reports = querySnapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
      
      // Filtrar por distancia
      return reports.where((report) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          report.location.latitude,
          report.location.longitude,
        );
        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      throw ServerFailure('Error al cargar reportes por ubicación: ${e.toString()}');
    }
  }

  @override
  Future<void> assignReport({
    required String reportId,
    required String assignedToId,
    required String assignedById,
  }) async {
    try {
      // Obtener datos del usuario asignado
      final assignedUserDoc = await firestore.collection('users').doc(assignedToId).get();
      final assignedUserData = assignedUserDoc.data();
      
      await firestore.collection('reports').doc(reportId).update({
        'assignedToId': assignedToId,
        'assignedToName': assignedUserData?['displayName'] ?? 'Usuario',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerFailure('Error al asignar reporte: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, int>> getReportStatistics(String muniId) async {
    try {
      final querySnapshot = await firestore
          .collection('reports')
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
  Stream<List<ReportModel>> watchReportsByUser(String userId) {
    return firestore
        .collection('reports')
        .where('citizenId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReportModel.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<ReportModel>> watchReportsByStatus(ReportStatus status, String muniId) {
    return firestore
        .collection('reports')
        .where('status', isEqualTo: status.name)
        .where('muniId', isEqualTo: muniId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReportModel.fromFirestore(doc))
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
    
    final double a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_degreesToRadians(lat1)) * _cos(_degreesToRadians(lat2)) *
        _sin(dLng / 2) * _sin(dLng / 2);
    
    final double c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.141592653589793 / 180);
  }

  double _sin(double radians) {
    return _sin(radians);
  }

  double _cos(double radians) {
    return _cos(radians);
  }

  double _sqrt(double value) {
    return _sqrt(value);
  }

  double _atan2(double y, double x) {
    return _atan2(y, x);
  }
}