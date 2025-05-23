// lib/features/citizen/presentation/widgets/response_input_widget.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../domain/entities/enhanced_report_entity.dart';
import '../bloc/report/enhanced_report_bloc.dart';
import '../bloc/report/enhanced_report_event.dart';
import '../bloc/report/enhanced_report_state.dart';

class ResponseInputWidget extends StatefulWidget {
  final String reportId;
  final VoidCallback? onResponseAdded;

  const ResponseInputWidget({
    Key? key,
    required this.reportId,
    this.onResponseAdded,
  }) : super(key: key);

  @override
  State<ResponseInputWidget> createState() => _ResponseInputWidgetState();
}

class _ResponseInputWidgetState extends State<ResponseInputWidget> {
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  List<File> _attachments = [];
  bool _isPublic = true;
  bool _isExpanded = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportBloc, ReportState>(
      listener: (context, state) {
        if (state is ResponseAdded) {
          _clearForm();
          widget.onResponseAdded?.call();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.reply,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Responder denuncia',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      _isExpanded 
                          ? Icons.keyboard_arrow_down 
                          : Icons.keyboard_arrow_up,
                    ),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                  ),
                ],
              ),
              
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                
                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message input
                      TextFormField(
                        controller: _messageController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Escribe tu respuesta...',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El mensaje es requerido';
                          }
                          if (value.trim().length < 10) {
                            return 'El mensaje debe tener al menos 10 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Attachments
                      if (_attachments.isNotEmpty) ...[
                        const Text(
                          'Archivos adjuntos:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(_attachments.length, (index) {
                            return _buildAttachmentChip(index);
                          }),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Action buttons
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Cámara'),
                          ),
                          TextButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Galería'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Privacy toggle
                      Row(
                        children: [
                          Switch(
                            value: _isPublic,
                            onChanged: (value) {
                              setState(() {
                                _isPublic = value;
                              });
                            },
                            activeColor: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isPublic ? 'Respuesta pública' : 'Respuesta privada',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _isPublic
                                      ? 'Visible para el ciudadano'
                                      : 'Solo visible para el equipo municipal',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: BlocBuilder<ReportBloc, ReportState>(
                          builder: (context, state) {
                            return CustomButton(
                              text: 'Enviar Respuesta',
                              isLoading: state is ResponseAdding,
                              onPressed: state is ResponseAdding 
                                  ? null 
                                  : _submitResponse,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Collapsed view
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = true;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Text(
                      'Toca para responder esta denuncia...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentChip(int index) {
    final file = _attachments[index];
    final fileName = file.path.split('/').last;
    
    return Chip(
      label: Text(
        fileName.length > 20 
            ? '${fileName.substring(0, 20)}...' 
            : fileName,
        style: const TextStyle(fontSize: 12),
      ),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () {
        setState(() {
          _attachments.removeAt(index);
        });
      },
      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _attachments.add(File(image.path));
        });
      }
    } catch (e) {
      _showError('Error al seleccionar imagen: ${e.toString()}');
    }
  }

  void _submitResponse() {
    if (_formKey.currentState!.validate()) {
      // Obtener información del usuario actual
      // En una implementación real, esto vendría del AuthBloc
      const currentUserId = 'current_user_id';
      const currentUserName = 'Inspector/Admin';
      
      context.read<ReportBloc>().add(
        AddReportResponseEvent(
          reportId: widget.reportId,
          responderId: currentUserId,
          responderName: currentUserName,
          message: _messageController.text.trim(),
          attachments: _attachments.isEmpty ? null : _attachments,
          isPublic: _isPublic,
        ),
      );
    }
  }

  void _clearForm() {
    _messageController.clear();
    setState(() {
      _attachments.clear();
      _isPublic = true;
      _isExpanded = false;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }
}