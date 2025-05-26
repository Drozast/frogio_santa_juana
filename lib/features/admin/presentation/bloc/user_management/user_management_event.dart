// lib/features/admin/presentation/bloc/user_management/user_management_event.dart
import 'package:equatable/equatable.dart';

abstract class UserManagementEvent extends Equatable {
  const UserManagementEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadUsersEvent extends UserManagementEvent {}

class UpdateUserRoleEvent extends UserManagementEvent {
  final String userId;
  final String newRole;
  
  const UpdateUserRoleEvent({
    required this.userId,
    required this.newRole,
  });
  
  @override
  List<Object> get props => [userId, newRole];
}

class FilterUsersEvent extends UserManagementEvent {
  final String filter;
  
  const FilterUsersEvent({required this.filter});
  
  @override
  List<Object> get props => [filter];
}

class SearchUsersEvent extends UserManagementEvent {
  final String query;
  
  const SearchUsersEvent({required this.query});
  
  @override
  List<Object> get props => [query];
}

class ActivateUserEvent extends UserManagementEvent {
  final String userId;
  
  const ActivateUserEvent({required this.userId});
  
  @override
  List<Object> get props => [userId];
}

class DeactivateUserEvent extends UserManagementEvent {
  final String userId;
  
  const DeactivateUserEvent({required this.userId});
  
  @override
  List<Object> get props => [userId];
}

// ===== STATES =====

// lib/features/admin/presentation/bloc/user_management/user_management_state.dart
import 'package:equatable/equatable.dart';

abstract class UserManagementState extends Equatable {
  const UserManagementState();
  
  @override
  List<Object?> get props => [];
}

class UserManagementInitial extends UserManagementState {}

class UserManagementLoading extends UserManagementState {}

class UsersLoaded extends UserManagementState {
  final List<UserEntity> users;
  final List<UserEntity> filteredUsers;
  final String currentFilter;
  final String searchQuery;
  
  const UsersLoaded({
    required this.users,
    List<UserEntity>? filteredUsers,
    this.currentFilter = 'Todos',
    this.searchQuery = '',
  }) : filteredUsers = filteredUsers ?? users;
  
  @override
  List<Object> get props => [users, filteredUsers, currentFilter, searchQuery];
}

class UserManagementError extends UserManagementState {
  final String message;
  
  const UserManagementError({required this.message});
  
  @override
  List<Object> get props => [message];
}

// Modelo simple de usuario para el admin
class UserEntity {
  final String id;
  final String displayName;
  final String email;
  final String role;
  final bool isActive;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.displayName,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });
}