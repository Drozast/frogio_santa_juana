// lib/features/citizen/presentation/bloc/report/enhanced_report_bloc.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../domain/entities/enhanced_report_entity.dart';
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

  StreamSubscription<List<ReportEntity>>? _reportsSubscription;
  List<File> _currentAttachments = [];
  LocationData? _currentLocation;

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
    // Eventos de carga
    on<LoadReportsEvent>(_onLoadReports);
    on<LoadReportDetailsEvent>(_onLoadReportDetails);
    on<LoadReportsByStatusEvent>(_onLoadReportsByStatus);
    
    // Eventos de creación
    on<CreateReportEvent>(_onCreateReport);
    
    // Eventos de estado
    on<UpdateReportStatusEvent>(_onUpdateReportStatus);
    
    // Eventos de respuestas
    on<AddReportResponseEvent>(_onAddReportResponse);
    
    // Eventos de filtrado
    on<FilterReportsEvent>(_onFilterReports);
    on<SearchReportsEvent>(_onSearchReports);
    
    // Eventos de asignación
    on<AssignReportEvent>(_onAssignReport);
    
    // Eventos de streaming
    on<StartWatchingUserReportsEvent>(_onStartWatchingUserReports);
    on<StartWatchingStatusReportsEvent>(_onStartWatchingStatusReports);
    on<StopWatchingReportsEvent>(_onStopWatchingReports);
    
    // Eventos de multimedia
    on<AddAttachmentEvent>(_onAddAttachment);
    on<RemoveAttachmentEvent>(_onRemoveAttachment);
    on<ClearAttachmentsEvent>(_onClearAttachments);
    
    // Eventos de ubicación
    on<SetLocationEvent>(_onSetLocation);
    on<GetCurrentLocationEvent>(_onGetCurrentLocation);
    on<SelectLocationOnMapEvent>(_onSelectLocationOnMap);
    
    // Evento de reset
    on<ResetReportStateEvent>(_onResetReportState);
  }

  @override
  Future<void> close() {
    _reportsSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadReports(
    LoadReportsEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    
    final result = await getReportsByUser(event.userId);
    
    result.fold(
      (failure) => emit(ReportError(message: failure.message)),
      (reports) => emit(ReportsLoaded(reports: reports)),
    );
  }

  Future<void> _onLoadReportDetails(
    LoadReportDetailsEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    
    final result = await getReportById(event.reportId);
    
    result.fold(
      (failure) => emit(ReportError(message: failure.message)),
      (report) => emit(ReportDetailLoaded(report: report)),
    );
  }

  Future<void> _onLoadReportsByStatus(
    LoadReportsByStatusEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    
    final result = await getReportsByStatus(
      GetReportsByStatusParams(
        status: event.status,
        muniId: event.muniId,
        assignedTo: event.assignedTo,
      ),
    );
    
    result.fold(
      (failure) => emit(ReportError(message: failure.message)),
      (reports) => emit(ReportsLoaded(reports: reports)),
    );
  }

  Future<void> _onCreateReport(
    CreateReportEvent event,
    Emitter<ReportState> emit,
  ) async {
    // Validar formulario
    final validationErrors = _validateReportData(event);
    if (validationErrors.isNotEmpty) {
      emit(ReportValidationError(errors: validationErrors));
      return;
    }

    emit(const ReportCreating(progress: 0.1, currentTask: 'Preparando denuncia...'));

    try {
      // Obtener ubicación si es necesaria
      LocationData finalLocation = event.location;
      if (event.location.latitude == 0 && event.location.longitude == 0) {
        emit(const ReportCreating(progress: 0.2, currentTask: 'Obteniendo ubicación...'));
        final position = await _getCurrentPosition();
        finalLocation = LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          address: await _getAddressFromCoordinates(position.latitude, position.longitude),
          source: LocationSource.gps,
        );
      }

      emit(const ReportCreating(progress: 0.4, currentTask: 'Subiendo archivos...'));

      final result = await createReport(
        CreateEnhancedReportParams(
          title: event.title,
          description: event.description,
          category: event.category,
          references: event.references,
          location: finalLocation,
          userId: event.userId,
          priority: event.priority,
          attachments: event.attachments,
        ),
      );

      result.fold(
        (failure) => emit(ReportError(message: failure.message)),
        (reportId) {
          emit(const ReportCreating(progress: 1.0, currentTask: 'Completado'));
          emit(ReportCreated(reportId: reportId));
          // Limpiar attachments después de crear
          _currentAttachments.clear();
        },
      );
    } catch (e) {
      emit(ReportError(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateReportStatus(
    UpdateReportStatusEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportStatusUpdating());
    
    final result = await updateReportStatus(
      UpdateReportStatusParams(
        reportId: event.reportId,
        status: event.status,
        comment: event.comment,
        userId: event.userId,
      ),
    );
    
    result.fold(
      (failure) => emit(ReportError(message: failure.message)),
      (_) => emit(ReportStatusUpdated(
        reportId: event.reportId,
        newStatus: event.status,
        message: 'Estado actualizado a ${event.status.displayName}',
      )),
    );
  }

  Future<void> _onAddReportResponse(
    AddReportResponseEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(ResponseAdding());
    
    final result = await addReportResponse(
      AddReportResponseParams(
        reportId: event.reportId,
        responderId: event.responderId,
        responderName: event.responderName,
        message: event.message,
        attachments: event.attachments,
        isPublic: event.isPublic,
      ),
    );
    
    result.fold(
      (failure) => emit(ReportError(message: failure.message)),
      (_) => emit(const ResponseAdded(message: 'Respuesta agregada exitosamente')),
    );
  }

  void _onFilterReports(
    FilterReportsEvent event,
    Emitter<ReportState> emit,
  ) {
    final currentState = state;
    
    if (currentState is ReportsLoaded) {
      final filteredReports = event.filter == 'Todas'
          ? currentState.reports
          : currentState.reports.where((report) => 
              report.status.displayName == event.filter
            ).toList();
      
      emit(ReportsLoaded(
        reports: currentState.reports,
        filteredReports: filteredReports,
        currentFilter: event.filter,
        searchQuery: currentState.searchQuery,
      ));
    }
  }

  void _onSearchReports(
    SearchReportsEvent event,
    Emitter<ReportState> emit,
  ) {
    final currentState = state;
    
    if (currentState is ReportsLoaded) {
      final filteredReports = event.query.isEmpty
          ? currentState.reports
          : currentState.reports.where((report) =>
              report.title.toLowerCase().contains(event.query.toLowerCase()) ||
              report.description.toLowerCase().contains(event.query.toLowerCase()) ||
              report.category.toLowerCase().contains(event.query.toLowerCase())
            ).toList();
      
      emit(ReportsLoaded(
        reports: currentState.reports,
        filteredReports: filteredReports,
        currentFilter: currentState.currentFilter,
        searchQuery: event.query,
      ));
    }
  }

  Future<void> _onAssignReport(
    AssignReportEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportAssigning());
    
    final result = await assignReport(
      AssignReportParams(
        reportId: event.reportId,
        assignedToId: event.assignedToId,
        assignedById: event.assignedById,
      ),
    );
    
    result.fold(
      (failure) => emit(ReportError(message: failure.message)),
      (_) => emit(ReportAssigned(
        reportId: event.reportId,
        assignedTo: event.assignedToId,
      )),
    );
  }

  Future<void> _onStartWatchingUserReports(
    StartWatchingUserReportsEvent event,
    Emitter<ReportState> emit,
  ) async {
    await _reportsSubscription?.cancel();
    
    final result = await watchReportsByUser(event.userId);
    
    result.fold(
      (failure) => emit(ReportError(message: failure.message)),
      (stream) {
        emit(const ReportsStreaming(reports: [], isListening: true));
        
        _reportsSubscription = stream.listen(
          (reports) => emit(ReportsStreaming(reports: reports)),
          onError: (error) => emit(ReportError(message: error.toString())),
        );
      },
    );
  }

  Future<void> _onStartWatchingStatusReports(
    StartWatchingStatusReportsEvent event,
    Emitter<ReportState> emit,
  ) async {
    await _reportsSubscription?.cancel();
    
    final result = await watchReportsByStatus(
      WatchReportsByStatusParams(
        status: event.status,
        muniId: event.muniId,
      ),
    );
    
    result.fold(
      (failure) => emit(ReportError(message: failure.message)),
      (stream) {
        emit(const ReportsStreaming(reports: [], isListening: true));
        
        _reportsSubscription = stream.listen(
          (reports) => emit(ReportsStreaming(reports: reports)),
          onError: (error) => emit(ReportError(message: error.toString())),
        );
      },
    );
  }

  Future<void> _onStopWatchingReports(
    StopWatchingReportsEvent event,
    Emitter<ReportState> emit,
  ) async {
    await _reportsSubscription?.cancel();
    _reportsSubscription = null;
    
    if (state is ReportsStreaming) {
      final currentState = state as ReportsStreaming;
      emit(ReportsLoaded(reports: currentState.reports));
    }
  }

  void _onAddAttachment(
    AddAttachmentEvent event,
    Emitter<ReportState> emit,
  ) {
    _currentAttachments.add(event.file);
    emit(AttachmentsUpdated(attachments: List.from(_currentAttachments)));
  }

  void _onRemoveAttachment(
    RemoveAttachmentEvent event,
    Emitter<ReportState> emit,
  ) {
    if (event.index >= 0 && event.index < _currentAttachments.length) {
      _currentAttachments.removeAt(event.index);
      emit(AttachmentsUpdated(attachments: List.from(_currentAttachments)));
    }
  }

  void _onClearAttachments(
    ClearAttachmentsEvent event,
    Emitter<ReportState> emit,
  ) {
    _currentAttachments.clear();
    emit(AttachmentsUpdated(attachments: []));
  }

  void _onSetLocation(
    SetLocationEvent event,
    Emitter<ReportState> emit,
  ) {
    _currentLocation = event.location;
    emit(LocationSelected(location: event.location));
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocationEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(LocationLoading());
    
    try {
      final position = await _getCurrentPosition();
      final address = await _getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      final location = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        source: LocationSource.gps,
      );
      
      _currentLocation = location;
      emit(LocationSelected(location: location));
    } catch (e) {
      emit(LocationError(message: e.toString()));
    }
  }

  Future<void> _onSelectLocationOnMap(
    SelectLocationOnMapEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(LocationLoading());
    
    try {
      final address = await _getAddressFromCoordinates(
        event.latitude,
        event.longitude,
      );
      
      final location = LocationData(
        latitude: event.latitude,
        longitude: event.longitude,
        address: address,
        source: LocationSource.map,
      );
      
      _currentLocation = location;
      emit(LocationSelected(location: location));
    } catch (e) {
      emit(LocationError(message: 'Error al obtener dirección: ${e.toString()}'));
    }
  }

  void _onResetReportState(
    ResetReportStateEvent event,
    Emitter<ReportState> emit,
  ) {
    _currentAttachments.clear();
    _currentLocation = null;
    emit(ReportInitial());
  }

  // Métodos auxiliares
  
  Map<String, String> _validateReportData(CreateReportEvent event) {
    final errors = <String, String>{};
    
    if (event.title.trim().isEmpty) {
      errors['title'] = 'El título es requerido';
    } else if (event.title.trim().length < 5) {
      errors['title'] = 'El título debe tener al menos 5 caracteres';
    }
    
    if (event.description.trim().isEmpty) {
      errors['description'] = 'La descripción es requerida';
    } else if (event.description.trim().length < 10) {
      errors['description'] = 'La descripción debe tener al menos 10 caracteres';
    }
    
    if (event.category.isEmpty) {
      errors['category'] = 'La categoría es requerida';
    }
    
    if (event.location.latitude == 0 && event.location.longitude == 0 && 
        (event.location.manualAddress?.isEmpty ?? true)) {
      errors['location'] = 'Debe proporcionar una ubicación';
    }
    
    return errors;
  }

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Servicios de ubicación desactivados');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permiso de ubicación denegado');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permiso de ubicación denegado permanentemente');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<String?> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}';
      }
    } catch (e) {
      // Ignorar errores de geocoding
    }
    return null;
  }
}