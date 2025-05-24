// lib/features/citizen/presentation/pages/create_report_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../di/injection_container.dart' as di;
import '../../domain/entities/report_entity.dart';
import '../bloc/report/report_bloc.dart';
import '../bloc/report/report_event.dart';
import '../bloc/report/report_state.dart';

class CreateReportScreen extends StatefulWidget {
  final String userId;
  
  const CreateReportScreen({
    super.key,
    required this.userId,
  });

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Alumbrado Público';
  final List<String> _categories = [
    'Alumbrado Público',
    'Basura',
    'Calles y Veredas',
    'Seguridad',
    'Áreas Verdes',
    'Otro',
  ];
  final List<File> _selectedImages = [];
  final _imagePicker = ImagePicker();
  late ReportBloc _reportBloc;
  String? _address;
  Position? _currentPosition;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _reportBloc = di.sl<ReportBloc>();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final position = await Geolocator.getCurrentPosition();
      
      if (!mounted) return;
      
      setState(() {
        _currentPosition = position;
        _address = "Ubicación actual";
        _isLoadingLocation = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _address = "No se pudo obtener ubicación";
        _isLoadingLocation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al obtener ubicación: ${e.toString()}'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70,
      );
      
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar imagen: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      if (_selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, agrega al menos una foto'),
            backgroundColor: AppTheme.warningColor,
          ),
        );
        return;
      }

      final location = LocationData(
        latitude: _currentPosition?.latitude ?? 0,
        longitude: _currentPosition?.longitude ?? 0,
        address: _address,
      );

      _reportBloc.add(CreateReportEvent(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        location: location,
        userId: widget.userId,
        images: _selectedImages,
      ));
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 80,
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '¡Denuncia Enviada!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tu denuncia ha sido enviada exitosamente. Podrás seguir su estado en la sección "Mis Denuncias".',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to previous screen
            },
            child: const Text(
              'Aceptar',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _reportBloc,
      child: BlocListener<ReportBloc, ReportState>(
        listener: (context, state) {
          if (state is ReportCreated) {
            _showSuccessDialog();
          } else if (state is ReportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        child: BlocBuilder<ReportBloc, ReportState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Nueva Denuncia'),
              ),
              body: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Instructions
                        const Card(
                          color: Color(0xFFE8F5E9),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.info, color: AppTheme.primaryColor),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Completa el formulario y adjunta fotos para informar sobre un problema en tu comunidad.',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Title
                        const Text(
                          'Título de la denuncia',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            hintText: 'Ej: Luminaria dañada en calle Principal',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa un título';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Category
                        const Text(
                          'Categoría',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          items: _categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Location
                        const Text(
                          'Ubicación',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: _isLoadingLocation 
                                      ? Colors.grey 
                                      : _currentPosition != null
                                          ? AppTheme.successColor
                                          : AppTheme.errorColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _isLoadingLocation
                                      ? const Text('Obteniendo ubicación...')
                                      : Text(_address ?? 'Ubicación no disponible'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: _getCurrentLocation,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Description
                        const Text(
                          'Descripción',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            hintText: 'Describe el problema con detalles...',
                            alignLabelWithHint: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa una descripción';
                            }
                            if (value.length < 10) {
                              return 'La descripción debe tener al menos 10 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Images
                        const Text(
                          'Fotografías',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: 'Tomar Foto',
                                icon: Icons.camera_alt,
                                onPressed: () => _pickImage(ImageSource.camera),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: CustomButton(
                                text: 'Galería',
                                icon: Icons.photo_library,
                                isOutlined: true,
                                onPressed: () => _pickImage(ImageSource.gallery),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Image preview
                        if (_selectedImages.isNotEmpty) ...[
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedImages.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          _selectedImages[index],
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () => _removeImage(index),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: 'Enviar Denuncia',
                            isLoading: state is SubmittingReport,
                            onPressed: _submitReport,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}