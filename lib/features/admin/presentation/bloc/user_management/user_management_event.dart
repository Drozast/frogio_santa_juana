part of 'user_management_bloc.dart';

abstract class UserManagementEvent extends Equatable {
  const UserManagementEvent();

  @override
  List<Object> get props => [];
}

class LoadUsers extends UserManagementEvent {
  final String? municipalityId;

  const LoadUsers({this.municipalityId});

  @override
  List<Object> get props => [municipalityId ?? ''];
}

class SearchUsers extends UserManagementEvent {
  final String query;

  const SearchUsers({required this.query});

  @override
  List<Object> get props => [query];
}

class UpdateUserRole extends UserManagementEvent {
  final String userId;
  final String newRole;

  const UpdateUserRole({
    required this.userId,
    required this.newRole,
  });

  @override
  List<Object> get props => [userId, newRole];
}

class DeactivateUser extends UserManagementEvent {
  final String userId;

  const DeactivateUser({required this.userId});

  @override
  List<Object> get props => [userId];
}

class ActivateUser extends UserManagementEvent {
  final String userId;

  const ActivateUser({required this.userId});

  @override
  List<Object> get props => [userId];
}