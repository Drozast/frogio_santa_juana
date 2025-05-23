// lib/di/injection_container.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

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
 
  // ===== AUTH FEATURE =====
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

  // ===== CITIZEN FEATURE =====
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

  // ===== INSPECTOR FEATURE (TODO) =====
  // sl.registerFactory(() => InspectorBloc(...));
  // sl.registerLazySingleton(() => CreateInfraction(sl()));
  // sl.registerLazySingleton(() => GetInfractionsByInspector(sl()));
  // sl.registerLazySingleton<InfractionRepository>(() => InfractionRepositoryImpl(remoteDataSource: sl()));
  // sl.registerLazySingleton<InfractionRemoteDataSource>(() => InfractionRemoteDataSourceImpl(...));

  // ===== ADMIN FEATURE (TODO) =====
  // sl.registerFactory(() => AdminBloc(...));
  // sl.registerLazySingleton(() => GetAllReports(sl()));
  // sl.registerLazySingleton(() => AssignReportToInspector(sl()));
  // sl.registerLazySingleton(() => GetReportStatistics(sl()));
  // sl.registerLazySingleton<AdminRepository>(() => AdminRepositoryImpl(remoteDataSource: sl()));
  // sl.registerLazySingleton<AdminRemoteDataSource>(() => AdminRemoteDataSourceImpl(...));

  // ===== VEHICLES FEATURE (TODO) =====
  // sl.registerFactory(() => VehicleBloc(...));
  // sl.registerLazySingleton(() => GetVehicles(sl()));
  // sl.registerLazySingleton(() => StartVehicleUsage(sl()));
  // sl.registerLazySingleton(() => EndVehicleUsage(sl()));
  // sl.registerLazySingleton<VehicleRepository>(() => VehicleRepositoryImpl(remoteDataSource: sl()));
  // sl.registerLazySingleton<VehicleRemoteDataSource>(() => VehicleRemoteDataSourceImpl(...));

  
  sl.registerLazySingleton(() => SessionTimeoutService());
  sl.registerLazySingleton(() => MapsService());
  sl.registerLazySingleton(() => NotificationService());
  sl.registerLazySingleton(() => NotificationManager());

  
  sl.registerFactory(() => NotificationBloc());


  
  // Firebase
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  
  // Network
  sl.registerLazySingleton(() => InternetConnectionChecker());

 
  // Inicializar servicios que lo requieran
  await _initializeServices();
}

Future<void> _initializeServices() async {
  // Inicializar notification service
  final notificationService = sl<NotificationService>();
  await notificationService.initialize();
  
  // Inicializar notification manager
  final notificationManager = sl<NotificationManager>();
  await notificationManager.initialize();
  
  // Configurar session timeout
  final sessionService = sl<SessionTimeoutService>();
  sessionService.startTimer();
}