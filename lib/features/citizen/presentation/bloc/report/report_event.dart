// lib/features/citizen/presentation/bloc/report/report_event.dart
import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../../domain/entities/report_entity.dart';

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

class LoadReportDetailsEvent extends ReportEvent {
  final String reportId;
  
  const LoadReportDetailsEvent({required this.reportId});
  
  @override
  List<Object> get props => [reportId];
}

class CreateReportEvent extends ReportEvent {
  final String title;
  final String description;
  final String category;
  final LocationData location;
  final String userId;
  final List<File> images;
  
  const CreateReportEvent({
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.userId,
    required this.images,
  });
  
  @override
  List<Object> get props => [title, description, category, location, userId, images];
}

class FilterReportsEvent extends ReportEvent {
  final String filter;
  
  const FilterReportsEvent({required this.filter});
  
  @override
  List<Object> get props => [filter];
}