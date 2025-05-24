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
  final VoidCallback? onResponse;

  const EnhancedReportListItem({
    super.key,
    required this.report,
    required this.onTap,
    this.showActions = false,
    this.onStatusUpdate,
    this.onAssign,
    this.onResponse,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildDescription(),
              const SizedBox(height: 12),
              if (report.attachments.isNotEmpty) _buildMediaPreview(),
              _buildLocationInfo(),
              const SizedBox(height: 12),
              _buildFooter(),
              if (showActions) _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category icon
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _getCategoryColor().withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCategoryIcon(),
            color: _getCategoryColor(),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        
        // Title and metadata
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
                  _buildCategoryChip(),
                  const SizedBox(width: 8),
                  if (report.priority != Priority.low) _buildPriorityChip(),
                ],
              ),
            ],
          ),
        ),
        
        // Status badge
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      report.description,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade700,
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMediaPreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: report.attachments.length > 4 ? 4 : report.attachments.length,
        itemBuilder: (context, index) {
          if (index == 3 && report.attachments.length > 4) {
            return _buildMoreMediaIndicator();
          }
          return _buildMediaThumbnail(report.attachments[index]);
        },
      ),
    );
  }

  Widget _buildMediaThumbnail(MediaAttachment attachment) {
    return Container(
      width: 80,
      height: 80,
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
                  size: 32,
                ),
              ),
            
            // Type indicator
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  attachment.type == MediaType.image
                      ? Icons.image
                      : Icons.videocam,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreMediaIndicator() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          '+${report.attachments.length - 3}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Row(
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
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Date info
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
        
        // Response and assignment info
        Row(
          children: [
            if (report.responses.isNotEmpty) _buildResponseCount(),
            if (report.assignedToId != null) _buildAssignmentInfo(),
          ],
        ),
      ],
    );
  }

  Widget _buildResponseCount() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.forum, size: 12, color: Colors.blue),
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
    );
  }

  Widget _buildAssignmentInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_outline, size: 12, color: Colors.purple),
          const SizedBox(width: 4),
          Text(
            report.assignedToName ?? 'Asignado',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.edit,
            label: 'Estado',
            onPressed: onStatusUpdate,
          ),
          if (report.assignedToId == null)
            _buildActionButton(
              icon: Icons.person_add,
              label: 'Asignar',
              onPressed: onAssign,
            ),
          _buildActionButton(
            icon: Icons.reply,
            label: 'Responder',
            onPressed: onResponse,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: onPressed != null ? AppTheme.primaryColor : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: onPressed != null ? AppTheme.primaryColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final color = _getStatusColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        report.status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        report.category,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPriorityChip() {
    final color = _getPriorityColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getPriorityIcon(), size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            report.priority.displayName,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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
        return Icons.keyboard_arrow_down;
      case Priority.medium:
        return Icons.remove;
      case Priority.high:
        return Icons.keyboard_arrow_up;
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