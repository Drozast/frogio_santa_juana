part of 'user_management_bloc.dart';

abstract class UserManagementState extends Equatable {
  const UserManagementState();

  @override
  List<Object?> get props => [];
}

class UserManagementInitial extends UserManagementState {}

class UserManagementLoading extends UserManagementState {}

class UserManagementLoaded extends UserManagementState {
  final List<UserEntity> users;
  final List<UserEntity> filteredUsers;

  const UserManagementLoaded({
    required this.users,
    required this.filteredUsers,
  });

  @override
  List<Object> get props => [users, filteredUsers];
}

class UserManagementError extends UserManagementState {
  final String message;

  const UserManagementError({required this.message});

  @override
  List<Object> get props => [message];
}