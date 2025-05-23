// lib/core/services/notification_manager.dart
import 'dart:developer';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'notification_service.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final NotificationService _notificationService = NotificationService();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> initialize() async {
    await _notificationService.initialize();
    _setupCallbacks();
  }

  void _setupCallbacks() {
    _notificationService.onNotificationReceived = _handleNotificationReceived;
    _notificationService.onNotificationTapped = _handleNotificationTapped;
  }

  void _handleNotificationReceived(Map<String, dynamic> data) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      _showInAppNotification(context, data);
    }
  }

  void _handleNotificationTapped(Map<String, dynamic> data) {
    log('Notification tapped: $data');
    _navigateBasedOnNotification(data);
  }

  void _showInAppNotification(BuildContext context, Map<String, dynamic> data) {
    final notificationType = data['type'] ?? 'general';
    final title = data['title'] ?? 'FROGIO';
    final body = data['body'] ?? 'Nueva notificación';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getNotificationIcon(notificationType),
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    body,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: _getNotificationColor(notificationType),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Ver',
          textColor: Colors.white,
          onPressed: () => _navigateBasedOnNotification(data),
        ),
      ),
    );
  }

  void _navigateBasedOnNotification(Map<String, dynamic> data) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final type = data['type'];
    final reportId = data['reportId'];
    final screen = data['screen'];

    switch (type) {
      case 'report_status_changed':
        _navigateToReportDetail(context, reportId);
        break;
      case 'report_response':
        _navigateToReportDetail(context, reportId);
        break;
      case 'report_assigned':
        _navigateToReportDetail(context, reportId);
        break;
      case 'new_report':
        _navigateToReportsList(context);
        break;
      case 'reminder':
        _handleReminder(context, data);
        break;
      default:
        if (screen != null) {
          _navigateToScreen(context, screen);
        }
    }
  }

  void _navigateToReportDetail(BuildContext context, String? reportId) {
    if (reportId != null) {
      Navigator.of(context).pushNamed('/report-detail', arguments: reportId);
    }
  }

  void _navigateToReportsList(BuildContext context) {
    Navigator.of(context).pushNamed('/reports');
  }

  void _navigateToScreen(BuildContext context, String screen) {
    Navigator.of(context).pushNamed(screen);
  }

  void _handleReminder(BuildContext context, Map<String, dynamic> data) {
    final reminderType = data['reminderType'];
    
    switch (reminderType) {
      case 'incomplete_profile':
        Navigator.of(context).pushNamed('/profile');
        break;
      case 'pending_reports':
        Navigator.of(context).pushNamed('/reports');
        break;
      default:
        Navigator.of(context).pushNamed('/dashboard');
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'report_status_changed':
        return Icons.update;
      case 'report_response':
        return Icons.reply;
      case 'report_assigned':
        return Icons.person_add;
      case 'new_report':
        return Icons.report;
      case 'reminder':
        return Icons.schedule;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'report_status_changed':
        return Colors.blue;
      case 'report_response':
        return AppTheme.primaryColor;
      case 'report_assigned':
        return Colors.purple;
      case 'new_report':
        return Colors.orange;
      case 'reminder':
        return Colors.amber;
      default:
        return AppTheme.primaryColor;
    }
  }

  // Métodos para suscripciones basadas en roles
  Future<void> subscribeToUserTopics(String userId, String role) async {
    // Suscribirse a notificaciones generales
    await _notificationService.subscribeToTopic('all_users');
    
    // Suscribirse según rol
    switch (role) {
      case 'citizen':
        await _notificationService.subscribeToTopic('citizens');
        await _notificationService.subscribeToTopic('user_$userId');
        break;
      case 'inspector':
        await _notificationService.subscribeToTopic('inspectors');
        await _notificationService.subscribeToTopic('staff');
        break;
      case 'admin':
        await _notificationService.subscribeToTopic('admins');
        await _notificationService.subscribeToTopic('staff');
        break;
    }
    
    // Enviar token al servidor
    await _notificationService.sendTokenToServer(userId, role);
  }

  Future<void> unsubscribeFromAllTopics(String userId, String role) async {
    await _notificationService.unsubscribeFromTopic('all_users');
    await _notificationService.unsubscribeFromTopic('citizens');
    await _notificationService.unsubscribeFromTopic('inspectors');
    await _notificationService.unsubscribeFromTopic('admins');
    await _notificationService.unsubscribeFromTopic('staff');
    await _notificationService.unsubscribeFromTopic('user_$userId');
    await _notificationService.clearToken();
  }

  // Mostrar notificaciones locales para acciones de la app
  Future<void> showReportStatusUpdate(String reportId, String newStatus) async {
    await _notificationService.showCustomNotification(
      title: 'Estado actualizado',
      body: 'Tu denuncia cambió a: $newStatus',
      data: {
        'type': 'report_status_changed',
        'reportId': reportId,
      },
    );
  }

  Future<void> showNewResponse(String reportId, String responderName) async {
    await _notificationService.showCustomNotification(
      title: 'Nueva respuesta',
      body: '$responderName respondió a tu denuncia',
      data: {
        'type': 'report_response',
        'reportId': reportId,
      },
    );
  }

  Future<void> showReportAssigned(String reportId, String inspectorName) async {
    await _notificationService.showCustomNotification(
      title: 'Reporte asignado',
      body: 'Asignado a $inspectorName',
      data: {
        'type': 'report_assigned',
        'reportId': reportId,
      },
    );
  }

  Future<void> showReminder(String title, String message, String type) async {
    await _notificationService.showCustomNotification(
      title: title,
      body: message,
      data: {
        'type': 'reminder',
        'reminderType': type,
      },
    );
  }
}