import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/session_timeout_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../di/injection_container.dart' as di;
import '../../../features/auth/domain/entities/user_entity.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../features/citizen/presentation/pages/create_report_screen.dart';
import '../../../features/citizen/presentation/pages/my_reports_screen.dart';
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
      if (mounted) {
        context.read<AuthBloc>().add(SignOutEvent());
      }
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

    // Ítems específicos por rol
    switch (role) {
      case 'citizen':
        items.add(const BottomNavigationBarItem(
          icon: Icon(Icons.report),
          label: 'Denuncias',
        ));
        items.add(const BottomNavigationBarItem(
          icon: Icon(Icons.question_answer),
          label: 'Consultas',
        ));
        break;
      case 'inspector':
        items.add(const BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Tareas',
        ));
        items.add(const BottomNavigationBarItem(
          icon: Icon(Icons.gavel),
          label: 'Infracciones',
        ));
        items.add(const BottomNavigationBarItem(
          icon: Icon(Icons.directions_car),
          label: 'Vehículos',
        ));
        break;
      case 'admin':
        items.add(const BottomNavigationBarItem(
          icon: Icon(Icons.insights),
          label: 'Estadísticas',
        ));
        items.add(const BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Usuarios',
        ));
        items.add(const BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Configuración',
        ));
        break;
    }

    // Común para todos los roles
    items.add(const BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Perfil',
    ));

    return items;
  }

  Widget _getPage(int index, UserEntity user) {
    switch (user.role) {
      case 'citizen':
        switch (index) {
          case 0:
            return _buildHomeDashboard(user);
          case 1:
            return MyReportsScreen(userId: user.id);
          case 2:
            return const Center(
              child: Text(
                'Consultas - En desarrollo',
                style: TextStyle(fontSize: 20),
              ),
            );
          case 3:
            return _buildProfilePage(user);
          default:
            return _buildHomeDashboard(user);
        }
      default:
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
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.eco,
                        size: 50,
                        color: AppTheme.primaryColor,
                      ),
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
            children: _getQuickAccessItemsForRole(user),
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

  Widget _buildProfilePage(UserEntity user) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información Personal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProfileRow('Nombre', user.name ?? 'No especificado'),
                  _buildProfileRow('Email', user.email),
                  _buildProfileRow('Rol', _getRoleDisplayName(user.role)),
                  _buildProfileRow('ID Usuario', user.id),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  List<Widget> _getQuickAccessItemsForRole(UserEntity user) {
    final List<Widget> items = [];

    switch (user.role) {
      case 'citizen':
        items.addAll([
          DashboardMenuItem(
            title: 'Nueva Denuncia',
            icon: Icons.add_circle,
            color: AppTheme.primaryColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateReportScreen(userId: user.id),
                ),
              );
            },
          ),
          DashboardMenuItem(
            title: 'Mis Denuncias',
            icon: Icons.list_alt,
            color: AppTheme.secondaryColor,
            onTap: () {
              setState(() {
                _currentIndex = 1;
              });
            },
          ),
          DashboardMenuItem(
            title: 'Nueva Consulta',
            icon: Icons.question_answer,
            color: AppTheme.darkGreen,
            onTap: () {
              // TODO: Navegar a crear consulta
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidad en desarrollo'),
                ),
              );
            },
          ),
          DashboardMenuItem(
            title: 'Mis Consultas',
            icon: Icons.question_mark,
            color: Colors.teal,
            onTap: () {
              setState(() {
                _currentIndex = 2;
              });
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
        items.addAll([
          DashboardMenuItem(
            title: 'Perfil',
            icon: Icons.person,
            color: AppTheme.primaryColor,
            onTap: () {
              setState(() {
                _currentIndex = _getNavigationItemsForRole(user.role).length - 1;
              });
            },
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