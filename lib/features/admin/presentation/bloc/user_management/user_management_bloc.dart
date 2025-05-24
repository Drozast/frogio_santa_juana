import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../auth/domain/entities/user_entity.dart';
import '../../../../auth/domain/usecases/get_current_user.dart';

part 'user_management_event.dart';
part 'user_management_state.dart';

class UserManagementBloc extends Bloc<UserManagementEvent, UserManagementState> {
  final GetCurrentUser getCurrentUser;

  UserManagementBloc({
    required this.getCurrentUser,
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
      // TODO: Implementar caso de uso para obtener todos los usuarios
      // Por ahora simulamos la carga
      await Future.delayed(const Duration(seconds: 1));
      
      emit(UserManagementLoaded(
        users: [], // Lista vacía por ahora
        filteredUsers: [],
      ));
    } catch (e) {
      emit(UserManagementError(message: e.toString()));
    }
  }

  void _onSearchUsers(SearchUsers event, Emitter<UserManagementState> emit) {
    if (state is UserManagementLoaded) {
      final currentState = state as UserManagementLoaded;
      final filteredUsers = currentState.users.where((user) {
        return user.name.toLowerCase().contains(event.query.toLowerCase()) ||
               user.email.toLowerCase().contains(event.query.toLowerCase());
      }).toList();
      
      emit(UserManagementLoaded(
        users: currentState.users,
        filteredUsers: filteredUsers,
      ));
    }
  }

  void _onUpdateUserRole(UpdateUserRole event, Emitter<UserManagementState> emit) async {
    if (state is UserManagementLoaded) {
      final currentState = state as UserManagementLoaded;
      emit(UserManagementLoading());
      
      try {
        // TODO: Implementar caso de uso para actualizar rol
        await Future.delayed(const Duration(seconds: 1));
        
        // Simulamos la actualización
        final updatedUsers = currentState.users.map((user) {
          if (user.id == event.userId) {
            // Crear una copia del usuario con el nuevo rol
            return user; // Por ahora retornamos el mismo
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

  void _onDeactivateUser(DeactivateUser event, Emitter<UserManagementState> emit) async {
    if (state is UserManagementLoaded) {
      final currentState = state as UserManagementLoaded;
      emit(UserManagementLoading());
      
      try {
        // TODO: Implementar caso de uso para desactivar usuario
        await Future.delayed(const Duration(seconds: 1));
        
        emit(currentState);
      } catch (e) {
        emit(UserManagementError(message: e.toString()));
      }
    }
  }

  void _onActivateUser(ActivateUser event, Emitter<UserManagementState> emit) async {
    if (state is UserManagementLoaded) {
      final currentState = state as UserManagementLoaded;
      emit(UserManagementLoading());
      
      try {
        // TODO: Implementar caso de uso para activar usuario
        await Future.delayed(const Duration(seconds: 1));
        
        emit(currentState);
      } catch (e) {
        emit(UserManagementError(message: e.toString()));
      }
    }
  }
}