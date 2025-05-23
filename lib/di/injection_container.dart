// lib/di/injection_container.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
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
import '../features/admin/domain/usecases/answer_query.dart';
import '../features/admin/domain/usecases/get_all_pending_queries.dart';
import '../features/admin/domain/usecases/get_municipal_statistics.dart';
import '../features/admin/presentation/bloc/statistics/statistics_bloc.dart';
import '../features/admin/presentation/bloc/user_management/user_management_bloc.dart';
// Auth Feature
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
// Citizen Feature - Enhanced
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

Future<void> init() async {
  print('🚀 FROGIO: Initializing dependencies...');
  
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
  
  print('✅ FROGIO: All dependencies initialized successfully');
}

// ===== CORE SERVICES =====
Future<void> _initCoreServices() async {
  print('📦 Initializing core services...');
  
  sl.registerLazySingleton(() => SessionTimeoutService());
  sl.registerLazySingleton(() => MapsService());
  sl.registerLazySingleton(() => NotificationService());
  sl.registerLazySingleton(() => NotificationManager());
  sl.registerFactory(() => NotificationBloc());
  sl.registerLazySingleton(() => const Uuid());
  
  print('✅ Core services registered');
}

// ===== FIREBASE SERVICES =====
void _initFirebaseServices() {
  print('🔥 Initializing Firebase services...');
  
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  
  print('✅ Firebase services registered');
}

// ===== NETWORK SERVICES =====
void _initNetworkServices() {
  print('🌐 Initializing network services...');
  
  sl.registerLazySingleton(() => InternetConnectionChecker());
  
  print('✅ Network services registered');
}

// ===== AUTH FEATURE =====
Future<void> _initAuthFeature() async {
  print('🔐 Initializing Auth feature...');

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
  
  print('✅ Auth feature registered');
}

// ===== CITIZEN FEATURE (ENHANCED) =====
Future<void> _initCitizenFeature() async {
  print('👤 Initializing Citizen feature...');

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
  
  print('✅ Citizen feature registered');
}

// ===== INSPECTOR FEATURE =====
Future<void> _initInspectorFeature() async {
  print('🕵️ Initializing Inspector feature...');

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
  
  print('✅ Inspector feature registered');
}

// ===== ADMIN FEATURE =====
Future<void> _initAdminFeature() async {
  print('👨‍💼 Initializing Admin feature...');

  // BLoCs
  sl.registerFactory(
    () => UserManagementBloc(
      getAllPendingQueries: sl(),
      answerQuery: sl(),
    ),
  );

  sl.registerFactory(
    () => StatisticsBloc(
      getMunicipalStatistics: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetAllPendingQueries(sl()));
  sl.registerLazySingleton(() => AnswerQuery(sl()));
  sl.registerLazySingleton(() => GetMunicipalStatistics(sl()));

  // Repository
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(
      firestore: sl(),
      storage: sl(),
    ),
  );
  
  print('✅ Admin feature registered');
}

// ===== VEHICLES FEATURE =====
Future<void> _initVehiclesFeature() async {
  print('🚗 Initializing Vehicles feature...');

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
  sl.registerLazySingleton(() => StartVehicleUsage(sl()));
  sl.registerLazySingleton(() => EndVehicleUsage(sl()));

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
  
  print('✅ Vehicles feature registered');
}

// ===== DASHBOARD FEATURE =====
Future<void> _initDashboardFeature() async {
  print('📊 Initializing Dashboard feature...');

  // BLoCs
  sl.registerFactory(() => ThemeBloc());
  
  print('✅ Dashboard feature registered');
}

// ===== SERVICE INITIALIZATION =====
Future<void> _initializeServices() async {
  print('🔧 Initializing services...');
  
  try {
    final notificationService = sl<NotificationService>();
    await notificationService.initialize();
    
    final notificationManager = sl<NotificationManager>();
    await notificationManager.initialize();
    
    final sessionService = sl<SessionTimeoutService>();
    sessionService.startTimer();
    
    print('✅ Services initialized successfully');
  } catch (e) {
    print('❌ Error initializing services: $e');
    rethrow;
  }
}

// ===== VALIDATION =====
void _validateDependencies() {
  print('🔍 Validating dependencies...');
  
  final validations = <String, bool>{
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
    print('❌ Failed dependencies: ${failed.join(', ')}');
    throw Exception('Dependency validation failed for: ${failed.join(', ')}');
  }
  
  print('✅ All dependencies validated successfully');
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
  print('🔄 Resetting dependencies...');
  await sl.reset();
  print('✅ Dependencies reset');
}

Map<String, bool> getDependencyInfo() {
  return {
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
  print('🔧 FROGIO Dependencies Status:');
  info.forEach((key, value) {
    print('  ${value ? '✅' : '❌'} $key');
  });
}

// ===== ERROR HANDLING =====
void logDependencyError(String feature, dynamic error) {
  print('❌ FROGIO [$feature]: $error');
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
    return requiredServices.every((service) => service != null);
  } catch (e) {
    print('❌ Health check failed: $e');
    return false;
  }
}