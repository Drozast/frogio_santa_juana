// lib/features/admin/data/models/municipal_statistics_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/municipal_statistics_entity.dart';

class MunicipalStatisticsModel extends MunicipalStatisticsEntity {
  const MunicipalStatisticsModel({
    required super.muniId,
    required super.generatedAt,
    required super.reports,
    required super.infractions,
    required super.users,
    required super.vehicles,
    required super.performance,
  });

  factory MunicipalStatisticsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return MunicipalStatisticsModel(
      muniId: doc.id,
      generatedAt: (data['generatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reports: ReportsStatisticsModel.fromMap(data['reports'] ?? {}),
      infractions: InfractionsStatisticsModel.fromMap(data['infractions'] ?? {}),
      users: UsersStatisticsModel.fromMap(data['users'] ?? {}),
      vehicles: VehiclesStatisticsModel.fromMap(data['vehicles'] ?? {}),
      performance: PerformanceMetricsModel.fromMap(data['performance'] ?? {}),
    );
  }

  factory MunicipalStatisticsModel.fromMap(Map<String, dynamic> map) {
    return MunicipalStatisticsModel(
      muniId: map['muniId'] ?? '',
      generatedAt: map['generatedAt'] is Timestamp 
          ? (map['generatedAt'] as Timestamp).toDate()
          : DateTime.parse(map['generatedAt'] ?? DateTime.now().toIso8601String()),
      reports: ReportsStatisticsModel.fromMap(map['reports'] ?? {}),
      infractions: InfractionsStatisticsModel.fromMap(map['infractions'] ?? {}),
      users: UsersStatisticsModel.fromMap(map['users'] ?? {}),
      vehicles: VehiclesStatisticsModel.fromMap(map['vehicles'] ?? {}),
      performance: PerformanceMetricsModel.fromMap(map['performance'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'muniId': muniId,
      'generatedAt': generatedAt,
      'reports': (reports as ReportsStatisticsModel).toMap(),
      'infractions': (infractions as InfractionsStatisticsModel).toMap(),
      'users': (users as UsersStatisticsModel).toMap(),
      'vehicles': (vehicles as VehiclesStatisticsModel).toMap(),
      'performance': (performance as PerformanceMetricsModel).toMap(),
    };
  }
}

class ReportsStatisticsModel extends ReportsStatistics {
  const ReportsStatisticsModel({
    required super.totalReports,
    required super.pendingReports,
    required super.inProgressReports,
    required super.resolvedReports,
    required super.rejectedReports,
    required super.averageResolutionTimeHours,
    required super.reportsByCategory,
    required super.reportsByMonth,
    required super.citizenSatisfactionRate,
  });

  factory ReportsStatisticsModel.fromMap(Map<String, dynamic> map) {
    return ReportsStatisticsModel(
      totalReports: map['totalReports']?.toInt() ?? 0,
      pendingReports: map['pendingReports']?.toInt() ?? 0,
      inProgressReports: map['inProgressReports']?.toInt() ?? 0,
      resolvedReports: map['resolvedReports']?.toInt() ?? 0,
      rejectedReports: map['rejectedReports']?.toInt() ?? 0,
      averageResolutionTimeHours: map['averageResolutionTimeHours']?.toDouble() ?? 0.0,
      reportsByCategory: Map<String, int>.from(map['reportsByCategory'] ?? {}),
      reportsByMonth: Map<String, int>.from(map['reportsByMonth'] ?? {}),
      citizenSatisfactionRate: map['citizenSatisfactionRate']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalReports': totalReports,
      'pendingReports': pendingReports,
      'inProgressReports': inProgressReports,
      'resolvedReports': resolvedReports,
      'rejectedReports': rejectedReports,
      'averageResolutionTimeHours': averageResolutionTimeHours,
      'reportsByCategory': reportsByCategory,
      'reportsByMonth': reportsByMonth,
      'citizenSatisfactionRate': citizenSatisfactionRate,
    };
  }
}

class InfractionsStatisticsModel extends InfractionsStatistics {
  const InfractionsStatisticsModel({
    required super.totalInfractions,
    required super.confirmedInfractions,
    required super.appealedInfractions,
    required super.cancelledInfractions,
    required super.totalFinesAmount,
    required super.collectedAmount,
    required super.infractionsByType,
    required super.infractionsByInspector,
    required super.averageProcessingTimeHours,
  });

  factory InfractionsStatisticsModel.fromMap(Map<String, dynamic> map) {
    return InfractionsStatisticsModel(
      totalInfractions: map['totalInfractions']?.toInt() ?? 0,
      confirmedInfractions: map['confirmedInfractions']?.toInt() ?? 0,
      appealedInfractions: map['appealedInfractions']?.toInt() ?? 0,
      cancelledInfractions: map['cancelledInfractions']?.toInt() ?? 0,
      totalFinesAmount: map['totalFinesAmount']?.toDouble() ?? 0.0,
      collectedAmount: map['collectedAmount']?.toDouble() ?? 0.0,
      infractionsByType: Map<String, int>.from(map['infractionsByType'] ?? {}),
      infractionsByInspector: Map<String, int>.from(map['infractionsByInspector'] ?? {}),
      averageProcessingTimeHours: map['averageProcessingTimeHours']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalInfractions': totalInfractions,
      'confirmedInfractions': confirmedInfractions,
      'appealedInfractions': appealedInfractions,
      'cancelledInfractions': cancelledInfractions,
      'totalFinesAmount': totalFinesAmount,
      'collectedAmount': collectedAmount,
      'infractionsByType': infractionsByType,
      'infractionsByInspector': infractionsByInspector,
      'averageProcessingTimeHours': averageProcessingTimeHours,
    };
  }
}

class UsersStatisticsModel extends UsersStatistics {
  const UsersStatisticsModel({
    required super.totalUsers,
    required super.citizenUsers,
    required super.inspectorUsers,
    required super.adminUsers,
    required super.activeUsers,
    required super.inactiveUsers,
    required super.userRegistrationsByMonth,
    required super.averageUserEngagement,
  });

  factory UsersStatisticsModel.fromMap(Map<String, dynamic> map) {
    return UsersStatisticsModel(
      totalUsers: map['totalUsers']?.toInt() ?? 0,
      citizenUsers: map['citizenUsers']?.toInt() ?? 0,
      inspectorUsers: map['inspectorUsers']?.toInt() ?? 0,
      adminUsers: map['adminUsers']?.toInt() ?? 0,
      activeUsers: map['activeUsers']?.toInt() ?? 0,
      inactiveUsers: map['inactiveUsers']?.toInt() ?? 0,
      userRegistrationsByMonth: Map<String, int>.from(map['userRegistrationsByMonth'] ?? {}),
      averageUserEngagement: map['averageUserEngagement']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalUsers': totalUsers,
      'citizenUsers': citizenUsers,
      'inspectorUsers': inspectorUsers,
      'adminUsers': adminUsers,
      'activeUsers': activeUsers,
      'inactiveUsers': inactiveUsers,
      'userRegistrationsByMonth': userRegistrationsByMonth,
      'averageUserEngagement': averageUserEngagement,
    };
  }
}

class VehiclesStatisticsModel extends VehiclesStatistics {
  const VehiclesStatisticsModel({
    required super.totalVehicles,
    required super.activeVehicles,
    required super.inMaintenanceVehicles,
    required super.totalKilometers,
    required super.averageKmPerVehicle,
    required super.usageByVehicle,
    required super.maintenanceCosts,
    required super.fuelCosts,
  });

  factory VehiclesStatisticsModel.fromMap(Map<String, dynamic> map) {
    return VehiclesStatisticsModel(
      totalVehicles: map['totalVehicles']?.toInt() ?? 0,
      activeVehicles: map['activeVehicles']?.toInt() ?? 0,
      inMaintenanceVehicles: map['inMaintenanceVehicles']?.toInt() ?? 0,
      totalKilometers: map['totalKilometers']?.toDouble() ?? 0.0,
      averageKmPerVehicle: map['averageKmPerVehicle']?.toDouble() ?? 0.0,
      usageByVehicle: Map<String, int>.from(map['usageByVehicle'] ?? {}),
      maintenanceCosts: map['maintenanceCosts']?.toDouble() ?? 0.0,
      fuelCosts: map['fuelCosts']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalVehicles': totalVehicles,
      'activeVehicles': activeVehicles,
      'inMaintenanceVehicles': inMaintenanceVehicles,
      'totalKilometers': totalKilometers,
      'averageKmPerVehicle': averageKmPerVehicle,
      'usageByVehicle': usageByVehicle,
      'maintenanceCosts': maintenanceCosts,
      'fuelCosts': fuelCosts,
    };
  }
}

class PerformanceMetricsModel extends PerformanceMetrics {
  const PerformanceMetricsModel({
    required super.overallEfficiencyScore,
    required super.responseTimeScore,
    required super.resolutionQualityScore,
    required super.citizenSatisfactionScore,
    required super.inspectorProductivityScore,
    required super.monthlyPerformance,
    required super.recommendations,
  });

  factory PerformanceMetricsModel.fromMap(Map<String, dynamic> map) {
    return PerformanceMetricsModel(
      overallEfficiencyScore: map['overallEfficiencyScore']?.toDouble() ?? 0.0,
      responseTimeScore: map['responseTimeScore']?.toDouble() ?? 0.0,
      resolutionQualityScore: map['resolutionQualityScore']?.toDouble() ?? 0.0,
      citizenSatisfactionScore: map['citizenSatisfactionScore']?.toDouble() ?? 0.0,
      inspectorProductivityScore: map['inspectorProductivityScore']?.toDouble() ?? 0.0,
      monthlyPerformance: Map<String, double>.from(map['monthlyPerformance'] ?? {}),
      recommendations: List<String>.from(map['recommendations'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'overallEfficiencyScore': overallEfficiencyScore,
      'responseTimeScore': responseTimeScore,
      'resolutionQualityScore': resolutionQualityScore,
      'citizenSatisfactionScore': citizenSatisfactionScore,
      'inspectorProductivityScore': inspectorProductivityScore,
      'monthlyPerformance': monthlyPerformance,
      'recommendations': recommendations,
    };
  }
}