// lib/features/citizen/presentation/pages/enhanced_report_detail_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../di/injection_container.dart' as di;
import '../../domain/entities/enhanced_report_entity.dart';
import '../bloc/report/enhanced_report_bloc.dart';
import '../bloc/report/enhanced_report_event.dart';
import '../bloc/report/enhanced_report_state.dart';
import '../widgets/response_input_widget.dart';
import '../widgets/status_update_widget.dart';

class ReportDetailScreen extends StatefulWidget {
  final String reportId;
  final String? currentUserRole;

  const ReportDetailScreen({
    super.key,
    required this.reportId,
    this.currentUserRole,
  });

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen>
    with SingleTickerProviderStateMixin {
  late ReportBloc _reportBloc;
  late TabController _tabController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _reportBloc = di.sl<ReportBloc>();
    _tabController = TabController(length: 3, vsync: this);
    _loadReportDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadReportDetails() {
    _reportBloc.add(LoadReportDetailsEvent(reportId: widget.reportId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _reportBloc,
      child: BlocListener<ReportBloc, ReportState>(
        listener: (context, state) {
          if (state is ReportStatusUpdated) {
            _showSuccessSnackBar('Estado actualizado: ${state.newStatus.displayName}');
            _loadReportDetails(); // Recargar datos
          } else if (state is ResponseAdded) {
            _showSuccessSnackBar('Respuesta agregada exitosamente');
            _loadReportDetails(); // Recargar datos
          } else if (state is ReportError) {
            _showErrorSnackBar(state.message);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Detalle de Denuncia'),
            actions: [
              BlocBuilder<ReportBloc, ReportState>(
                builder: (context, state) {
                  if (state is ReportDetailLoaded) {
                    return PopupMenuButton<String>(
                      onSelected: (value) => _handleMenuAction(value, state.report),
                      itemBuilder: (context) => [
                        if (_canUpdateStatus())
                          const PopupMenuItem(
                            value: 'update_status',
                            child: Row(
                              children: [
                                Icon(Icons.update),
                                SizedBox(width: 8),
                                Text('Actualizar Estado'),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'share',
                          child: Row(
                            children: [
                              Icon(Icons.share),
                              SizedBox(width: 8),
                              Text('Compartir'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'refresh',
                          child: Row(
                            children: [
                              Icon(Icons.refresh),
                              SizedBox(width: 8),
                              Text('Actualizar'),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          body: BlocBuilder<ReportBloc, ReportState>(
            builder: (context, state) {
              if (state is ReportLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ReportDetailLoaded) {
                return _buildReportDetail(state.report);
              } else if (state is ReportError) {
                return _buildErrorState(state.message);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildReportDetail(ReportEntity report) {
    // Preparar marcador del mapa
    if (report.location.latitude != 0 && report.location.longitude != 0) {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId(report.id),
          position: LatLng(
            report.location.latitude,
            report.location.longitude,
          ),
          infoWindow: InfoWindow(
            title: report.title,
            snippet: report.location.address,
          ),
        ),
      );
    }

    return Column(
      children: [
        // Header con información básica
        _buildReportHeader(report),
        
        // Tabs
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'Detalles'),
            Tab(icon: Icon(Icons.forum), text: 'Respuestas'),
            Tab(icon: Icon(Icons.history), text: 'Historial'),
          ],
        ),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDetailsTab(report),
              _buildResponsesTab(report),
              _buildHistoryTab(report),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportHeader(ReportEntity report) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  report.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildStatusBadge(report.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.category,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                report.category,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.priority_high,
                size: 16,
                color: _getPriorityColor(report.priority),
              ),
              const SizedBox(width: 4),
              Text(
                report.priority.displayName,
                style: TextStyle(color: _getPriorityColor(report.priority)),
              ),
              const Spacer(),
              Text(
                'ID: ${report.id.substring(0, 8)}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                'Creada: ${DateFormat('dd/MM/yyyy HH:mm').format(report.createdAt)}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(ReportEntity report) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Descripción
          _buildSection(
            'Descripción',
            Icons.description,
            Text(report.description),
          ),
          
          // Referencias (si existen)
          if (report.references != null && report.references!.isNotEmpty)
            _buildSection(
              'Referencias',
              Icons.place,
              Text(report.references!),
            ),
          
          // Multimedia
          if (report.attachments.isNotEmpty)
            _buildSection(
              'Evidencia Multimedia',
              Icons.photo_library,
              _buildMediaGallery(report.attachments),
            ),
          
          // Ubicación
          _buildSection(
            'Ubicación',
            Icons.location_on,
            _buildLocationSection(report),
          ),
          
          // Información adicional
          _buildSection(
            'Información Adicional',
            Icons.info,
            Column(
              children: [
                _buildInfoRow('Prioridad', report.priority.displayName),
                _buildInfoRow('Categoría', report.category),
                _buildInfoRow('Estado', report.status.displayName),
                if (report.assignedToId != null)
                  _buildInfoRow('Asignado a', report.assignedToId!),
                _buildInfoRow(
                  'Última actualización',
                  DateFormat('dd/MM/yyyy HH:mm').format(report.updatedAt),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsesTab(ReportEntity report) {
    return Column(
      children: [
        // Lista de respuestas
        Expanded(
          child: report.responses.isEmpty
              ? _buildEmptyResponses()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: report.responses.length,
                  itemBuilder: (context, index) {
                    return _buildResponseCard(report.responses[index]);
                  },
                ),
        ),
        
        // Widget para agregar respuesta (solo para inspectores/admin)
        if (_canRespond())
          ResponseInputWidget(
            reportId: report.id,
            onResponseAdded: () => _loadReportDetails(),
          ),
      ],
    );
  }

  Widget _buildHistoryTab(ReportEntity report) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: report.statusHistory.length,
      itemBuilder: (context, index) {
        final historyItem = report.statusHistory[index];
        final isFirst = index == 0;
        final isLast = index == report.statusHistory.length - 1;
        
        return TimelineTile(
          alignment: TimelineAlign.start,
          isFirst: isFirst,
          isLast: isLast,
          indicatorStyle: IndicatorStyle(
            width: 24,
            height: 24,
            indicator: Container(
              decoration: BoxDecoration(
                color: _getStatusColor(historyItem.status),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(historyItem.status),
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
          endChild: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      historyItem.status.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(historyItem.status),
                      ),
                    ),
                    Text(
                      DateFormat('dd/MM HH:mm').format(historyItem.timestamp),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (historyItem.userName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Por: ${historyItem.userName}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (historyItem.comment != null) ...[
                  const SizedBox(height: 8),
                  Text(historyItem.comment!),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildMediaGallery(List<MediaAttachment> attachments) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: attachments.length,
        itemBuilder: (context, index) {
          final attachment = attachments[index];
          return GestureDetector(
            onTap: () => _openMediaViewer(attachments, index),
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (attachment.type == MediaType.image)
                      CachedNetworkImage(
                        imageUrl: attachment.url,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      )
                    else
                      Container(
                        color: Colors.black,
                        child: const Icon(
                          Icons.play_circle_outline,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    
                    // Overlay con tipo de archivo
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          attachment.type == MediaType.image
                              ? Icons.image
                              : Icons.videocam,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationSection(ReportEntity report) {
    final location = report.location;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dirección
        if (location.address != null)
          Text(location.address!)
        else if (location.manualAddress != null)
          Text(location.manualAddress!)
        else
          const Text('Dirección no disponible'),
        
        const SizedBox(height: 8),
        
        // Coordenadas
        if (location.latitude != 0 && location.longitude != 0) ...[
          Text(
            'Coordenadas: ${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          
          // Mapa
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            clipBehavior: Clip.antiAlias,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(location.latitude, location.longitude),
                zoom: 15,
              ),
              markers: _markers,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              scrollGesturesEnabled: false,
              zoomGesturesEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildResponseCard(ReportResponse response) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    response.responderName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        response.responderName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(response.createdAt),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!response.isPublic)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Privado',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(response.message),
            
            // Attachments de la respuesta
            if (response.attachments.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildMediaGallery(response.attachments),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyResponses() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.forum_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Sin respuestas aún',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Las respuestas del municipio aparecerán aquí',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Error: $message',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadReportDetails,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ReportStatus status) {
    final color = _getStatusColor(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // Métodos auxiliares

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.draft:
        return Colors.grey;
      case ReportStatus.submitted:
        return Colors.blue;
      case ReportStatus.reviewing:
        return Colors.orange;
      case ReportStatus.inProgress:
        return Colors.purple;
      case ReportStatus.resolved:
        return AppTheme.successColor;
      case ReportStatus.rejected:
        return AppTheme.errorColor;
      case ReportStatus.archived:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
      case Priority.urgent:
        return Colors.purple;
    }
  }

  IconData _getStatusIcon(ReportStatus status) {
    switch (status) {
      case ReportStatus.draft:
        return Icons.edit;
      case ReportStatus.submitted:
        return Icons.send;
      case ReportStatus.reviewing:
        return Icons.visibility;
      case ReportStatus.inProgress:
        return Icons.build;
      case ReportStatus.resolved:
        return Icons.check_circle;
      case ReportStatus.rejected:
        return Icons.cancel;
      case ReportStatus.archived:
        return Icons.archive;
    }
  }

  bool _canUpdateStatus() {
    return widget.currentUserRole == 'inspector' || 
           widget.currentUserRole == 'admin';
  }

  bool _canRespond() {
    return widget.currentUserRole == 'inspector' || 
           widget.currentUserRole == 'admin';
  }

  void _handleMenuAction(String action, ReportEntity report) {
    switch (action) {
      case 'update_status':
        _showStatusUpdateDialog(report);
        break;
      case 'share':
        _shareReport(report);
        break;
      case 'refresh':
        _loadReportDetails();
        break;
    }
  }

  void _showStatusUpdateDialog(ReportEntity report) {
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: _reportBloc,
        child: StatusUpdateWidget(
          report: report,
          onStatusUpdated: () => _loadReportDetails(),
        ),
      ),
    );
  }

  void _shareReport(ReportEntity report) {
    // Implementar funcionalidad de compartir
    // Por ejemplo, copiar enlace al portapapeles
  }

  void _openMediaViewer(List<MediaAttachment> attachments, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MediaViewerScreen(
          attachments: attachments,
          initialIndex: initialIndex,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }
}

// Screen para visualizar multimedia en pantalla completa
class MediaViewerScreen extends StatelessWidget {
  final List<MediaAttachment> attachments;
  final int initialIndex;

  const MediaViewerScreen({
    Key? key,
    required this.attachments,
    required this.initialIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${initialIndex + 1} de ${attachments.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PhotoViewGallery.builder(
        itemCount: attachments.length,
        pageController: PageController(initialPage: initialIndex),
        builder: (context, index) {
          final attachment = attachments[index];
          
          if (attachment.type == MediaType.image) {
            return PhotoViewGalleryPageOptions(
              imageProvider: CachedNetworkImageProvider(attachment.url),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            );
          } else {
            // Para videos, mostrar placeholder
            return PhotoViewGalleryPageOptions.customChild(
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.videocam,
                      color: Colors.white,
                      size: 64,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Video no disponible en vista previa',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          }
        },
        scrollPhysics: const BouncingScrollPhysics(),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      ),
    );
  }
}