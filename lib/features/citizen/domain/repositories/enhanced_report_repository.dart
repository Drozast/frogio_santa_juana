// lib/features/citizen/domain/repositories/enhanced_report_repository.dart
import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/enhanced_report_entity.dart';

abstract class ReportRepository {
  // CRUD básico
  Future<Either<Failure, List<ReportEntity>>> getReportsByUser(String userId);
  Future<Either<Failure, ReportEntity>> getReportById(String reportId);
  Future<Either<Failure, String>> createReport(CreateReportParams params);
  Future<Either<Failure, void>> updateReport(String reportId, UpdateReportParams params);
  Future<Either<Failure, void>> deleteReport(String reportId);
  
  // Gestión de estado
  Future<Either<Failure, void>> updateReportStatus({
    required String reportId,
    required ReportStatus status,
    String? comment,
    required String userId,
  });
  
  // Respuestas
  Future<Either<Failure, void>> addResponse({
    required String reportId,
    required String responderId,
    required String responderName,
    required String message,
    List<File>? attachments,
    bool isPublic = true,
  });
  
  // Media
  Future<Either<Failure, List<MediaAttachment>>> uploadMedia({
    required String reportId,
    required List<File> files,
    required MediaType type,
  });
  
  // Consultas para inspectores/administradores
  Future<Either<Failure, List<ReportEntity>>> getReportsByStatus(
    ReportStatus status, {
    String? muniId,
    String? assignedTo,
  });
  
  Future<Either<Failure, List<ReportEntity>>> getReportsByCategory(
    String category, {
    String? muniId,
  });
  
  Future<Either<Failure, List<ReportEntity>>> getReportsByLocation({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? muniId,
  });
  
  // Asignación
  Future<Either<Failure, void>> assignReport({
    required String reportId,
    required String assignedToId,
    required String assignedById,
  });
  
  // Estadísticas
  Future<Either<Failure, Map<String, int>>> getReportStatistics(String muniId);
  
  // Stream para tiempo real
  Stream<List<ReportEntity>> watchReportsByUser(String userId);
  Stream<List<ReportEntity>> watchReportsByStatus(ReportStatus status, String muniId);
}

class CreateReportParams {
  final String title;
  final String description;
  final String category;
  final String? references;
  final LocationData location;
  final String userId;
  final Priority priority;
  final List<File> attachments;

  CreateReportParams({
    required this.title,
    required this.description,
    required this.category,
    this.references,
    required this.location,
    required this.userId,
    this.priority = Priority.medium,
    this.attachments = const [],
  });
}

class UpdateReportParams {
  final String? title;
  final String? description;
  final String? category;
  final String? references;
  final LocationData? location;
  final Priority? priority;

  UpdateReportParams({
    this.title,
    this.description,
    this.category,
    this.references,
    this.location,
    this.priority,
  });
}