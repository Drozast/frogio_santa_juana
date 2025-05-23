// lib/features/citizen/presentation/widgets/report_assignment_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../bloc/report/report_bloc.dart';
import '../bloc/report/report_event.dart';
import '../bloc/report/report_state.dart';

class ReportAssignmentWidget extends StatefulWidget {
  final String reportId;
  final String? currentAssignee;
  final VoidCallback? onAssigned;

  const ReportAssignmentWidget({
    Key? key,
    required this.reportId,
    this.currentAssignee,
    this.onAssigned,
  }) : super(key: key);

  @override
  State<ReportAssignmentWidget> createState() => _ReportAssignmentWidgetState();
}

class _ReportAssignmentWidgetState extends State<ReportAssignmentWidget> {
  String? _selectedInspector;
  final _noteController = TextEditingController();
  
  // Mock data - en implementación real vendría de un servicio
  final List<Inspector> _inspectors = [
    Inspector('1', 'Juan Pérez', 'Infraestructura', true, 3),
    Inspector('2', 'María González', 'Alumbrado', true, 1),
    Inspector('3', 'Carlos Silva', 'Áreas Verdes', false, 5),
    Inspector('4', 'Ana López', 'Seguridad', true, 2),
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportBloc, ReportState>(
      listener: (context, state) {
        if (state is ReportDetailLoaded) {
          Navigator.of(context).pop();
          widget.onAssigned?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reporte asignado exitosamente'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      },
      child: AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.person_add, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Asignar Inspector'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.currentAssignee != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Actualmente asignado a: ${widget.currentAssignee}',
                          style: TextStyle(color: Colors.orange.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Seleccionar inspector:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _inspectors.length,
                  itemBuilder: (context, index) {
                    return _buildInspectorTile(_inspectors[index]);
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Nota (opcional)',
                  hintText: 'Instrucciones especiales...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          BlocBuilder<ReportBloc, ReportState>(
            builder: (context, state) {
              return CustomButton(
                text: 'Asignar',
                isLoading: state is ReportLoading,
                onPressed: _selectedInspector == null ? null : _assignReport,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInspectorTile(Inspector inspector) {
    final isSelected = _selectedInspector == inspector.id;
    
    return ListTile(
      selected: isSelected,
      selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
      leading: CircleAvatar(
        backgroundColor: inspector.isAvailable 
            ? AppTheme.primaryColor 
            : Colors.grey,
        child: Text(
          inspector.name.substring(0, 1),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(inspector.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Especialidad: ${inspector.specialty}'),
          Row(
            children: [
              Icon(
                inspector.isAvailable ? Icons.check_circle : Icons.schedule,
                size: 14,
                color: inspector.isAvailable ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                inspector.isAvailable ? 'Disponible' : 'Ocupado',
                style: TextStyle(
                  color: inspector.isAvailable ? Colors.green : Colors.orange,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${inspector.activeReports} reportes activos',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      trailing: isSelected 
          ? const Icon(Icons.radio_button_checked, color: AppTheme.primaryColor)
          : const Icon(Icons.radio_button_unchecked),
      onTap: () {
        setState(() {
          _selectedInspector = inspector.id;
        });
      },
    );
  }

  void _assignReport() {
    if (_selectedInspector != null) {
      context.read<ReportBloc>().add(
        AssignReportEvent(
          reportId: widget.reportId,
          inspectorId: _selectedInspector!,
          note: _noteController.text.trim(),
        ),
      );
    }
  }
}

class Inspector {
  final String id;
  final String name;
  final String specialty;
  final bool isAvailable;
  final int activeReports;

  Inspector(this.id, this.name, this.specialty, this.isAvailable, this.activeReports);
}

// Agregar evento al report_event.dart
class AssignReportEvent extends ReportEvent {
  final String reportId;
  final String inspectorId;
  final String? note;
  
  const AssignReportEvent({
    required this.reportId,
    required this.inspectorId,
    this.note,
  });
  
  @override
  List<Object?> get props => [reportId, inspectorId, note];
}