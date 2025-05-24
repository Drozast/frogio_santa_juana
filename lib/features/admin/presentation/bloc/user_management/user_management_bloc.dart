import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/activate_user.dart';
import '../../../domain/usecases/deactivate_user.dart';
import '../../../domain/usecases/get_all_users.dart';
import '../../../domain/usecases/update_user_role.dart';

part 'user_management_event.dart';
part 'user_management_state.dart';

class UserManagementBloc extends Bloc<UserManagementEvent, UserManagementState> {
  final GetAllUsers getAllUsers;
  final UpdateUserRole updateUserRole;
  final ActivateUser activateUser;
  final DeactivateUser deactivateUser;

  UserManagementBloc({
    required this.getAllUsers,
    required this.updateUserRole,
    required this.activateUser,
    required this.deactivateUser,
  }) : super(UserManagementInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<SearchUsers>(_onSearchUsers);
    on<UpdateUserRole>(_onUpdateUserRole);
    on<DeactivateUser>(_onDeactivateUser);
    on<ActivateUser>(_onActivateUser);
  }

  void _onLoadUsers(LoadUsers event, Emitter<UserManagementState> emit) async {
    emit(UserManagementLoading());
   
    try {
      final result = await getAllUsers(event.muniId);
      
      result.fold(
        (failure) => emit(UserManagementError(message: failure.message)),
        (users) => emit(UserManagementLoaded(
          users: users,
          filteredUsers: users,
        )),
      );
    } catch (e) {
      emit(UserManagementError(message: e.toString()));
    }
  }

  void _onSearchUsers(SearchUsers event, Emitter<UserManagementState> emit) {
    if (state is UserManagementLoaded) {
      final currentState = state as UserManagementLoaded;
      
      // Verificar si la consulta es null o vacía
      if (event.query == null || event.query!.trim().isEmpty) {
        // Si no hay query, mostrar todos los usuarios
        emit(UserManagementLoaded(
          users: currentState.users,
          filteredUsers: currentState.users,
        ));
        return;
      }
      
      final queryLower = event.query!.toLowerCase().trim();
      final filteredUsers = currentState.users.where((user) {
        final nameLower = user.name?.toLowerCase() ?? '';
        final emailLower = user.email?.toLowerCase() ?? '';
        
        return nameLower.contains(queryLower) || emailLower.contains(queryLower);
      }).toList();
     
      emit(UserManagementLoaded(
        users: currentState.users,
        filteredUsers: filteredUsers,
      ));
    }
  }

  void _onUpdateUserRole(UpdateUserRoleEvent event, Emitter<UserManagementState> emit) async {
    if (state is UserManagementLoaded) {
      final currentState = state as UserManagementLoaded;
      emit(UserManagementLoading());
     
      try {
        final result = await updateUserRole(UpdateUserRoleParams(
          userId: event.userId,
          newRole: event.newRole,
          adminId: event.adminId,
        ));
        
        result.fold(
          (failure) => emit(UserManagementError(message: failure.message)),
          (_) {
            // Recargar la lista de usuarios después de la actualización
            add(LoadUsers(muniId: event.muniId));
          },
        );
      } catch (e) {
        emit(UserManagementError(message: e.toString()));
      }
    }
  }

  void _onDeactivateUser(DeactivateUserEvent event, Emitter<UserManagementState> emit) async {
    if (state is UserManagementLoaded) {
      final currentState = state as UserManagementLoaded;
      emit(UserManagementLoading());
     
      try {
        final result = await deactivateUser(event.userId);
        
        result.fold(
          (failure) => emit(UserManagementError(message: failure.message)),
          (_) {
            // Actualizar el usuario en la lista local
            final updatedUsers = currentState.users.map((user) {
              if (user.id == event.userId) {
                return user.copyWith(isActive: false);
              }
              return user;
            }).toList();
            
            emit(UserManagementLoaded(
              users: updatedUsers,
              filteredUsers: updatedUsers,
            ));
          },
        );
      } catch (e) {
        emit(UserManagementError(message: e.toString()));
      }
    }
  }

  void _onActivateUser(ActivateUserEvent event, Emitter<UserManagementState> emit) async {
    if (state is UserManagementLoaded) {
      final currentState = state as UserManagementLoaded;
      emit(UserManagementLoading());
     
      try {
        final result = await activateUser(event.userId);
        
        result.fold(
          (failure) => emit(UserManagementError(message: failure.message)),
          (_) {
            // Actualizar el usuario en la lista local
            final updatedUsers = currentState.users.map((user) {
              if (user.id == event.userId) {
                return user.copyWith(isActive: true);
              }
              return user;
            }).toList();
            
            emit(UserManagementLoaded(
              users: updatedUsers,
              filteredUsers: updatedUsers,
            ));
          },
        );
      } catch (e) {
        emit(UserManagementError(message: e.toString()));
      }
    }
  }
}

// user_management_event.dart
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

// user_management_state.dart
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