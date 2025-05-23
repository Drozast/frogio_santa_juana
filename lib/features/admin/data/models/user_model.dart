// lib/features/admin/data/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    super.firstName,
    super.lastName,
    required super.role,
    super.muniId,
    super.muniName,
    required super.isActive,
    required super.isEmailVerified,
    super.phoneNumber,
    super.address,
    super.profileImageUrl,
    required super.createdAt,
    required super.updatedAt,
    super.lastLoginAt,
    required super.permissions,
    required super.statistics,
    required super.assignedAreas,
    super.preferences,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      firstName: data['firstName'],
      lastName: data['lastName'],
      role: data['role'] ?? 'citizen',
      muniId: data['muniId'],
      muniName: data['muniName'],
      isActive: data['isActive'] ?? true,
      isEmailVerified: data['isEmailVerified'] ?? false,
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      profileImageUrl: data['profileImageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      permissions: UserPermissionsModel.fromMap(data['permissions'] ?? {}),
      statistics: UserStatisticsModel.fromMap(data['statistics'] ?? {}),
      assignedAreas: List<String>.from(data['assignedAreas'] ?? []),
      preferences: data['preferences'] != null 
          ? Map<String, dynamic>.from(data['preferences'])
          : null,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      firstName: map['firstName'],
      lastName: map['lastName'],
      role: map['role'] ?? 'citizen',
      muniId: map['muniId'],
      muniName: map['muniName'],
      isActive: map['isActive'] ?? true,
      isEmailVerified: map['isEmailVerified'] ?? false,
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      profileImageUrl: map['profileImageUrl'],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: map['lastLoginAt'] is Timestamp
          ? (map['lastLoginAt'] as Timestamp).toDate()
          : map['lastLoginAt'] != null
              ? DateTime.parse(map['lastLoginAt'])
              : null,
      permissions: UserPermissionsModel.fromMap(map['permissions'] ?? {}),
      statistics: UserStatisticsModel.fromMap(map['statistics'] ?? {}),
      assignedAreas: List<String>.from(map['assignedAreas'] ?? []),
      preferences: map['preferences'] != null 
          ? Map<String, dynamic>.from(map['preferences'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'muniId': muniId,
      'muniName': muniName,
      'isActive': isActive,
      'isEmailVerified': isEmailVerified,
      'phoneNumber': phoneNumber,
      'address': address,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastLoginAt': lastLoginAt,
      'permissions': (permissions as UserPermissionsModel).toMap(),
      'statistics': (statistics as UserStatisticsModel).toMap(),
      'assignedAreas': assignedAreas,
      'preferences': preferences,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'muniId': muniId,
      'muniName': muniName,
      'isActive': isActive,
      'isEmailVerified': isEmailVerified,
      'phoneNumber': phoneNumber,
      'address': address,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'permissions': (permissions as UserPermissionsModel).toMap(),
      'statistics': (statistics as UserStatisticsModel).toMap(),
      'assignedAreas': assignedAreas,
      'preferences': preferences,
    };
  }
}

class UserPermissionsModel extends UserPermissions {
  const UserPermissionsModel({
    required super.canManageUsers,
    required super.canManageReports,
    required super.canManageInfractions,
    required super.canManageVehicles,
    required super.canViewStatistics,
    required super.canExportData,
    required super.canManageSettings,
    required super.canAssignTasks,
    required super.canApproveActions,
    required super.allowedModules,
  });

  factory UserPermissionsModel.fromMap(Map<String, dynamic> map) {
    return UserPermissionsModel(
      canManageUsers: map['canManageUsers'] ?? false,
      canManageReports: map['canManageReports'] ?? false,
      canManageInfractions: map['canManageInfractions'] ?? false,
      canManageVehicles: map['canManageVehicles'] ?? false,
      canViewStatistics: map['canViewStatistics'] ?? false,
      canExportData: map['canExportData'] ?? false,
      canManageSettings: map['canManageSettings'] ?? false,
      canAssignTasks: map['canAssignTasks'] ?? false,
      canApproveActions: map['canApproveActions'] ?? false,
      allowedModules: List<String>.from(map['allowedModules'] ?? []),
    );
  }

  factory UserPermissionsModel.fromEntity(UserPermissions entity) {
    return UserPermissionsModel(
      canManageUsers: entity.canManageUsers,
      canManageReports: entity.canManageReports,
      canManageInfractions: entity.canManageInfractions,
      canManageVehicles: entity.canManageVehicles,
      canViewStatistics: entity.canViewStatistics,
      canExportData: entity.canExportData,
      canManageSettings: entity.canManageSettings,
      canAssignTasks: entity.canAssignTasks,
      canApproveActions: entity.canApproveActions,
      allowedModules: entity.allowedModules,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'canManageUsers': canManageUsers,
      'canManageReports': canManageReports,
      'canManageInfractions': canManageInfractions,
      'canManageVehicles': canManageVehicles,
      'canViewStatistics': canViewStatistics,
      'canExportData': canExportData,
      'canManageSettings': canManageSettings,
      'canAssignTasks': canAssignTasks,
      'canApproveActions': canApproveActions,
      'allowedModules': allowedModules,
    };
  }
}

class UserStatisticsModel extends UserStatistics {
  const UserStatisticsModel({
    required super.totalReportsCreated,
    required super.totalInfractionsIssued,
    required super.totalQueriesAnswered,
    required super.averageResponseTimeHours,
    required super.tasksCompleted,
    required super.performanceScore,
    super.lastActivityDate,
    required super.monthlyActivity,
  });

  factory UserStatisticsModel.fromMap(Map<String, dynamic> map) {
    return UserStatisticsModel(
      totalReportsCreated: map['totalReportsCreated']?.toInt() ?? 0,
      totalInfractionsIssued: map['totalInfractionsIssued']?.toInt() ?? 0,
      totalQueriesAnswered: map['totalQueriesAnswered']?.toInt() ?? 0,
      averageResponseTimeHours: map['averageResponseTimeHours']?.toDouble() ?? 0.0,
      tasksCompleted: map['tasksCompleted']?.toInt() ?? 0,
      performanceScore: map['performanceScore']?.toDouble() ?? 0.0,
      lastActivityDate: map['lastActivityDate'] is Timestamp
          ? (map['lastActivityDate'] as Timestamp).toDate()
          : map['lastActivityDate'] != null
              ? DateTime.parse(map['lastActivityDate'])
              : null,
      monthlyActivity: Map<String, int>.from(map['monthlyActivity'] ?? {}),
    );
  }

  factory UserStatisticsModel.fromEntity(UserStatistics entity) {
    return UserStatisticsModel(
      totalReportsCreated: entity.totalReportsCreated,
      totalInfractionsIssued: entity.totalInfractionsIssued,
      totalQueriesAnswered: entity.totalQueriesAnswered,
      averageResponseTimeHours: entity.averageResponseTimeHours,
      tasksCompleted: entity.tasksCompleted,
      performanceScore: entity.performanceScore,
      lastActivityDate: entity.lastActivityDate,
      monthlyActivity: entity.monthlyActivity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalReportsCreated': totalReportsCreated,
      'totalInfractionsIssued': totalInfractionsIssued,
      'totalQueriesAnswered': totalQueriesAnswered,
      'averageResponseTimeHours': averageResponseTimeHours,
      'tasksCompleted': tasksCompleted,
      'performanceScore': performanceScore,
      'lastActivityDate': lastActivityDate?.toIso8601String(),
      'monthlyActivity': monthlyActivity,
    };
  }
}