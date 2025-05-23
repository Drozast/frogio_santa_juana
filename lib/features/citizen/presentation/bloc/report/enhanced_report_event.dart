// lib/features/citizen/presentation/bloc/report/enhanced_report_event.dart
import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../../domain/entities/enhanced_report_entity.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();
  
  @override
  List<Object?> get props => [];
}

// LOAD EVENTS
class LoadReportsEvent extends ReportEvent {
  final String userId;
  
  const LoadReportsEvent({required this.userId});
  
  @override
  List<Object> get props => [userId];
}

class LoadReportDetailsEvent extends ReportEvent {
  final String reportId;
  
  const LoadReportDetailsEvent({required this.reportId});
  
  @override
  List<Object> get props => [reportId];
}

class LoadReportsByStatusEvent extends ReportEvent {
  final ReportStatus status;
  final String? muniId;
  final String? assignedTo;
  
  const LoadReportsByStatusEvent({
    required this.status,
    this.muniId,
    this.assignedTo,
  });
  
  @override
  List<Object?> get props => [status, muniId, assignedTo];
}

// CREATE EVENTS
class CreateReportEvent extends ReportEvent {
  final String title;
  final String description;
  final String category;
  final String? references;
  final LocationData location;
  final String userId;
  final Priority priority;
  final List<File> attachments;
  
  const CreateReportEvent({
    required this.title,
    required this.description,
    required this.category,
    this.references,
    required this.location,
    required this.userId,
    this.priority = Priority.medium,
    this.attachments = const [],
  });
  
  @override
  List<Object?> get props => [
    title, description, category, references, 
    location, userId, priority, attachments
  ];
}

// STATUS EVENTS
class UpdateReportStatusEvent extends ReportEvent {
  final String reportId;
  final ReportStatus status;
  final String? comment;
  final String userId;
  
  const UpdateReportStatusEvent({
    required this.reportId,
    required this.status,
    this.comment,
    required this.userId,
  });
  
  @override
  List<Object?> get props => [reportId, status, comment, userId];
}

// RESPONSE EVENTS
class AddReportResponseEvent extends ReportEvent {
  final String reportId;
  final String responderId;
  final String responderName;
  final String message;
  final List<File>? attachments;
  final bool isPublic;
  
  const AddReportResponseEvent({
    required this.reportId,
    required this.responderId,
    required this.responderName,
    required this.message,
    this.attachments,
    this.isPublic = true,
  });
  
  @override
  List<Object?> get props => [
    reportId, responderId, responderName, 
    message, attachments, isPublic
  ];
}

// FILTER EVENTS
class FilterReportsEvent extends ReportEvent {
  final String filter;
  
  const FilterReportsEvent({required this.filter});
  
  @override
  List<Object> get props => [filter];
}

class SearchReportsEvent extends ReportEvent {
  final String query;
  
  const SearchReportsEvent({required this.query});
  
  @override
  List<Object> get props => [query];
}

// ASSIGNMENT EVENTS
class AssignReportEvent extends ReportEvent {
  final String reportId;
  final String assignedToId;
  final String assignedById;
  
  const AssignReportEvent({
    required this.reportId,
    required this.assignedToId,
    required this.assignedById,
  });
  
  @override
  List<Object> get props => [reportId, assignedToId, assignedById];
}

// REAL-TIME EVENTS
class StartWatchingUserReportsEvent extends ReportEvent {
  final String userId;
  
  const StartWatchingUserReportsEvent({required this.userId});
  
  @override
  List<Object> get props => [userId];
}

class StartWatchingStatusReportsEvent extends ReportEvent {
  final ReportStatus status;
  final String muniId;
  
  const StartWatchingStatusReportsEvent({
    required this.status,
    required this.muniId,
  });
  
  @override
  List<Object> get props => [status, muniId];
}

class StopWatchingReportsEvent extends ReportEvent {}

// MEDIA EVENTS
class AddAttachmentEvent extends ReportEvent {
  final File file;
  final MediaType type;
  
  const AddAttachmentEvent({
    required this.file,
    required this.type,
  });
  
  @override
  List<Object> get props => [file, type];
}

class RemoveAttachmentEvent extends ReportEvent {
  final int index;
  
  const RemoveAttachmentEvent({required this.index});
  
  @override
  List<Object> get props => [index];
}

class ClearAttachmentsEvent extends ReportEvent {}

// LOCATION EVENTS
class SetLocationEvent extends ReportEvent {
  final LocationData location;
  
  const SetLocationEvent({required this.location});
  
  @override
  List<Object> get props => [location];
}

class GetCurrentLocationEvent extends ReportEvent {}

class SelectLocationOnMapEvent extends ReportEvent {
  final double latitude;
  final double longitude;
  
  const SelectLocationOnMapEvent({
    required this.latitude,
    required this.longitude,
  });
  
  @override
  List<Object> get props => [latitude, longitude];
}

// UTILITY EVENTS
class ResetReportStateEvent extends ReportEvent {}

class RefreshReportsEvent extends ReportEvent {}