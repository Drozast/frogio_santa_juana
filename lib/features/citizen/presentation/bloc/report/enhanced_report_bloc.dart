// lib/features/citizen/presentation/bloc/report/enhanced_report_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/reports/enhanced_report_use_cases.dart';
import 'enhanced_report_event.dart';
import 'enhanced_report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final CreateEnhancedReport createReport;
  final GetEnhancedReportsByUser getReportsByUser;
  final GetEnhancedReportById getReportById;
  final UpdateReportStatus updateReportStatus;
  final AddReportResponse addReportResponse;
  final GetReportsByStatus getReportsByStatus;
  final AssignReport assignReport;
  final WatchReportsByUser watchReportsByUser;
  final WatchReportsByStatus watchReportsByStatus;

  ReportBloc({
    required this.createReport,
    required this.getReportsByUser,
    required this.getReportById,
    required this.updateReportStatus,
    required this.addReportResponse,
    required this.getReportsByStatus,
    required this.assignReport,
    required this.watchReportsByUser,
    required this.watchReportsByStatus,
  }) : super(ReportInitial()) {
    on<LoadReportsEvent>(_onLoadReports);
    on<LoadReportByIdEvent>(_onLoadReportById);
    on<CreateReportEvent>(_onCreateReport);
    on<UpdateReportStatusEvent>(_onUpdateReportStatus);
    on<AddReportResponseEvent>(_onAddReportResponse);
    on<LoadReportsByStatusEvent>(_onLoadReportsByStatus);
    on<AssignReportEvent>(_onAssignReport);
    on<RefreshReportsEvent>(_onRefreshReports);
  }

  Future<void> _onLoadReports(
    LoadReportsEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    
    try {
      final result = await getReportsByUser(event.userId);
      
      result.fold(
        (failure) => emit(ReportError(message: failure.message)),
        (reports) => emit(ReportsLoaded(reports: reports)),
      );
    } catch (e) {
      emit(ReportError(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onLoadReportById(
    LoadReportByIdEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    
    try {
      final result = await getReportById(event.reportId);
      
      result.fold(
        (failure) => emit(ReportError(message: failure.message)),
        (report) => emit(ReportDetailLoaded(report: report)),
      );
    } catch (e) {
      emit(ReportError(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onCreateReport(
    CreateReportEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportCreating());
    
    try {
      final result = await createReport(event.params);
      
      result.fold(
        (failure) => emit(ReportError(message: failure.message)),
        (reportId) => emit(ReportCreated(reportId: reportId)),
      );
    } catch (e) {
      emit(ReportError(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateReportStatus(
    UpdateReportStatusEvent event,
    Emitter<ReportState> emit,
  ) async {
    try {
      final result = await updateReportStatus(event.params);
      
      result.fold(
        (failure) => emit(ReportError(message: failure.message)),
        (_) {
          // Opcional: recargar el reporte o lista después de actualizar
          if (state is ReportDetailLoaded) {
            add(LoadReportByIdEvent(reportId: event.params.reportId));
          }
        },
      );
    } catch (e) {
      emit(ReportError(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onAddReportResponse(
    AddReportResponseEvent event,
    Emitter<ReportState> emit,
  ) async {
    try {
      final result = await addReportResponse(event.params);
      
      result.fold(
        (failure) => emit(ReportError(message: failure.message)),
        (_) {
          // Opcional: recargar el reporte después de agregar respuesta
          if (state is ReportDetailLoaded) {
            add(LoadReportByIdEvent(reportId: event.params.reportId));
          }
        },
      );
    } catch (e) {
      emit(ReportError(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onLoadReportsByStatus(
    LoadReportsByStatusEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    
    try {
      final result = await getReportsByStatus(event.params);
      
      result.fold(
        (failure) => emit(ReportError(message: failure.message)),
        (reports) => emit(ReportsLoaded(reports: reports)),
      );
    } catch (e) {
      emit(ReportError(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onAssignReport(
    AssignReportEvent event,
    Emitter<ReportState> emit,
  ) async {
    try {
      final result = await assignReport(event.params);
      
      result.fold(
        (failure) => emit(ReportError(message: failure.message)),
        (_) {
          // Opcional: recargar el reporte después de asignar
          if (state is ReportDetailLoaded) {
            add(LoadReportByIdEvent(reportId: event.params.reportId));
          }
        },
      );
    } catch (e) {
      emit(ReportError(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshReports(
    RefreshReportsEvent event,
    Emitter<ReportState> emit,
  ) async {
    // No emitir loading state para refresh
    try {
      final result = await getReportsByUser(event.userId);
      
      result.fold(
        (failure) => emit(ReportError(message: failure.message)),
        (reports) => emit(ReportsLoaded(reports: reports)),
      );
    } catch (e) {
      emit(ReportError(message: 'Error inesperado: ${e.toString()}'));
    }
  }
}