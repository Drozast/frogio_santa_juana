import 'package:equatable/equatable.dart';

import '../../domain/entities/municipal_statistics_entity.dart';

class MunicipalStatisticsModel extends Equatable {
  final int totalReports;
  final int resolvedReports;
  final int pendingReports;
  final int inProgressReports;
  final int totalQueries;
  final int answeredQueries;
  final int totalInfractions;
  final int activeUsers;
  final int inspectors;
  final DateTime lastUpdated;

  const MunicipalStatisticsModel({
    required this.totalReports,
    required this.resolvedReports,
    required this.pendingReports,
    required this.inProgressReports,
    required this.totalQueries,
    required this.answeredQueries,
    required this.totalInfractions,
    required this.activeUsers,
    required this.inspectors,
    required this.lastUpdated,
  });

  factory MunicipalStatisticsModel.fromJson(Map<String, dynamic> json) {
    return MunicipalStatisticsModel(
      totalReports: json['totalReports'] ?? 0,
      resolvedReports: json['resolvedReports'] ?? 0,
      pendingReports: json['pendingReports'] ?? 0,
      inProgressReports: json['inProgressReports'] ?? 0,
      totalQueries: json['totalQueries'] ?? 0,
      answeredQueries: json['answeredQueries'] ?? 0,
      totalInfractions: json['totalInfractions'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
      inspectors: json['inspectors'] ?? 0,
      lastUpdated: (json['lastUpdated'] as dynamic).toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalReports': totalReports,
      'resolvedReports': resolvedReports,
      'pendingReports': pendingReports,
      'inProgressReports': inProgressReports,
      'totalQueries': totalQueries,
      'answeredQueries': answeredQueries,
      'totalInfractions': totalInfractions,
      'activeUsers': activeUsers,
      'inspectors': inspectors,
      'lastUpdated': lastUpdated,
    };
  }

  MunicipalStatisticsEntity toEntity() {
    return MunicipalStatisticsEntity(
      totalReports: totalReports,
      resolvedReports: resolvedReports,
      pendingReports: pendingReports,
      inProgressReports: inProgressReports,
      totalQueries: totalQueries,
      answeredQueries: answeredQueries,
      totalInfractions: totalInfractions,
      activeUsers: activeUsers,
      inspectors: inspectors,
      lastUpdated: lastUpdated, muniId: '', generatedAt: null, reports: null, infractions: null, users: null, vehicles: null, performance: null,
    );
  }

  @override
  List<Object> get props => [
        totalReports,
        resolvedReports,
        pendingReports,
        inProgressReports,
        totalQueries,
        answeredQueries,
        totalInfractions,
        activeUsers,
        inspectors,
        lastUpdated,
      ];
}