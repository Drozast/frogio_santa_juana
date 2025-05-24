part of 'user_management_bloc.dart';

abstract class UserManagementEvent extends Equatable {
  const UserManagementEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsers extends UserManagementEvent {
  final String muniId;

  const LoadUsers({required this.muniId});

  @override
  List<Object> get props => [muniId];
}

class SearchUsers extends UserManagementEvent {
  final String? query;

  const SearchUsers({this.query});

  @override
  List<Object?> get props => [query];
}

class UpdateUserRoleEvent extends UserManagementEvent {
  final String userId;
  final String newRole;
  final String adminId;
  final String muniId;

  const UpdateUserRoleEvent({
    required this.userId,
    required this.newRole,
    required this.adminId,
    required this.muniId,
  });

  @override
  List<Object> get props => [userId, newRole, adminId, muniId];
}

class DeactivateUserEvent extends UserManagementEvent {
  final String userId;

  const DeactivateUserEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class ActivateUserEvent extends UserManagementEvent {
  final String userId;

  const ActivateUserEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}