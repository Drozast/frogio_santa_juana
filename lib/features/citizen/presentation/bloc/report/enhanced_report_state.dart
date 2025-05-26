// lib/features/citizen/presentation/bloc/report/enhanced_report_state.dart
import 'package:equatable/equatable.dart';

import '../../../domain/entities/enhanced_report_entity.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportCreating extends ReportState {}

class ReportsLoaded extends ReportState {
  final List<ReportEntity> reports;

  const ReportsLoaded({required this.reports});

  @override
  List<Object> get props => [reports];
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

class ReportError extends ReportState {
  final String message;

  const ReportError({required this.message});

  @override
  List<Object> get props => [message];
}

class ReportOperationSuccess extends ReportState {
  final String message;

  const ReportOperationSuccess({required this.message});

  @override
  List<Object> get props => [message];
}