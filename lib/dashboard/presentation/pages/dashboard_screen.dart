import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/services/session_timeout_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../di/injection_container.dart' as di;
import '../../../features/auth/domain/entities/user_entity.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../features/auth/presentation/bloc/auth_state.dart';
import '../widgets/dashboard_menu_item.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animationController.forward();

    // Inicializar servicio de timeout de sesión
    final sessionService = di.sl<SessionTimeoutService>();
    sessionService.onSessionTimeout = () {
      context.read<AuthBloc>().add(SignOutEvent());
    };
    sessionService.startTimer();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return _buildDashboard(state.user);
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildDashboard(UserEntity user) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FROGIO'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              _showLogoutConfirmationDialog();
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Actualizar timeout de sesión en actividad del usuario
          di.sl<SessionTimeoutService>().updateLastActivityTime();
        },
        child: _getPage(_currentIndex, user),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Actualizar timeout de sesión en navegación
          di.sl<SessionTimeoutService>().updateLastActivityTime();
        },
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: _getNavigationItemsForRole(user.role),
      ),
    );
  }

  List<BottomNavigationBarItem> _getNavigationItemsForRole(String role) {
    final List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard),
        label: 'Inicio',
      ),
    ];

    // Común para todos los roles
    items.add(const BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Perfil',
    ));

    // Ítems específicos por rol
    switch (role) {
      case 'citizen':
        items.insert(1, const BottomNavigationBarItem(
          icon: Icon(Icons.report),
          label: 'Denuncias',
        ));
        items.insert(2, const BottomNavigationBarItem(
          icon: Icon(Icons.question_answer),
          label: 'Consultas',
        ));
        break;
      case 'inspector':
        items.insert(1, const BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Tareas',
        ));
        items.insert(2, const BottomNavigationBarItem(
          icon: Icon(Icons.gavel),
          label: 'Infracciones',
        ));
        items.insert(3, const BottomNavigationBarItem(
          icon: Icon(Icons.directions_car),
          label: 'Vehículos',
        ));
        break;
      case 'admin':
        items.insert(1, const BottomNavigationBarItem(
          icon: Icon(Icons.insights),
          label: 'Estadísticas',
        ));
        items.insert(2, const BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Usuarios',
        ));
        items.insert(3, const BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Configuración',
        ));
        break;
    }

    return items;
  }

  Widget _getPage(int index, UserEntity user) {
    // Esto cambiaría según el rol del usuario y el índice seleccionado
    // Por ahora, solo devolvemos un marcador de posición
    if (index == 0) {
      return _buildHomeDashboard(user);
    } else {
      return Center(
        child: Text(
          'Página en desarrollo: $index',
          style: const TextStyle(fontSize: 20),
        ),
      );
    }
  }

  Widget _buildHomeDashboard(UserEntity user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta de bienvenida con animación
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(-1, 0),
                      end: const Offset(0, 0),
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeOut,
                    )),
                    child: Lottie.asset(
                      'assets/animations/welcome_frog.json',
                      width: 100,
                      height: 100,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡Hola, ${user.name ?? "Usuario"}!',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rol: ${_getRoleDisplayName(user.role)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Título de sección
          const Text(
            'Accesos Rápidos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Cuadrícula de acceso rápido
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: _getQuickAccessItemsForRole(user.role),
          ),
          const SizedBox(height: 24),
          // Sección de actividad reciente
          const Text(
            'Actividad Reciente',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Marcador de posición para actividad reciente
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No hay actividad reciente',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getQuickAccessItemsForRole(String role) {
    final List<Widget> items = [];

    switch (role) {
      case 'citizen':
        items.addAll([
          DashboardMenuItem(
            title: 'Nueva Denuncia',
            icon: Icons.add_circle,
            color: AppTheme.primaryColor,
            onTap: () {
              // Navegar a la pantalla de crear denuncia
            },
          ),
          DashboardMenuItem(
            title: 'Mis Denuncias',
            icon: Icons.list_alt,
            color: AppTheme.secondaryColor,
            onTap: () {
              // Navegar a la pantalla de mis denuncias
            },
          ),
          DashboardMenuItem(
            title: 'Nueva Consulta',
            icon: Icons.question_answer,
            color: AppTheme.darkGreen,
            onTap: () {
              // Navegar a la pantalla de crear consulta
            },
          ),
          DashboardMenuItem(
            title: 'Mis Consultas',
            icon: Icons.question_mark,
            color: Colors.teal,
            onTap: () {
              // Navegar a la pantalla de mis consultas
            },
          ),
        ]);
        break;
      case 'inspector':
        items.addAll([
          DashboardMenuItem(
            title: 'Tareas Pendientes',
            icon: Icons.assignment,
            color: AppTheme.primaryColor,
            onTap: () {},
          ),
          DashboardMenuItem(
            title: 'Nueva Infracción',
            icon: Icons.gavel,
            color: AppTheme.secondaryColor,
            onTap: () {},
          ),
          DashboardMenuItem(
            title: 'Registro Vehículo',
            icon: Icons.directions_car,
            color: AppTheme.darkGreen,
            onTap: () {},
          ),
          DashboardMenuItem(
            title: 'Mapa',
            icon: Icons.map,
            color: Colors.teal,
            onTap: () {},
          ),
        ]);
        break;
      case 'admin':
        items.addAll([
          DashboardMenuItem(
            title: 'Estadísticas',
            icon: Icons.bar_chart,
            color: AppTheme.primaryColor,
            onTap: () {},
          ),
          DashboardMenuItem(
            title: 'Usuarios',
            icon: Icons.people,
            color: AppTheme.secondaryColor,
            onTap: () {},
          ),
          DashboardMenuItem(
            title: 'Denuncias Pendientes',
            icon: Icons.report_problem,
            color: AppTheme.darkGreen,
            onTap: () {},
          ),
          DashboardMenuItem(
            title: 'Configuración',
            icon: Icons.settings,
            color: Colors.teal,
            onTap: () {},
          ),
        ]);
        break;
      default:
        // Ítems predeterminados si no se reconoce el rol
        items.addAll([
          DashboardMenuItem(
            title: 'Perfil',
            icon: Icons.person,
            color: AppTheme.primaryColor,
            onTap: () {},
          ),
          DashboardMenuItem(
            title: 'Configuración',
            icon: Icons.settings,
            color: AppTheme.secondaryColor,
            onTap: () {},
          ),
        ]);
    }

    return items;
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'citizen':
        return 'Ciudadano';
      case 'inspector':
        return 'Inspector';
      case 'admin':
        return 'Administrador';
      default:
        return role;
    }
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que deseas cerrar tu sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(SignOutEvent());
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}