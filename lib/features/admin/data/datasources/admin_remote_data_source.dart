// lib/features/admin/data/datasources/admin_remote_data_source.dart
import '../models/municipal_statistics_model.dart';
import '../models/query_model.dart';
import '../models/user_model.dart';

abstract class AdminRemoteDataSource {
  // Gestión de consultas
  Future<List<QueryModel>> getAllPendingQueries(String muniId);
  Future<void> answerQuery({
    required String queryId,
    required String adminId,
    required String response,
    List<String>? attachments,
  });
  Future<List<QueryModel>> getQueriesByStatus({
    required String muniId,
    required String status,
  });
  
  // Gestión de usuarios
  Future<List<UserModel>> getAllUsers(String muniId);
  Future<List<UserModel>> getUsersByRole({
    required String muniId,
    required String role,
  });
  Future<void> updateUserRole({
    required String userId,
    required String newRole,
    required String adminId,
  });
  Future<void> activateUser(String userId);
  Future<void> deactivateUser(String userId);
  
  // Estadísticas municipales
  Future<MunicipalStatisticsModel> getMunicipalStatistics(String muniId);
  Future<Map<String, dynamic>> getReportsStatistics({
    required String muniId,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Map<String, dynamic>> getInfractionsStatistics({
    required String muniId,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  // Gestión de reportes
  Future<void> assignReportToInspector({
    required String reportId,
    required String inspectorId,
    required String adminId,
  });
  Future<void> updateReportPriority({
    required String reportId,
    required String priority,
    required String adminId,
  });
  
  // Gestión de configuraciones
  Future<void> updateMunicipalSettings({
    required String muniId,
    required Map<String, dynamic> settings,
  });
  Future<Map<String, dynamic>> getMunicipalSettings(String muniId);
  
  // Exportación de datos
  Future<String> exportReportsToCSV({
    required String muniId,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<String> exportInfractionsToCSV({
    required String muniId,
    DateTime? startDate,
    DateTime? endDate,
  });
}