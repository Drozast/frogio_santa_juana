// lib/features/citizen/data/repositories/enhanced_report_repository_impl.dart
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:frogio_santa_juana/features/citizen/data/datasources/enhanced_report_remote_data_source.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/enhanced_report_entity.dart';
import '../../domain/repositories/enhanced_report_repository.dart';
import '../datasources/enhanced_report_remote_data_source.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;

  ReportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ReportEntity>>> getReportsByUser(String userId) async {
    try {
      final reports = await remoteDataSource.getReportsByUser(userId);
      return Right(reports);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReportEntity>> getReportById(String reportId) async {
    try {
      final report = await remoteDataSource.getReportById(reportId);
      return Right(report);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createReport(CreateReportParams params) async {
    try {
      final reportId = await remoteDataSource.createReport(params);
      return Right(reportId);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateReport(String reportId, UpdateReportParams params) async {
    try {
      await remoteDataSource.updateReport(reportId, params);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReport(String reportId) async {
    try {
      await remoteDataSource.deleteReport(reportId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateReportStatus({
    required String reportId,
    required ReportStatus status,
    String? comment,
    required String userId,
  }) async {
    try {
      await remoteDataSource.updateReportStatus(
        reportId: reportId,
        status: status,
        comment: comment,
        userId: userId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addResponse({
    required String reportId,
    required String responderId,
    required String responderName,
    required String message,
    List<File>? attachments,
    bool isPublic = true,
  }) async {
    try {
      await remoteDataSource.addResponse(
        reportId: reportId,
        responderId: responderId,
        responderName: responderName,
        message: message,
        attachments: attachments,
        isPublic: isPublic,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MediaAttachment>>> uploadMedia({
    required String reportId,
    required List<File> files,
    required MediaType type,
  }) async {
    try {
      final attachments = await remoteDataSource.uploadMedia(
        reportId: reportId,
        files: files,
        type: type,
      );
      return Right(attachments);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReportEntity>>> getReportsByStatus(
    ReportStatus status, {
    String? muniId,
    String? assignedTo,
  }) async {
    try {
      final reports = await remoteDataSource.getReportsByStatus(
        status,
        muniId: muniId,
        assignedTo: assignedTo,
      );
      return Right(reports);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReportEntity>>> getReportsByCategory(
    String category, {
    String? muniId,
  }) async {
    try {
      final reports = await remoteDataSource.getReportsByCategory(
        category,
        muniId: muniId,
      );
      return Right(reports);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReportEntity>>> getReportsByLocation({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? muniId,
  }) async {
    try {
      final reports = await remoteDataSource.getReportsByLocation(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        muniId: muniId,
      );
      return Right(reports);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> assignReport({
    required String reportId,
    required String assignedToId,
    required String assignedById,
  }) async {
    try {
      await remoteDataSource.assignReport(
        reportId: reportId,
        assignedToId: assignedToId,
        assignedById: assignedById,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getReportStatistics(String muniId) async {
    try {
      final stats = await remoteDataSource.getReportStatistics(muniId);
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<ReportEntity>> watchReportsByUser(String userId) {
    return remoteDataSource.watchReportsByUser(userId);
  }

  @override
  Stream<List<ReportEntity>> watchReportsByStatus(ReportStatus status, String muniId) {
    return remoteDataSource.watchReportsByStatus(status, muniId);
  }
}