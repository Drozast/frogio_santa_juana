import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/get_all_users.dart';
import '../../../domain/usecases/update_user_role.dart';

part 'user_management_event.dart';
part 'user_management_state.dart';

class UserManagementBloc extends Bloc<UserManagementEvent, UserManagementState> {
  final GetAllUsers getAllUsers;
  final UpdateUserRole updateUserRole;

  UserManagementBloc({
    required this.getAllUsers,
    required this.updateUserRole,
  }) : super(UserManagementInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<SearchUsers>(_onSearchUsers);
    on<UpdateUserRoleEvent>(_onUpdateUserRole);
    on<DeactivateUserEvent>(_onDeactivateUser);
    on<ActivateUserEvent>(_onActivateUser);
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
        final nameLower = user.displayName.toLowerCase();
        final emailLower = user.email.toLowerCase();
        
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
        // Simular desactivación de usuario
        // En implementación real, usarías un use case específico
        await Future.delayed(const Duration(seconds: 1));
        
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
        // Simular activación de usuario
        // En implementación real, usarías un use case específico
        await Future.delayed(const Duration(seconds: 1));
        
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
      } catch (e) {
        emit(UserManagementError(message: e.toString()));
      }
    }
  }
}