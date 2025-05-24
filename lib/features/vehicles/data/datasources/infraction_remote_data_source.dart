// lib/features/inspector/data/datasources/infraction_remote_data_source.dart
import 'dart:io';

import '../models/infraction_model.dart';

abstract class InfractionRemoteDataSource {
  Future<List<InfractionModel>> getInfractionsByInspector(String inspectorId);
  Future<InfractionModel> getInfractionById(String infractionId);
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
  });
  Future<void> updateInfractionStatus(String infractionId, String status, String? comment);
  Future<void> deleteInfraction(String infractionId);
  Future<List<String>> uploadInfractionImages(List<File> images, String infractionId);
  Future<void> addSignature(String infractionId, String signatureUrl);
  Future<List<InfractionModel>> getInfractionsByStatus(String status, {String? muniId});
  Future<List<InfractionModel>> getInfractionsByLocation({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? muniId,
  });
  Future<Map<String, int>> getInfractionStatistics(String muniId);
  Stream<List<InfractionModel>> watchInfractionsByInspector(String inspectorId);
}