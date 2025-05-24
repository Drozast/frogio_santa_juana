// lib/features/citizen/presentation/pages/report_detail_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../di/injection_container.dart' as di;
import '../bloc/report/report_bloc.dart';
import '../bloc/report/report_event.dart';
import '../bloc/report/report_state.dart';

class ReportDetailScreen extends StatefulWidget {
  final String reportId;

  const ReportDetailScreen({
    super.key,
    required this.reportId, String? currentUserRole,
  });

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  late ReportBloc _reportBloc;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _reportBloc = di.sl<ReportBloc>();
    _loadReportDetails();
  }

  void _loadReportDetails() {
    _reportBloc.add(LoadReportDetailsEvent(reportId: widget.reportId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _reportBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalle de Denuncia'),
        ),
        body: BlocBuilder<ReportBloc, ReportState>(
          builder: (context, state) {
            if (state is ReportLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ReportDetailLoaded) {
              // Añadir marcador para el mapa cuando cargue los detalles
              _markers.clear();
              _markers.add(
                Marker(
                  markerId: MarkerId(state.report.id),
                  position: LatLng(
                    state.report.location.latitude,
                    state.report.location.longitude,
                  ),
                  infoWindow: InfoWindow(
                    title: state.report.title,
                    snippet: state.report.location.address,
                  ),
                ),
              );
              
              return _buildReportDetail(state);
            } else if (state is ReportError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: AppTheme.errorColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
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
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Widget _buildReportDetail(ReportDetailLoaded state) {
    final report = state.report;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Galería de imágenes
          SizedBox(
            height: 200,
            child: PageView.builder(
              itemCount: report.imageUrls.length,
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: report.imageUrls[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.error),
                  ),
                );
              },
            ),
          ),
          
          // Contenido principal
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Estado y fecha
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusChip(report.status),
                    Text(
                      'Creada: ${DateFormat('dd/MM/yyyy').format(report.createdAt)}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Título
                Text(
                  report.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Categoría
                Row(
                  children: [
                    const Icon(
                      Icons.category,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Categoría: ${report.category}',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                
                // Ubicación
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        report.location.address ?? 'Ubicación no disponible',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Descripción
                const Text(
                  'Descripción',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(report.description),
                const SizedBox(height: 24),
                
                // Mapa
                const Text(
                  'Ubicación',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        report.location.latitude,
                        report.location.longitude,
                      ),
                      zoom: 15,
                    ),
                    markers: _markers,
                    mapType: MapType.normal,
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Historial
                const Text(
                  'Historial',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTimeline(report.historyLog),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    
    switch (status) {
      case 'Pendiente':
        color = Colors.orange;
        break;
      case 'En Proceso':
        color = Colors.blue;
        break;
      case 'Completada':
        color = AppTheme.successColor;
        break;
      case 'Rechazada':
        color = AppTheme.errorColor;
        break;
      default:
        color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTimeline(List<dynamic> historyLog) {
    return Column(
      children: List.generate(historyLog.length, (index) {
        final logItem = historyLog[index];
        final isFirst = index == 0;
        final isLast = index == historyLog.length - 1;
        
        return TimelineTile(
          alignment: TimelineAlign.start,
          isFirst: isFirst,
          isLast: isLast,
          indicatorStyle: IndicatorStyle(
            width: 20,
            color: AppTheme.primaryColor,
            iconStyle: IconStyle(
              color: Colors.white,
              iconData: _getStatusIcon(logItem.status),
            ),
          ),
          endChild: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      logItem.status,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(logItem.timestamp),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (logItem.comment != null) ...[
                  const SizedBox(height: 8),
                  Text(logItem.comment!),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Enviada':
        return Icons.send;
      case 'Revisada':
        return Icons.visibility;
      case 'En Proceso':
        return Icons.build;
      case 'Completada':
        return Icons.check_circle;
      case 'Rechazada':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}