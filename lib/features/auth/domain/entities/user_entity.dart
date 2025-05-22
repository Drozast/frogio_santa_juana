// lib/features/auth/domain/entities/user_entity.dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String role;
  final String? muniId;
  final DateTime createdAt;
  
  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    required this.role,
    this.muniId,
    required this.createdAt,
  });
  
  @override
  List<Object?> get props => [id, email, name, role, muniId, createdAt];
}