// lib/features/citizen/presentation/bloc/report/enhanced_report_event.dart
import 'package:equatable/equatable.dart';

import '../../../domain/usecases/reports/enhanced_report_use_cases.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

class LoadReportsEvent extends ReportEvent {
  final String userId;

  const LoadReportsEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class LoadReportByIdEvent extends ReportEvent {
  final String reportId;

  const LoadReportByIdEvent({required this.reportId});

  @override
  List<Object> get props => [reportId];
}

class CreateReportEvent extends ReportEvent {
  final CreateEnhancedReportParams params;

  const CreateReportEvent({required this.params});

  @override
  List<Object> get props => [params];
}

class UpdateReportStatusEvent extends ReportEvent {
  final UpdateReportStatusParams params;

  const UpdateReportStatusEvent({required this.params});

  @override
  List<Object> get props => [params];
}

class AddReportResponseEvent extends ReportEvent {
  final AddReportResponseParams params;

  const AddReportResponseEvent({required this.params});

  @override
  List<Object> get props => [params];
}

class LoadReportsByStatusEvent extends ReportEvent {
  final GetReportsByStatusParams params;

  const LoadReportsByStatusEvent({required this.params});

  @override
  List<Object> get props => [params];
}

class AssignReportEvent extends ReportEvent {
  final AssignReportParams params;

  const AssignReportEvent({required this.params});

  @override
  List<Object> get props => [params];
}

class RefreshReportsEvent extends ReportEvent {
  final String userId;

  const RefreshReportsEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}