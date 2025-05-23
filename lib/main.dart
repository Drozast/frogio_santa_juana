// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/blocs/notification/notification_bloc.dart';
import 'core/services/notification_manager.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'di/injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/pages/splash_screen.dart';
import 'firebase_options.dart';

// Handler para mensajes en background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Configurar handler de background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Inicializar servicios
  await di.init();
  await NotificationManager().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatusEvent()),
        ),
        BlocProvider(
          create: (_) => NotificationBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'FROGIO',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        navigatorKey: NotificationManager().navigatorKey,
        home: const SplashScreen(),
        routes: {
          '/notifications': (context) => const NotificationsScreen(),
          '/reports': (context) => const MyReportsScreen(userId: ''),
          '/profile': (context) => const EditProfileScreen(),
          '/dashboard': (context) => const DashboardScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/report-detail') {
            final reportId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => EnhancedReportDetailScreen(reportId: reportId),
            );
          }
          return null;
        },
      ),
    );
  }
}