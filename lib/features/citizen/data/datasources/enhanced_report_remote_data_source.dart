// lib/features/citizen/data/datasources/enhanced_report_remote_data_source.dart
import 'dart:io';

import '../../domain/entities/enhanced_report_entity.dart';
import '../../domain/repositories/enhanced_report_repository.dart';
import '../models/enhanced_report_model.dart';

abstract class ReportRemoteDataSource {
  Future<List<ReportModel>> getReportsByUser(String userId);
  Future<ReportModel> getReportById(String reportId);
  Future<String> createReport(CreateReportParams params);
  Future<void> updateReport(String reportId, UpdateReportParams params);
  Future<void> deleteReport(String reportId);
  
  Future<void> updateReportStatus({
    required String reportId,
    required ReportStatus status,
    String? comment,
    required String userId,
  });
  
  Future<void> addResponse({
    required String reportId,
    required String responderId,
    required String responderName,
    required String message,
    List<File>? attachments,
    bool isPublic = true,
  });
  
  Future<List<MediaAttachment>> uploadMedia({
    required String reportId,
    required List<File> files,
    required MediaType type,
  });
  
  Future<List<ReportModel>> getReportsByStatus(
    ReportStatus status, {
    String? muniId,
    String? assignedTo,
  });
  
  Future<List<ReportModel>> getReportsByCategory(
    String category, {
    String? muniId,
  });
  
  Future<List<ReportModel>> getReportsByLocation({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? muniId,
  });
  
  Future<void> assignReport({
    required String reportId,
    required String assignedToId,
    required String assignedById,
  });
  
  Future<Map<String, int>> getReportStatistics(String muniId);
  
  Stream<List<ReportModel>> watchReportsByUser(String userId);
  Stream<List<ReportModel>> watchReportsByStatus(ReportStatus status, String muniId);
}