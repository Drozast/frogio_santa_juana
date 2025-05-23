// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/blocs/notification/notification_bloc.dart';
import 'core/presentation/pages/notifications_screen.dart';
import 'core/services/notification_manager.dart';
import 'core/theme/app_theme.dart';
import 'dashboard/presentation/pages/dashboard_screen.dart';
import 'di/injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/edit_profile_screen.dart';
import 'features/auth/presentation/pages/splash_screen.dart';
import 'features/citizen/presentation/pages/enhanced_my_reports_screen.dart';
import 'features/citizen/presentation/pages/enhanced_report_detail_screen.dart';
import 'firebase_options.dart';

// Handler para mensajes en background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message: ${message.notification?.title}');
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
        onGenerateRoute: (settings) {
          // Manejo dinámico de rutas con parámetros
          switch (settings.name) {
            case '/notifications':
              return MaterialPageRoute(
                builder: (_) => const NotificationsScreen(),
              );
              
            case '/reports':
              final userId = settings.arguments as String? ?? '';
              return MaterialPageRoute(
                builder: (_) => MyReportsScreen(userId: userId),
              );
              
            case '/profile':
              // Obtener el usuario actual del AuthBloc
              return MaterialPageRoute(
                builder: (context) => BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is Authenticated) {
                      return EditProfileScreen(user: state.user);
                    } else {
                      // Redirigir al login si no está autenticado
                      return const SplashScreen();
                    }
                  },
                ),
              );
              
            case '/dashboard':
              return MaterialPageRoute(
                builder: (_) => const DashboardScreen(),
              );
              
            case '/report-detail':
              final args = settings.arguments as Map<String, dynamic>?;
              final reportId = args?['reportId'] as String? ?? '';
              final userRole = args?['userRole'] as String?;
              return MaterialPageRoute(
                builder: (_) => EnhancedReportDetailScreen(
                  reportId: reportId,
                  currentUserRole: userRole,
                ),
              );
              
            default:
              // Ruta no encontrada
              return MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text('Página no encontrada')),
                  body: const Center(
                    child: Text('La página solicitada no existe'),
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}