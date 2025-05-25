import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

// Core Services
import '../core/blocs/notification/notification_bloc.dart';
import '../core/services/maps_service.dart';
import '../core/services/notification_manager.dart';
import '../core/services/notification_service.dart';
import '../core/services/session_timeout_service.dart';
// Dashboard Feature
import '../dashboard/presentation/bloc/theme/theme_bloc.dart';
// Admin Feature
import '../features/admin/data/datasources/admin_remote_data_source.dart';
import '../features/admin/data/datasources/admin_remote_data_source_impl.dart';
import '../features/admin/data/repositories/admin_repository_impl.dart';
import '../features/admin/domain/repositories/admin_repository.dart';
import '../features/admin/domain/usecases/activate_user.dart';
import '../features/admin/domain/usecases/answer_query.dart';
import '../features/admin/domain/usecases/deactivate_user.dart';
import '../features/admin/domain/usecases/get_all_pending_queries.dart';
import '../features/admin/domain/usecases/get_all_users.dart';
import '../features/admin/domain/usecases/get_municipal_statistics.dart';
import '../features/admin/domain/usecases/update_user_role.dart';
import '../features/admin/presentation/bloc/statistics/statistics_bloc.dart';
import '../features/admin/presentation/bloc/user_management/user_management_bloc.dart';
// Auth Feature - Asumiendo que existen
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/datasources/auth_remote_data_source_impl.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/forgot_password.dart';
import '../features/auth/domain/usecases/get_current_user.dart';
import '../features/auth/domain/usecases/register_user.dart';
import '../features/auth/domain/usecases/sign_in_user.dart';
import '../features/auth/domain/usecases/sign_out_user.dart';
import '../features/auth/domain/usecases/update_user_profile.dart';
import '../features/auth/domain/usecases/upload_profile_image.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/profile/profile_bloc.dart';
// Citizen Feature - Asumiendo que existen
import '../features/citizen/data/datasources/enhanced_report_remote_data_source.dart';
import '../features/citizen/data/datasources/enhanced_report_remote_data_source_impl.dart';
import '../features/citizen/data/repositories/enhanced_report_repository_impl.dart';
import '../features/citizen/domain/repositories/enhanced_report_repository.dart';
import '../features/citizen/domain/usecases/reports/enhanced_report_use_cases.dart';
import '../features/citizen/presentation/bloc/report/enhanced_report_bloc.dart';
// Inspector Feature
import '../features/inspector/data/datasources/infraction_remote_data_source.dart';
import '../features/inspector/data/datasources/infraction_remote_data_source_impl.dart';
import '../features/inspector/data/repositories/infraction_repository_impl.dart';
import '../features/inspector/domain/repositories/infraction_repository.dart';
import '../features/inspector/domain/usecases/create_infraction.dart';
import '../features/inspector/domain/usecases/get_infractions_by_inspector.dart';
import '../features/inspector/domain/usecases/update_infraction_status.dart';
import '../features/inspector/domain/usecases/upload_infraction_image.dart';
import '../features/inspector/presentation/bloc/infraction_bloc.dart';
// Vehicles Feature
import '../features/vehicles/data/datasources/vehicle_remote_data_source.dart';
import '../features/vehicles/data/datasources/vehicle_remote_data_source_impl.dart';
import '../features/vehicles/data/repositories/vehicle_repository_impl.dart';
import '../features/vehicles/domain/repositories/vehicle_repository.dart';
import '../features/vehicles/domain/usecases/end_vehicle_usage.dart';
import '../features/vehicles/domain/usecases/get_vehicles.dart';
import '../features/vehicles/domain/usecases/start_vehicle_usage.dart';
import '../features/vehicles/presentation/bloc/vehicle_bloc.dart';

final sl = GetIt.instance;
final logger = Logger();

Future<void> init() async {
  logger.i('🚀 FROGIO: Initializing dependencies...');
  
  // ===== CORE SERVICES =====
  await _initCoreServices();
  
  // ===== FIREBASE INSTANCES =====
  _initFirebaseServices();
  
  // ===== NETWORK =====
  _initNetworkServices();
  
  // ===== FEATURES =====
  await _initAuthFeature();
  await _initCitizenFeature();
  await _initInspectorFeature();
  await _initAdminFeature();
  await _initVehiclesFeature();
  await _initDashboardFeature();
  
  // ===== INITIALIZE SERVICES =====
  await _initializeServices();
  
  // ===== VALIDATION =====
  _validateDependencies();
  
  logger.i('✅ FROGIO: All dependencies initialized successfully');
}

// ===== CORE SERVICES =====
Future<void> _initCoreServices() async {
  logger.d('📦 Initializing core services...');
  
  sl.registerLazySingleton(() => Logger());
  sl.registerLazySingleton(() => SessionTimeoutService());
  sl.registerLazySingleton(() => MapsService());
  sl.registerLazySingleton(() => NotificationService());
  sl.registerLazySingleton(() => NotificationManager());
  sl.registerFactory(() => NotificationBloc());
  sl.registerLazySingleton(() => const Uuid());
  
  logger.d('✅ Core services registered');
}

// ===== FIREBASE SERVICES =====
void _initFirebaseServices() {
  logger.d('🔥 Initializing Firebase services...');
  
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  
  logger.d('✅ Firebase services registered');
}

// ===== NETWORK SERVICES =====
void _initNetworkServices() {
  logger.d('🌐 Initializing network services...');
  
  sl.registerLazySingleton(() => InternetConnectionChecker());
  
  logger.d('✅ Network services registered');
}

// ===== AUTH FEATURE =====
Future<void> _initAuthFeature() async {
  logger.d('🔐 Initializing Auth feature...');

  // BLoCs
  sl.registerFactory(
    () => AuthBloc(
      getCurrentUser: sl(),
      signInUser: sl(),
      signOutUser: sl(),
      registerUser: sl(),
      forgotPassword: sl(),
    ),
  );

  sl.registerFactory(
    () => ProfileBloc(
      updateUserProfile: sl(),
      uploadProfileImage: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => SignInUser(sl()));
  sl.registerLazySingleton(() => SignOutUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => ForgotPassword(sl()));
  sl.registerLazySingleton(() => UpdateUserProfile(sl()));
  sl.registerLazySingleton(() => UploadProfileImage(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      storage: sl(),
    ),
  );
  
  logger.d('✅ Auth feature registered');
}

// ===== CITIZEN FEATURE (ENHANCED) =====
Future<void> _initCitizenFeature() async {
  logger.d('👤 Initializing Citizen feature...');

  // BLoCs
  sl.registerFactory(
    () => ReportBloc(
      createReport: sl(),
      getReportsByUser: sl(),
      getReportById: sl(),
      updateReportStatus: sl(),
      addReportResponse: sl(),
      getReportsByStatus: sl(),
      assignReport: sl(),
      watchReportsByUser: sl(),
      watchReportsByStatus: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => CreateEnhancedReport(sl()));
  sl.registerLazySingleton(() => GetEnhancedReportsByUser(sl()));
  sl.registerLazySingleton(() => GetEnhancedReportById(sl()));
  sl.registerLazySingleton(() => UpdateReportStatus(sl()));
  sl.registerLazySingleton(() => AddReportResponse(sl()));
  sl.registerLazySingleton(() => GetReportsByStatus(sl()));
  sl.registerLazySingleton(() => AssignReport(sl()));
  sl.registerLazySingleton(() => WatchReportsByUser(sl()));
  sl.registerLazySingleton(() => WatchReportsByStatus(sl()));

  // Repository
  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<ReportRemoteDataSource>(
    () => ReportRemoteDataSourceImpl(
      firestore: sl(),
      storage: sl(),
      uuid: sl(),
    ),
  );
  
  logger.d('✅ Citizen feature registered');
}

// ===== INSPECTOR FEATURE =====
Future<void> _initInspectorFeature() async {
  logger.d('🕵️ Initializing Inspector feature...');

  // BLoCs
  sl.registerFactory(
    () => InfractionBloc(
      getInfractionsByInspector: sl(),
      createInfraction: sl(),
      updateInfractionStatus: sl(),
      uploadInfractionImage: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetInfractionsByInspector(sl()));
  sl.registerLazySingleton(() => CreateInfraction(sl()));
  sl.registerLazySingleton(() => UpdateInfractionStatus(sl()));
  sl.registerLazySingleton(() => UploadInfractionImage(sl()));

  // Repository
  sl.registerLazySingleton<InfractionRepository>(
    () => InfractionRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<InfractionRemoteDataSource>(
    () => InfractionRemoteDataSourceImpl(
      firestore: sl(),
      storage: sl(),
      uuid: sl(),
    ),
  );
  
  logger.d('✅ Inspector feature registered');
}
// ===== ADMIN FEATURE =====
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? firstName;
  final String? lastName;
  final String role;
  final String? muniId;
  final String? muniName;
  final bool isActive;
  final bool isEmailVerified;
  final String? phoneNumber;
  final String? address;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  final UserPermissions permissions;
  final UserStatistics statistics;
  final List<String> assignedAreas;
  final Map<String, dynamic>? preferences;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.firstName,
    this.lastName,
    required this.role,
    this.muniId,
    this.muniName,
    required this.isActive,
    required this.isEmailVerified,
    this.phoneNumber,
    this.address,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    required this.permissions,
    required this.statistics,
    required this.assignedAreas,
    this.preferences,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    firstName,
    lastName,
    role,
    muniId,
    muniName,
    isActive,
    isEmailVerified,
    phoneNumber,
    address,
    profileImageUrl,
    createdAt,
    updatedAt,
    lastLoginAt,
    permissions,
    statistics,
    assignedAreas,
    preferences,
  ];

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? firstName,
    String? lastName,
    String? role,
    String? muniId,
    String? muniName,
    bool? isActive,
    bool? isEmailVerified,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    UserPermissions? permissions,
    UserStatistics? statistics,
    List<String>? assignedAreas,
    Map<String, dynamic>? preferences,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      muniId: muniId ?? this.muniId,
      muniName: muniName ?? this.muniName,
      isActive: isActive ?? this.isActive,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      permissions: permissions ?? this.permissions,
      statistics: statistics ?? this.statistics,
      assignedAreas: assignedAreas ?? this.assignedAreas,
      preferences: preferences ?? this.preferences,
    );
  }

  // Métodos útiles
  bool get isCitizen => role == 'citizen';
  bool get isInspector => role == 'inspector';
  bool get isAdmin => role == 'admin';
  bool get isSuperAdmin => role == 'superAdmin';
  
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return displayName;
  }
  
  bool get hasRecentActivity {
    if (lastLoginAt == null) return false;
    return DateTime.now().difference(lastLoginAt!).inDays <= 7;
  }
  
  String get roleDisplayName {
    switch (role) {
      case 'citizen':
        return 'Ciudadano';
      case 'inspector':
        return 'Inspector';
      case 'admin':
        return 'Administrador';
      case 'superAdmin':
        return 'Super Administrador';
      default:
        return role;
    }
  }
}

class UserPermissions extends Equatable {
  final bool canManageUsers;
  final bool canManageReports;
  final bool canManageInfractions;
  final bool canManageVehicles;
  final bool canViewStatistics;
  final bool canExportData;
  final bool canManageSettings;
  final bool canAssignTasks;
  final bool canApproveActions;
  final List<String> allowedModules;

  const UserPermissions({
    required this.canManageUsers,
    required this.canManageReports,
    required this.canManageInfractions,
    required this.canManageVehicles,
    required this.canViewStatistics,
    required this.canExportData,
    required this.canManageSettings,
    required this.canAssignTasks,
    required this.canApproveActions,
    required this.allowedModules,
  });

  factory UserPermissions.fromRole(String role) {
    switch (role) {
      case 'citizen':
        return const UserPermissions(
          canManageUsers: false,
          canManageReports: false,
          canManageInfractions: false,
          canManageVehicles: false,
          canViewStatistics: false,
          canExportData: false,
          canManageSettings: false,
          canAssignTasks: false,
          canApproveActions: false,
          allowedModules: ['reports', 'queries'],
        );
      case 'inspector':
        return const UserPermissions(
          canManageUsers: false,
          canManageReports: true,
          canManageInfractions: true,
          canManageVehicles: true,
          canViewStatistics: true,
          canExportData: false,
          canManageSettings: false,
          canAssignTasks: false,
          canApproveActions: false,
          allowedModules: ['reports', 'infractions', 'vehicles', 'statistics'],
        );
      case 'admin':
        return const UserPermissions(
          canManageUsers: true,
          canManageReports: true,
          canManageInfractions: true,
          canManageVehicles: true,
          canViewStatistics: true,
          canExportData: true,
          canManageSettings: true,
          canAssignTasks: true,
          canApproveActions: true,
          allowedModules: ['reports', 'infractions', 'vehicles', 'statistics', 'users', 'settings'],
        );
      case 'superAdmin':
        return const UserPermissions(
          canManageUsers: true,
          canManageReports: true,
          canManageInfractions: true,
          canManageVehicles: true,
          canViewStatistics: true,
          canExportData: true,
          canManageSettings: true,
          canAssignTasks: true,
          canApproveActions: true,
          allowedModules: ['all'],
        );
      default:
        return const UserPermissions(
          canManageUsers: false,
          canManageReports: false,
          canManageInfractions: false,
          canManageVehicles: false,
          canViewStatistics: false,
          canExportData: false,
          canManageSettings: false,
          canAssignTasks: false,
          canApproveActions: false,
          allowedModules: [],
        );
    }
  }

  @override
  List<Object> get props => [
    canManageUsers,
    canManageReports,
    canManageInfractions,
    canManageVehicles,
    canViewStatistics,
    canExportData,
    canManageSettings,
    canAssignTasks,
    canApproveActions,
    allowedModules,
  ];
}

class UserStatistics extends Equatable {
  final int totalReportsCreated;
  final int totalInfractionsIssued;
  final int totalQueriesAnswered;
  final double averageResponseTimeHours;
  final int tasksCompleted;
  final double performanceScore;
  final DateTime? lastActivityDate;
  final Map<String, int> monthlyActivity;

  const UserStatistics({
    required this.totalReportsCreated,
    required this.totalInfractionsIssued,
    required this.totalQueriesAnswered,
    required this.averageResponseTimeHours,
    required this.tasksCompleted,
    required this.performanceScore,
    this.lastActivityDate,
    required this.monthlyActivity,
  });

  factory UserStatistics.empty() {
    return const UserStatistics(
      totalReportsCreated: 0,
      totalInfractionsIssued: 0,
      totalQueriesAnswered: 0,
      averageResponseTimeHours: 0,
      tasksCompleted: 0,
      performanceScore: 0,
      monthlyActivity: {},
    );
  }

  @override
  List<Object?> get props => [
    totalReportsCreated,
    totalInfractionsIssued,
    totalQueriesAnswered,
    averageResponseTimeHours,
    tasksCompleted,
    performanceScore,
    lastActivityDate,
    monthlyActivity,
  ];
}

// ===== VEHICLES FEATURE =====
Future<void> _initVehiclesFeature() async {
  logger.d('🚗 Initializing Vehicles feature...');

  // BLoCs
  sl.registerFactory(
    () => VehicleBloc(
      getVehicles: sl(),
      startVehicleUsage: sl(),
      endVehicleUsage: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetVehicles(sl()));
  sl.registerLazySingleton(() => StartVehicleUsage(repository: sl()));
  sl.registerLazySingleton(() => EndVehicleUsage(repository: sl()));

  // Repository
  sl.registerLazySingleton<VehicleRepository>(
    () => VehicleRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<VehicleRemoteDataSource>(
    () => VehicleRemoteDataSourceImpl(
      firestore: sl(),
      uuid: sl(),
    ),
  );
  
  logger.d('✅ Vehicles feature registered');
}
// ===== DASHBOARD FEATURE =====
Future<void> _initDashboardFeature() async {
  logger.d('📊 Initializing Dashboard feature...');

  // BLoCs
  sl.registerFactory(() => ThemeBloc());
  
  logger.d('✅ Dashboard feature registered');
}

// ===== SERVICE INITIALIZATION =====
Future<void> _initializeServices() async {
  logger.d('🔧 Initializing services...');
  
  try {
    final notificationService = sl<NotificationService>();
    await notificationService.initialize();
    
    final notificationManager = sl<NotificationManager>();
    await notificationManager.initialize();
    
    final sessionService = sl<SessionTimeoutService>();
    sessionService.startTimer();
    
    logger.d('✅ Services initialized successfully');
  } catch (e) {
    logger.e('❌ Error initializing services: $e');
    rethrow;
  }
}

// ===== VALIDATION =====
void _validateDependencies() {
  logger.d('🔍 Validating dependencies...');
  
  final validations = <String, bool>{
    'Logger': _validateService<Logger>(),
    'SessionTimeoutService': _validateService<SessionTimeoutService>(),
    'MapsService': _validateService<MapsService>(),
    'NotificationService': _validateService<NotificationService>(),
    'AuthBloc': _validateService<AuthBloc>(),
    'ReportBloc': _validateService<ReportBloc>(),
    'InfractionBloc': _validateService<InfractionBloc>(),
    'VehicleBloc': _validateService<VehicleBloc>(),
    'UserManagementBloc': _validateService<UserManagementBloc>(),
    'FirebaseAuth': _validateService<FirebaseAuth>(),
    'FirebaseFirestore': _validateService<FirebaseFirestore>(),
    'FirebaseStorage': _validateService<FirebaseStorage>(),
  };

  final failed = validations.entries.where((e) => !e.value).map((e) => e.key).toList();
  
  if (failed.isNotEmpty) {
    logger.e('❌ Failed dependencies: ${failed.join(', ')}');
    throw Exception('Dependency validation failed for: ${failed.join(', ')}');
  }
  
  logger.d('✅ All dependencies validated successfully');
}

bool _validateService<T extends Object>() {
  try {
    sl<T>();
    return true;
  } catch (e) {
    return false;
  }
}

// ===== UTILITY METHODS =====
Future<void> resetDependencies() async {
  logger.i('🔄 Resetting dependencies...');
  await sl.reset();
  logger.i('✅ Dependencies reset');
}

Map<String, bool> getDependencyInfo() {
  return {
    'Logger': sl.isRegistered<Logger>(),
    'SessionTimeoutService': sl.isRegistered<SessionTimeoutService>(),
    'MapsService': sl.isRegistered<MapsService>(),
    'NotificationService': sl.isRegistered<NotificationService>(),
    'NotificationManager': sl.isRegistered<NotificationManager>(),
    'AuthBloc': sl.isRegistered<AuthBloc>(),
    'ReportBloc': sl.isRegistered<ReportBloc>(),
    'InfractionBloc': sl.isRegistered<InfractionBloc>(),
    'VehicleBloc': sl.isRegistered<VehicleBloc>(),
    'UserManagementBloc': sl.isRegistered<UserManagementBloc>(),
    'StatisticsBloc': sl.isRegistered<StatisticsBloc>(),
    'ProfileBloc': sl.isRegistered<ProfileBloc>(),
    'NotificationBloc': sl.isRegistered<NotificationBloc>(),
    'ThemeBloc': sl.isRegistered<ThemeBloc>(),
    'FirebaseAuth': sl.isRegistered<FirebaseAuth>(),
    'FirebaseFirestore': sl.isRegistered<FirebaseFirestore>(),
    'FirebaseStorage': sl.isRegistered<FirebaseStorage>(),
    'InternetConnectionChecker': sl.isRegistered<InternetConnectionChecker>(),
    'Uuid': sl.isRegistered<Uuid>(),
  };
}

void printDependencies() {
  final info = getDependencyInfo();
  logger.i('🔧 FROGIO Dependencies Status:');
  info.forEach((key, value) {
    logger.i('  ${value ? '✅' : '❌'} $key');
  });
}

// ===== ERROR HANDLING =====
void logDependencyError(String feature, dynamic error) {
  logger.e('❌ FROGIO [$feature]: $error');
}

// ===== HEALTH CHECK =====
bool isHealthy() {
  try {
    final requiredServices = [
      sl<FirebaseAuth>(),
      sl<FirebaseFirestore>(),
      sl<AuthBloc>(),
      sl<SessionTimeoutService>(),
    ];
    return requiredServices.isNotEmpty;
  } catch (e) {
    logger.e('❌ Health check failed: $e');
    return false;
  }
}