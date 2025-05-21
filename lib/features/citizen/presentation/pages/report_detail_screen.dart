import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/report_entity.dart';

class ReportDetailScreen extends StatefulWidget {
  final String reportId;

  const ReportDetailScreen({
    Key? key,
    required this.reportId,
  }) : super(key: key);

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  bool _isLoading = true;
  late ReportEntity _report;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadReportDetails();
  }

  Future<void> _loadReportDetails() async {
    // Simular carga de datos
    await Future.delayed(const Duration(seconds: 1));
    
    // En una implementación real, aquí se cargarían los datos de Firestore
    _report = _getMockReport(widget.reportId);
    
    // Añadir marcador para el mapa
    _markers.add(
      Marker(
        markerId: MarkerId(_report.id),
        position: LatLng(
          _report.location.latitude,
          _report.location.longitude,
        ),
        infoWindow: InfoWindow(
          title: _report.title,
          snippet: _report.location.address,
        ),
      ),
    );
    
    setState(() {
      _isLoading = false;
    });
  }

  ReportEntity _getMockReport(String id) {
    // Datos de ejemplo basados en el ID
    return ReportEntity(
      id: id,
      title: 'Luminaria dañada en Calle Principal',
      description: 'La luminaria está completamente apagada desde hace una semana. Esto ha causado problemas de seguridad en la zona durante la noche. Es urgente su reparación.',
      category: 'Alumbrado Público',
      location: const LocationData(
        latitude: -37.0415,
        longitude: -73.1586,
        address: 'Calle Principal 123, Coronel',
      ),
      citizenId: 'user123',
      muniId: 'muni1',
      status: 'En Proceso',
      imageUrls: [
        'https://via.placeholder.com/400x300',
        'https://via.placeholder.com/400x300',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      historyLog: [
        HistoryLogItem(
          timestamp: DateTime.now().subtract(const Duration(days: 5)),
          status: 'Enviada',
          userId: 'user123',
        ),
        HistoryLogItem(
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          status: 'Revisada',
          comment: 'Se ha validado la denuncia',
          userId: 'admin1',
        ),
        HistoryLogItem(
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          status: 'En Proceso',
          comment: 'Se ha asignado a un técnico que visitará el lugar en los próximos días',
          userId: 'admin1',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Denuncia'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Galería de imágenes
                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      itemCount: _report.imageUrls.length,
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                          imageUrl: _report.imageUrls[index],
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
                            _buildStatusChip(_report.status),
                            Text(
                              'Creada: ${DateFormat('dd/MM/yyyy').format(_report.createdAt)}',
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
                          _report.title,
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
                              'Categoría: ${_report.category}',
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
                                _report.location.address ?? 'Ubicación no disponible',
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
                        Text(_report.description),
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
                                _report.location.latitude,
                                _report.location.longitude,
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
                        _buildTimeline(),
                      ],
                    ),
                  ),
                ],
              ),
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
        color: color.withOpacity(0.2),
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

  Widget _buildTimeline() {
    return Column(
      children: List.generate(_report.historyLog.length, (index) {
        final logItem = _report.historyLog[index];
        final isFirst = index == 0;
        final isLast = index == _report.historyLog.length - 1;
        
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