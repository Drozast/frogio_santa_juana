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
// Citizen Feature
import '../features/citizen/data/datasources/report_remote_data_source.dart';
import '../features/citizen/data/datasources/report_remote_data_source_impl.dart';
import '../features/citizen/data/repositories/report_repository_impl.dart';
import '../features/citizen/domain/repositories/report_repository.dart';
import '../features/citizen/domain/usecases/reports/create_report.dart';
import '../features/citizen/domain/usecases/reports/get_report_by_id.dart';
import '../features/citizen/domain/usecases/reports/get_reports_by_user.dart';
import '../features/citizen/presentation/bloc/report/report_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ===== CORE SERVICES =====
  await _initCoreServices();
  
  // ===== FIREBASE INSTANCES =====
  _initFirebaseServices();
  
  // ===== NETWORK =====
  _initNetworkServices();
  
  // ===== FEATURES =====
  await _initAuthFeature();
  await _initCitizenFeature();
  
  // ===== INITIALIZE SERVICES =====
  await _initializeServices();
}

// ===== CORE SERVICES =====
Future<void> _initCoreServices() async {
  sl.registerLazySingleton(() => SessionTimeoutService());
  sl.registerLazySingleton(() => MapsService());
  sl.registerLazySingleton(() => NotificationService());
  sl.registerLazySingleton(() => NotificationManager());
  sl.registerFactory(() => NotificationBloc());
  sl.registerLazySingleton(() => const Uuid());
}

// ===== FIREBASE SERVICES =====
void _initFirebaseServices() {
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
}

// ===== NETWORK SERVICES =====
void _initNetworkServices() {
  sl.registerLazySingleton(() => InternetConnectionChecker());
}

// ===== AUTH FEATURE =====
Future<void> _initAuthFeature() async {
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
}

// ===== CITIZEN FEATURE =====
Future<void> _initCitizenFeature() async {
  // BLoCs
  sl.registerFactory(
    () => ReportBloc(
      getReportsByUser: sl(),
      getReportById: sl(),
      createReport: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetReportsByUser(sl()));
  sl.registerLazySingleton(() => GetReportById(sl()));
  sl.registerLazySingleton(() => CreateReport(sl()));

  // Repository
  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<ReportRemoteDataSource>(
    () => ReportRemoteDataSourceImpl(
      firestore: sl(),
      storage: sl(),
    ),
  );
}

// ===== SERVICE INITIALIZATION =====
Future<void> _initializeServices() async {
  try {
    final notificationService = sl<NotificationService>();
    await notificationService.initialize();
    
    final notificationManager = sl<NotificationManager>();
    await notificationManager.initialize();
    
    final sessionService = sl<SessionTimeoutService>();
    sessionService.startTimer();
    
    print('✅ FROGIO: Services initialized');
  } catch (e) {
    print('❌ FROGIO: Error initializing services: $e');
    rethrow;
  }
}

// ===== UTILITY METHODS =====
Future<void> resetDependencies() async {
  await sl.reset();
}

bool validateDependencies() {
  try {
    sl<SessionTimeoutService>();
    sl<MapsService>();
    sl<NotificationService>();
    sl<FirebaseAuth>();
    sl<FirebaseFirestore>();
    sl<FirebaseStorage>();
    sl<AuthBloc>();
    sl<ReportBloc>();
    return true;
  } catch (e) {
    print('❌ FROGIO: Dependency validation failed: $e');
    return false;
  }
}

Map<String, bool> getDependencyInfo() {
  return {
    'SessionTimeoutService': sl.isRegistered<SessionTimeoutService>(),
    'MapsService': sl.isRegistered<MapsService>(),
    'NotificationService': sl.isRegistered<NotificationService>(),
    'NotificationManager': sl.isRegistered<NotificationManager>(),
    'AuthBloc': sl.isRegistered<AuthBloc>(),
    'ReportBloc': sl.isRegistered<ReportBloc>(),
    'ProfileBloc': sl.isRegistered<ProfileBloc>(),
    'NotificationBloc': sl.isRegistered<NotificationBloc>(),
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