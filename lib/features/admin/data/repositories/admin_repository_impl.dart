// lib/features/admin/data/repositories/admin_repository_impl.dart
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/municipal_statistics_entity.dart';
import '../../domain/entities/query_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<QueryEntity>>> getAllPendingQueries(String muniId) async {
    try {
      final queries = await remoteDataSource.getAllPendingQueries(muniId);
      return Right(queries);
    } catch (e) {
      return Left(ServerFailure('Error al obtener consultas pendientes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> answerQuery({
    required String queryId,
    required String adminId,
    required String response,
    List<String>? attachments,
  }) async {
    try {
      await remoteDataSource.answerQuery(
        queryId: queryId,
        adminId: adminId,
        response: response,
        attachments: attachments,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al responder consulta: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<QueryEntity>>> getQueriesByStatus({
    required String muniId,
    required String status,
  }) async {
    try {
      final queries = await remoteDataSource.getQueriesByStatus(
        muniId: muniId,
        status: status,
      );
      return Right(queries);
    } catch (e) {
      return Left(ServerFailure('Error al obtener consultas por estado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getAllUsers(String muniId) async {
    try {
      final users = await remoteDataSource.getAllUsers(muniId);
      return Right(users);
    } catch (e) {
      return Left(ServerFailure('Error al obtener usuarios: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getUsersByRole({
    required String muniId,
    required String role,
  }) async {
    try {
      final users = await remoteDataSource.getUsersByRole(
        muniId: muniId,
        role: role,
      );
      return Right(users);
    } catch (e) {
      return Left(ServerFailure('Error al obtener usuarios por rol: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserRole({
    required String userId,
    required String newRole,
    required String adminId,
  }) async {
    try {
      await remoteDataSource.updateUserRole(
        userId: userId,
        newRole: newRole,
        adminId: adminId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al actualizar rol de usuario: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> activateUser(String userId) async {
    try {
      await remoteDataSource.activateUser(userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al activar usuario: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deactivateUser(String userId) async {
    try {
      await remoteDataSource.deactivateUser(userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al desactivar usuario: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, MunicipalStatisticsEntity>> getMunicipalStatistics(String muniId) async {
    try {
      final statistics = await remoteDataSource.getMunicipalStatistics(muniId);
      return Right(statistics);
    } catch (e) {
      return Left(ServerFailure('Error al obtener estadísticas municipales: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getReportsStatistics({
    required String muniId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final statistics = await remoteDataSource.getReportsStatistics(
        muniId: muniId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(statistics);
    } catch (e) {
      return Left(ServerFailure('Error al obtener estadísticas de reportes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getInfractionsStatistics({
    required String muniId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final statistics = await remoteDataSource.getInfractionsStatistics(
        muniId: muniId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(statistics);
    } catch (e) {
      return Left(ServerFailure('Error al obtener estadísticas de infracciones: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> assignReportToInspector({
    required String reportId,
    required String inspectorId,
    required String adminId,
  }) async {
    try {
      await remoteDataSource.assignReportToInspector(
        reportId: reportId,
        inspectorId: inspectorId,
        adminId: adminId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al asignar reporte: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateReportPriority({
    required String reportId,
    required String priority,
    required String adminId,
  }) async {
    try {
      await remoteDataSource.updateReportPriority(
        reportId: reportId,
        priority: priority,
        adminId: adminId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al actualizar prioridad del reporte: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateMunicipalSettings({
    required String muniId,
    required Map<String, dynamic> settings,
  }) async {
    try {
      await remoteDataSource.updateMunicipalSettings(
        muniId: muniId,
        settings: settings,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al actualizar configuración municipal: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMunicipalSettings(String muniId) async {
    try {
      final settings = await remoteDataSource.getMunicipalSettings(muniId);
      return Right(settings);
    } catch (e) {
      return Left(ServerFailure('Error al obtener configuración municipal: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> exportReportsToCSV({
    required String muniId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final csvData = await remoteDataSource.exportReportsToCSV(
        muniId: muniId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(csvData);
    } catch (e) {
      return Left(ServerFailure('Error al exportar reportes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> exportInfractionsToCSV({
    required String muniId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final csvData = await remoteDataSource.exportInfractionsToCSV(
        muniId: muniId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(csvData);
    } catch (e) {
      return Left(ServerFailure('Error al exportar infracciones: ${e.toString()}'));
    }
  }
}