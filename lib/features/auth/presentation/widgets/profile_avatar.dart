// lib/features/auth/presentation/widgets/profile_avatar.dart
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/profile/profile_bloc.dart';
import '../bloc/profile/profile_event.dart';
import '../bloc/profile/profile_state.dart';

class ProfileAvatar extends StatelessWidget {
  final UserEntity user;
  final double radius;
  final bool isEditable;

  const ProfileAvatar({
    Key? key,
    required this.user,
    this.radius = 50,
    this.isEditable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return Stack(
          children: [
            CircleAvatar(
              radius: radius,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: state is ProfileImageUploading
                  ? const CircularProgressIndicator()
                  : _buildAvatarContent(),
            ),
            if (isEditable)
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showImagePicker(context),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildAvatarContent() {
    if (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: user.profileImageUrl!,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: radius,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => CircleAvatar(
          radius: radius,
          child: const CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => _buildDefaultAvatar(),
      );
    }
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
      child: Text(
        user.displayName.substring(0, 1).toUpperCase(),
        style: TextStyle(
          fontSize: radius * 0.6,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de galería'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        
        // Buscar ProfileBloc en el contexto padre o crear uno nuevo
        try {
          context.read<ProfileBloc>().add(
            UploadProfileImageEvent(
              userId: user.id,
              imageFile: imageFile,
            ),
          );
        } catch (e) {
          // Si no hay ProfileBloc disponible, usar el servicio directamente
          _uploadImageDirectly(context, imageFile);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar imagen: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _uploadImageDirectly(BuildContext context, File imageFile) async {
    // TODO: Implementar subida directa si es necesario
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ve a Editar Perfil para cambiar tu foto'),
      ),
    );
  }
}