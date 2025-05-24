// lib/features/admin/presentation/bloc/user_management/user_management_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/query_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/answer_query.dart';
import '../../../domain/usecases/get_all_pending_queries.dart';

// Events
abstract class UserManagementEvent extends Equatable {
  const UserManagementEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadPendingQueriesEvent extends UserManagementEvent {
  final String muniId;
  final QueryPriority? priority;
  final QueryCategory? category;
  final bool onlyUrgent;
  final bool onlyOverdue;
  
  const LoadPendingQueriesEvent({
    required this.muniId,
    this.priority,
    this.category,
    this.onlyUrgent = false,
    this.onlyOverdue = false,
  });
  
  @override
  List<Object?> get props => [muniId, priority, category, onlyUrgent, onlyOverdue];
}

class AnswerQueryEvent extends UserManagementEvent {
  final String queryId;
  final String adminId;
  final String response;
  final List<String>? attachments;
  final bool sendNotification;
  final bool closeQuery;
  
  const AnswerQueryEvent({
    required this.queryId,
    required this.adminId,
    required this.response,
    this.attachments,
    this.sendNotification = true,
    this.closeQuery = false,
  });
  
  @override
  List<Object?> get props => [
    queryId, adminId, response, attachments, sendNotification, closeQuery
  ];
}

class FilterQueriesEvent extends UserManagementEvent {
  final QueryPriority? priority;
  final QueryCategory? category;
  final bool onlyUrgent;
  final bool onlyOverdue;
  
  const FilterQueriesEvent({
    this.priority,
    this.category,
    this.onlyUrgent = false,
    this.onlyOverdue = false,
  });
  
  @override
  List<Object?> get props => [priority, category, onlyUrgent, onlyOverdue];
}

class SearchQueriesEvent extends UserManagementEvent {
  final String searchTerm;
  
  const SearchQueriesEvent({required this.searchTerm});
  
  @override
  List<Object> get props => [searchTerm];
}

class RefreshQueriesEvent extends UserManagementEvent {
  final String muniId;
  
  const RefreshQueriesEvent({required this.muniId});
  
  @override
  List<Object> get props => [muniId];
}

// States
abstract class UserManagementState extends Equatable {
  const UserManagementState();
  
  @override
  List<Object?> get props => [];
}

class UserManagementInitial extends UserManagementState {}

class UserManagementLoading extends UserManagementState {
  final String? message;
  
  const UserManagementLoading({this.message});
  
  @override
  List<Object?> get props => [message];
}

class QueriesLoaded extends UserManagementState {
  final List<QueryEntity> queries;
  final List<QueryEntity> filteredQueries;
  final String? searchTerm;
  final QueryPriority? selectedPriority;
  final QueryCategory? selectedCategory;
  final bool showOnlyUrgent;
  final bool showOnlyOverdue;
  final int totalCount;
  final int urgentCount;
  final int overdueCount;
  
  const QueriesLoaded({
    required this.queries,
    List<QueryEntity>? filteredQueries,
    this.searchTerm,
    this.selectedPriority,
    this.selectedCategory,
    this.showOnlyUrgent = false,
    this.showOnlyOverdue = false,
    required this.totalCount,
    required this.urgentCount,
    required this.overdueCount,
  }) : filteredQueries = filteredQueries ?? queries;
  
  @override
  List<Object?> get props => [
    queries, filteredQueries, searchTerm, selectedPriority, selectedCategory,
    showOnlyUrgent, showOnlyOverdue, totalCount, urgentCount, overdueCount,
  ];
  
  QueriesLoaded copyWith({
    List<QueryEntity>? queries,
    List<QueryEntity>? filteredQueries,
    String? searchTerm,
    QueryPriority? selectedPriority,
    QueryCategory? selectedCategory,
    bool? showOnlyUrgent,
    bool? showOnlyOverdue,
    int? totalCount,
    int? urgentCount,
    int? overdueCount,
  }) {
    return QueriesLoaded(
      queries: queries ?? this.queries,
      filteredQueries: filteredQueries ?? this.filteredQueries,
      searchTerm: searchTerm ?? this.searchTerm,
      selectedPriority: selectedPriority ?? this.selectedPriority,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      showOnlyUrgent: showOnlyUrgent ?? this.showOnlyUrgent,
      showOnlyOverdue: showOnlyOverdue ?? this.showOnlyOverdue,
      totalCount: totalCount ?? this.totalCount,
      urgentCount: urgentCount ?? this.urgentCount,
      overdueCount: overdueCount ?? this.overdueCount,
    );
  }
}

class QueryAnswering extends UserManagementState {
  final String queryId;
  
  const QueryAnswering({required this.queryId});
  
  @override
  List<Object> get props => [queryId];
}

class QueryAnswered extends UserManagementState {
  final String queryId;
  final String message;
  
  const QueryAnswered({
    required this.queryId,
    required this.message,
  });
  
  @override
  List<Object> get props => [queryId, message];
}

class UserManagementError extends UserManagementState {
  final String message;
  final String? errorCode;
  final bool canRetry;
  
  const UserManagementError({
    required this.message,
    this.errorCode,
    this.canRetry = true,
  });
  
  @override
  List<Object?> get props => [message, errorCode, canRetry];
}

// BLoC
class UserManagementBloc extends Bloc<UserManagementEvent, UserManagementState> {
  final GetAllPendingQueries getAllPendingQueries;
  final AnswerQuery answerQuery;
  
  UserManagementBloc({
    required this.getAllPendingQueries,
    required this.answerQuery,
  }) : super(UserManagementInitial()) {
    on<LoadPendingQueriesEvent>(_onLoadPendingQueries);
    on<AnswerQueryEvent>(_onAnswerQuery);
    on<FilterQueriesEvent>(_onFilterQueries);
    on<SearchQueriesEvent>(_onSearchQueries);
    on<RefreshQueriesEvent>(_onRefreshQueries);
  }

  Future<void> _onLoadPendingQueries(
    LoadPendingQueriesEvent event,
    Emitter<UserManagementState> emit,
  ) async {
    if (state is! QueriesLoaded) {
      emit(const UserManagementLoading(message: 'Cargando consultas pendientes...'));
    }
    
    try {
      final result = await getAllPendingQueries(
        GetPendingQueriesParams(
          muniId: event.muniId,
          priority: event.priority,
          category: event.category,
          onlyUrgent: event.onlyUrgent,
          onlyOverdue: event.onlyOverdue,
          sortBy: QuerySortBy.newest,
        ),
      );
      
      result.fold(
        (failure) => emit(UserManagementError(message: failure.message)),
        (queries) {
          final stats = _calculateQueryStats(queries);
          
          emit(QueriesLoaded(
            queries: queries,
            totalCount: queries.length,
            urgentCount: stats['urgent'] ?? 0,
            overdueCount: stats['overdue'] ?? 0,
          ));
        },
      );
    } catch (e) {
      emit(UserManagementError(
        message: 'Error inesperado: ${e.toString()}',
      ));
    }
  }

  Future<void> _onAnswerQuery(
    AnswerQueryEvent event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(QueryAnswering(queryId: event.queryId));
    
    try {
      final result = await answerQuery(
        AnswerQueryParams(
          queryId: event.queryId,
          adminId: event.adminId,
          response: event.response,
          attachments: event.attachments,
          sendNotification: event.sendNotification,
          closeQuery: event.closeQuery,
        ),
      );
      
      result.fold(
        (failure) => emit(UserManagementError(message: failure.message)),
        (_) {
          emit(QueryAnswered(
            queryId: event.queryId,
            message: 'Consulta respondida exitosamente',
          ));
          
          // Recargar consultas después de responder
          if (state is QueriesLoaded) {
            final currentState = state as QueriesLoaded;
            // Aquí deberías recargar desde el servidor o actualizar la lista local
          }
        },
      );
    } catch (e) {
      emit(UserManagementError(
        message: 'Error al responder consulta: ${e.toString()}',
      ));
    }
  }

  void _onFilterQueries(
    FilterQueriesEvent event,
    Emitter<UserManagementState> emit,
  ) {
    if (state is QueriesLoaded) {
      final currentState = state as QueriesLoaded;
      
      List<QueryEntity> filteredQueries = currentState.queries;
      
      // Aplicar filtros
      if (event.priority != null) {
        filteredQueries = filteredQueries
            .where((query) => query.priority == event.priority)
            .toList();
      }
      
      if (event.category != null) {
        filteredQueries = filteredQueries
            .where((query) => query.category == event.category)
            .toList();
      }
      
      if (event.onlyUrgent) {
        filteredQueries = filteredQueries
            .where((query) => query.isUrgent)
            .toList();
      }
      
      if (event.onlyOverdue) {
        filteredQueries = filteredQueries
            .where((query) => query.isOverdue)
            .toList();
      }
      
      // Aplicar búsqueda si existe
      if (currentState.searchTerm != null && currentState.searchTerm!.isNotEmpty) {
        filteredQueries = filteredQueries
            .where((query) =>
                query.title.toLowerCase().contains(currentState.searchTerm!.toLowerCase()) ||
                query.description.toLowerCase().contains(currentState.searchTerm!.toLowerCase()) ||
                query.citizenName.toLowerCase().contains(currentState.searchTerm!.toLowerCase()))
            .toList();
      }
      
      emit(currentState.copyWith(
        filteredQueries: filteredQueries,
        selectedPriority: event.priority,
        selectedCategory: event.category,
        showOnlyUrgent: event.onlyUrgent,
        showOnlyOverdue: event.onlyOverdue,
      ));
    }
  }

  void _onSearchQueries(
    SearchQueriesEvent event,
    Emitter<UserManagementState> emit,
  ) {
    if (state is QueriesLoaded) {
      final currentState = state as QueriesLoaded;
      
      List<QueryEntity> filteredQueries = currentState.queries;
      
      // Aplicar búsqueda
      if (event.searchTerm.isNotEmpty) {
        filteredQueries = filteredQueries
            .where((query) =>
                query.title.toLowerCase().contains(event.searchTerm.toLowerCase()) ||
                query.description.toLowerCase().contains(event.searchTerm.toLowerCase()) ||
                query.citizenName.toLowerCase().contains(event.searchTerm.toLowerCase()))
            .toList();
      }
      
      // Aplicar filtros existentes
      if (currentState.selectedPriority != null) {
        filteredQueries = filteredQueries
            .where((query) => query.priority == currentState.selectedPriority)
            .toList();
      }
      
      if (currentState.selectedCategory != null) {
        filteredQueries = filteredQueries
            .where((query) => query.category == currentState.selectedCategory)
            .toList();
      }
      
      if (currentState.showOnlyUrgent) {
        filteredQueries = filteredQueries
            .where((query) => query.isUrgent)
            .toList();
      }
      
      if (currentState.showOnlyOverdue) {
        filteredQueries = filteredQueries
            .where((query) => query.isOverdue)
            .toList();
      }
      
      emit(currentState.copyWith(
        filteredQueries: filteredQueries,
        searchTerm: event.searchTerm,
      ));
    }
  }

  Future<void> _onRefreshQueries(
    RefreshQueriesEvent event,
    Emitter<UserManagementState> emit,
  ) async {
    add(LoadPendingQueriesEvent(muniId: event.muniId));
  }

  Map<String, int> _calculateQueryStats(List<QueryEntity> queries) {
    final stats = <String, int>{
      'urgent': 0,
      'overdue': 0,
      'pending': 0,
      'answered': 0,
    };
    
    for (final query in queries) {
      if (query.isUrgent) {
        stats['urgent'] = (stats['urgent'] ?? 0) + 1;
      }
      
      if (query.isOverdue) {
        stats['overdue'] = (stats['overdue'] ?? 0) + 1;
      }
      
      if (query.isPending) {
        stats['pending'] = (stats['pending'] ?? 0) + 1;
      }
      
      if (query.isAnswered) {
        stats['answered'] = (stats['answered'] ?? 0) + 1;
      }
    }
    
    return stats;
  }
}