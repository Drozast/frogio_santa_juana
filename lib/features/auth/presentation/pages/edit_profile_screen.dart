// lib/features/auth/presentation/pages/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/text_formatters.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../di/injection_container.dart' as di;
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/profile/profile_bloc.dart';
import '../bloc/profile/profile_event.dart';
import '../bloc/profile/profile_state.dart';
import '../widgets/profile_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  final UserEntity user;

  const EditProfileScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    _profileBloc = di.sl<ProfileBloc>();
    _nameController = TextEditingController(text: widget.user.name ?? '');
    _phoneController = TextEditingController(text: widget.user.phoneNumber ?? '');
    _addressController = TextEditingController(text: widget.user.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      bloc: _profileBloc,
      listener: (context, state) {
        if (state is ProfileUpdated) {
          // Actualizar AuthBloc con nueva información
          context.read<AuthBloc>().add(CheckAuthStatusEvent());
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil actualizado correctamente'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.pop(context, true);
        } else if (state is ProfileImageUploaded) {
          // Actualizar AuthBloc después de subir imagen
          context.read<AuthBloc>().add(CheckAuthStatusEvent());
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Imagen de perfil actualizada'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Editar Perfil'),
          elevation: 0,
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          bloc: _profileBloc,
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Avatar con opción de cambiar foto
                    BlocProvider.value(
                      value: _profileBloc,
                      child: ProfileAvatar(
                        user: widget.user,
                        radius: 60,
                        isEditable: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Toca la cámara para cambiar tu foto',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Campo nombre
                    TextFormField(
                      controller: _nameController,
                      inputFormatters: [NameFormatter()],
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: Validators.validateName,
                    ),
                    const SizedBox(height: 16),

                    // Campo teléfono
                    TextFormField(
                      controller: _phoneController,
                      inputFormatters: [PhoneFormatter()],
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        prefixIcon: Icon(Icons.phone),
                        prefixText: '+56 ',
                      ),
                      validator: Validators.validatePhone,
                    ),
                    const SizedBox(height: 16),

                    // Campo dirección
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Dirección',
                        prefixIcon: Icon(Icons.location_on),
                        hintText: 'Ej: Calle Los Aromos 123, Santa Juana',
                      ),
                      validator: Validators.validateAddress,
                    ),
                    const SizedBox(height: 24),

                    // Información de cuenta (solo lectura)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Información de la cuenta',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow('Email:', widget.user.email),
                            _buildInfoRow('Rol:', _getRoleDisplayName(widget.user.role)),
                            _buildInfoRow(
                              'Cuenta creada:',
                              _formatDate(widget.user.createdAt),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Botón guardar
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Guardar Cambios',
                        isLoading: state is ProfileLoading,
                        onPressed: _saveProfile,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
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
              label,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
      final address = _addressController.text.trim();

      _profileBloc.add(
        UpdateProfileEvent(
          userId: widget.user.id,
          name: name.isNotEmpty ? name : null,
          phoneNumber: phone.isNotEmpty ? phone : null,
          address: address.isNotEmpty ? address : null,
        ),
      );
    }
  }
}