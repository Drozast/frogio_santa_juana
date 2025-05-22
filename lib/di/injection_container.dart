// lib/di/injection_container.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:frogio_santa_juana/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../core/services/session_timeout_service.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/datasources/auth_remote_data_source_impl.dart';
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
  // Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      getCurrentUser: sl(),
      signInUser: sl(),
      signOutUser: sl(),
      registerUser: sl(),
      forgotPassword: sl(),
    ),
  );

  // Profile Bloc
  sl.registerFactory(
    () => ProfileBloc(
      updateUserProfile: sl(),
      uploadProfileImage: sl(),
    ),
  );

  // Use cases - Auth
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => SignInUser(sl()));
  sl.registerLazySingleton(() => SignOutUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => ForgotPassword(sl()));
  sl.registerLazySingleton(() => UpdateUserProfile(sl()));
  sl.registerLazySingleton(() => UploadProfileImage(sl()));

  // Repository - Auth
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources - Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      storage: sl(),
    ),
  );

  // Features - Citizen Reports
  // Bloc
  sl.registerFactory(
    () => ReportBloc(
      getReportsByUser: sl(),
      getReportById: sl(),
      createReport: sl(),
    ),
  );

  // Use cases - Reports
  sl.registerLazySingleton(() => GetReportsByUser(sl()));
  sl.registerLazySingleton(() => GetReportById(sl()));
  sl.registerLazySingleton(() => CreateReport(sl()));

  // Repository - Reports
  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources - Reports
  sl.registerLazySingleton<ReportRemoteDataSource>(
    () => ReportRemoteDataSourceImpl(
      firestore: sl(),
      storage: sl(),
    ),
  );

  // Services
  sl.registerLazySingleton(() => SessionTimeoutService());

  // External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => InternetConnectionChecker());
}