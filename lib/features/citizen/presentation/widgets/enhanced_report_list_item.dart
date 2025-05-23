// lib/features/citizen/presentation/widgets/enhanced_report_list_item.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/enhanced_report_entity.dart';

class EnhancedReportListItem extends StatelessWidget {
  final ReportEntity report;
  final VoidCallback onTap;
  final bool showActions;
  final VoidCallback? onStatusUpdate;
  final VoidCallback? onAssign;

  const EnhancedReportListItem({
    Key? key,
    required this.report,
    required this.onTap,
    this.showActions = false,
    this.onStatusUpdate,
    this.onAssign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getCategoryColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(),
                      color: _getCategoryColor(),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Title and category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.category,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              report.category,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Status badge and priority
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildStatusBadge(),
                      const SizedBox(height: 4),
                      _buildPriorityBadge(),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Description
              Text(
                report.description,
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // Media preview (if exists)
              if (report.attachments.isNotEmpty) _buildMediaPreview(),
              
              // Location
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _getLocationDisplay(),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Bottom row with date and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date and responses count
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Creada: ${DateFormat('dd/MM/yyyy').format(report.createdAt)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (report.updatedAt != report.createdAt)
                        Text(
                          'Actualizada: ${_timeAgo(report.updatedAt)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                  
                  // Response count and actions
                  Row(
                    children: [
                      if (report.responses.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.forum,
                                size: 12,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${report.responses.length}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      
                      // Action buttons for admins/inspectors
                      if (showActions) _buildActionButtons(),
                    ],
                  ),
                ],
              ),
              
              // Assigned to (if applicable)
              if (report.assignedToId != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 14,
                        color: Colors.purple,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Asignado a: ${report.assignedToId}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.purple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final color = _getStatusColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        report.status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPriorityBadge() {
    if (report.priority == Priority.low) return const SizedBox.shrink();
    
    final color = _getPriorityColor();
    final icon = _getPriorityIcon();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 2),
          Text(
            report.priority.displayName,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview() {
    final visibleAttachments = report.attachments.take(3).toList();
    final remainingCount = report.attachments.length - 3;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 60,
      child: Row(
        children: [
          ...visibleAttachments.map((attachment) => Container(
            width: 60,
            height: 60,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (attachment.type == MediaType.image)
                    CachedNetworkImage(
                      imageUrl: attachment.url,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    )
                  else
                    Container(
                      color: Colors.black87,
                      child: const Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  
                  // Type indicator
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                      child: Icon(
                        attachment.type == MediaType.image
                            ? Icons.image
                            : Icons.videocam,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )).toList(),
          
          // Show remaining count if any
          if (remainingCount > 0)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Text(
                  '+$remainingCount',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, size: 18),
          onPressed: onStatusUpdate,
          tooltip: 'Actualizar estado',
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
        ),
        if (report.assignedToId == null)
          IconButton(
            icon: const Icon(Icons.person_add, size: 18),
            onPressed: onAssign,
            tooltip: 'Asignar',
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
      ],
    );
  }

  // Helper methods for colors and icons
  
  Color _getStatusColor() {
    switch (report.status) {
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

  Color _getPriorityColor() {
    switch (report.priority) {
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

  IconData _getPriorityIcon() {
    switch (report.priority) {
      case Priority.low:
        return Icons.arrow_downward;
      case Priority.medium:
        return Icons.remove;
      case Priority.high:
        return Icons.arrow_upward;
      case Priority.urgent:
        return Icons.priority_high;
    }
  }

  Color _getCategoryColor() {
    switch (report.category) {
      case 'Alumbrado Público':
        return Colors.amber;
      case 'Basura y Limpieza':
        return Colors.brown;
      case 'Calles y Veredas':
        return Colors.grey;
      case 'Seguridad Pública':
        return Colors.red;
      case 'Áreas Verdes':
        return AppTheme.primaryColor;
      case 'Tránsito':
        return Colors.blue;
      case 'Ruido':
        return Colors.orange;
      case 'Animales':
        return Colors.green;
      case 'Infraestructura':
        return Colors.indigo;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getCategoryIcon() {
    switch (report.category) {
      case 'Alumbrado Público':
        return Icons.lightbulb;
      case 'Basura y Limpieza':
        return Icons.delete;
      case 'Calles y Veredas':
        return Icons.directions_walk;
      case 'Seguridad Pública':
        return Icons.security;
      case 'Áreas Verdes':
        return Icons.park;
      case 'Tránsito':
        return Icons.traffic;
      case 'Ruido':
        return Icons.volume_up;
      case 'Animales':
        return Icons.pets;
      case 'Infraestructura':
        return Icons.engineering;
      default:
        return Icons.help;
    }
  }

  String _getLocationDisplay() {
    final location = report.location;
    
    if (location.address != null && location.address!.isNotEmpty) {
      return location.address!;
    } else if (location.manualAddress != null && location.manualAddress!.isNotEmpty) {
      return location.manualAddress!;
    } else if (location.latitude != 0 && location.longitude != 0) {
      return 'Coordenadas: ${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
    } else {
      return 'Ubicación no disponible';
    }
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return 'hace ${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes}m';
    } else {
      return 'ahora';
    }
  }
}