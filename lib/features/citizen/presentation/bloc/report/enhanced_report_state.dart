// lib/features/citizen/presentation/bloc/report/enhanced_report_state.dart
import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../../domain/entities/enhanced_report_entity.dart';

abstract class ReportState extends Equatable {
  const ReportState();
  
  @override
  List<Object?> get props => [];
}

// INITIAL STATE
class ReportInitial extends ReportState {}

// LOADING STATES
class ReportLoading extends ReportState {}

class ReportCreating extends ReportState {
  final double progress;
  final String currentTask;
  
  const ReportCreating({
    required this.progress,
    required this.currentTask,
  });
  
  @override
  List<Object> get props => [progress, currentTask];
}

class ReportStatusUpdating extends ReportState {}

class ResponseAdding extends ReportState {}

class ReportAssigning extends ReportState {}

// SUCCESS STATES
class ReportsLoaded extends ReportState {
  final List<ReportEntity> reports;
  final List<ReportEntity> filteredReports;
  final String currentFilter;
  final String searchQuery;
  
  const ReportsLoaded({
    required this.reports,
    List<ReportEntity>? filteredReports,
    this.currentFilter = 'Todas',
    this.searchQuery = '',
  }) : filteredReports = filteredReports ?? reports;
  
  @override
  List<Object> get props => [reports, filteredReports, currentFilter, searchQuery];
}

class ReportDetailLoaded extends ReportState {
  final ReportEntity report;
  
  const ReportDetailLoaded({required this.report});
  
  @override
  List<Object> get props => [report];
}

class ReportCreated extends ReportState {
  final String reportId;
  
  const ReportCreated({required this.reportId});
  
  @override
  List<Object> get props => [reportId];
}

class ReportStatusUpdated extends ReportState {
  final String reportId;
  final ReportStatus newStatus;
  final String message;
  
  const ReportStatusUpdated({
    required this.reportId,
    required this.newStatus,
    required this.message,
  });
  
  @override
  List<Object> get props => [reportId, newStatus, message];
}

class ResponseAdded extends ReportState {
  final String message;
  
  const ResponseAdded({required this.message});
  
  @override
  List<Object> get props => [message];
}

class ReportAssigned extends ReportState {
  final String reportId;
  final String assignedTo;
  
  const ReportAssigned({
    required this.reportId,
    required this.assignedTo,
  });
  
  @override
  List<Object> get props => [reportId, assignedTo];
}

// REAL-TIME STATES
class ReportsStreaming extends ReportState {
  final List<ReportEntity> reports;
  final bool isListening;
  
  const ReportsStreaming({
    required this.reports,
    this.isListening = true,
  });
  
  @override
  List<Object> get props => [reports, isListening];
}

// MEDIA STATES
class AttachmentsUpdated extends ReportState {
  final List<File> attachments;
  
  const AttachmentsUpdated({required this.attachments});
  
  @override
  List<Object> get props => [attachments];
}

class MediaUploading extends ReportState {
  final double progress;
  final String fileName;
  
  const MediaUploading({
    required this.progress,
    required this.fileName,
  });
  
  @override
  List<Object> get props => [progress, fileName];
}

class MediaUploaded extends ReportState {
  final List<MediaAttachment> attachments;
  
  const MediaUploaded({required this.attachments});
  
  @override
  List<Object> get props => [attachments];
}

// LOCATION STATES
class LocationLoading extends ReportState {}

class LocationSelected extends ReportState {
  final LocationData location;
  
  const LocationSelected({required this.location});
  
  @override
  List<Object> get props => [location];
}

class LocationError extends ReportState {
  final String message;
  
  const LocationError({required this.message});
  
  @override
  List<Object> get props => [message];
}

// ERROR STATES
class ReportError extends ReportState {
  final String message;
  
  const ReportError({required this.message});
  
  @override
  List<Object> get props => [message];
}

class ReportValidationError extends ReportState {
  final Map<String, String> errors;
  
  const ReportValidationError({required this.errors});
  
  @override
  List<Object> get props => [errors];
}

class NetworkError extends ReportState {
  final String message;
  final bool isConnected;
  
  const NetworkError({
    required this.message,
    this.isConnected = false,
  });
  
  @override
  List<Object> get props => [message, isConnected];
}

// NOTIFICATION STATES
class NewReportNotification extends ReportState {
  final ReportEntity report;
  
  const NewReportNotification({required this.report});
  
  @override
  List<Object> get props => [report];
}

class ReportUpdateNotification extends ReportState {
  final String reportId;
  final String message;
  final ReportStatus? newStatus;
  
  const ReportUpdateNotification({
    required this.reportId,
    required this.message,
    this.newStatus,
  });
  
  @override
  List<Object> get props => [reportId, message, newStatus];
}

// OFFLINE STATES
class OfflineReportQueued extends ReportState {
  final String tempId;
  final String message;
  
  const OfflineReportQueued({
    required this.tempId,
    required this.message,
  });
  
  @override
  List<Object> get props => [tempId, message];
}

class OfflineReportsSyncing extends ReportState {
  final int pendingCount;
  final int syncedCount;
  
  const OfflineReportsSyncing({
    required this.pendingCount,
    required this.syncedCount,
  });
  
  @override
  List<Object> get props => [pendingCount, syncedCount];
}

class OfflineReportsSynced extends ReportState {
  final int syncedCount;
  
  const OfflineReportsSynced({required this.syncedCount});
  
  @override
  List<Object> get props => [syncedCount];
}