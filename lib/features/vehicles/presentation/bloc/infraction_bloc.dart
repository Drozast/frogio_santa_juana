// lib/features/inspector/presentation/bloc/infraction_bloc.dart
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/infraction_entity.dart';
import '../../domain/usecases/create_infraction.dart';
import '../../domain/usecases/get_infractions_by_inspector.dart';
import '../../domain/usecases/update_infraction_status.dart';
import '../../domain/usecases/upload_infraction_image.dart';

// Events
abstract class InfractionEvent extends Equatable {
  const InfractionEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadInfractionsByInspectorEvent extends InfractionEvent {
  final String inspectorId;
  
  const LoadInfractionsByInspectorEvent({required this.inspectorId});
  
  @override
  List<Object> get props => [inspectorId];
}

class CreateInfractionEvent extends InfractionEvent {
  final String title;
  final String description;
  final String ordinanceRef;
  final LocationData location;
  final String offenderId;
  final String offenderName;
  final String offenderDocument;
  final String inspectorId;
  final List<File> evidence;
  
  const CreateInfractionEvent({
    required this.title,
    required this.description,
    required this.ordinanceRef,
    required this.location,
    required this.offenderId,
    required this.offenderName,
    required this.offenderDocument,
    required this.inspectorId,
    required this.evidence,
  });
  
  @override
  List<Object> get props => [
    title, description, ordinanceRef, location, offenderId,
    offenderName, offenderDocument, inspectorId, evidence,
  ];
}

class UpdateInfractionStatusEvent extends InfractionEvent {
  final String infractionId;
  final InfractionStatus status;
  final String? comment;
  
  const UpdateInfractionStatusEvent({
    required this.infractionId,
    required this.status,
    this.comment,
  });
  
  @override
  List<Object?> get props => [infractionId, status, comment];
}

class UploadInfractionImagesEvent extends InfractionEvent {
  final List<File> images;
  final String infractionId;
  
  const UploadInfractionImagesEvent({
    required this.images,
    required this.infractionId,
  });
  
  @override
  List<Object> get props => [images, infractionId];
}

class FilterInfractionsEvent extends InfractionEvent {
  final InfractionStatus? status;
  final String? searchQuery;
  
  const FilterInfractionsEvent({
    this.status,
    this.searchQuery,
  });
  
  @override
  List<Object?> get props => [status, searchQuery];
}

class RefreshInfractionsEvent extends InfractionEvent {
  final String inspectorId;
  
  const RefreshInfractionsEvent({required this.inspectorId});
  
  @override
  List<Object> get props => [inspectorId];
}

// States
abstract class InfractionState extends Equatable {
  const InfractionState();
  
  @override
  List<Object?> get props => [];
}

class InfractionInitial extends InfractionState {}

class InfractionLoading extends InfractionState {
  final String? message;
  
  const InfractionLoading({this.message});
  
  @override
  List<Object?> get props => [message];
}

class InfractionsLoaded extends InfractionState {
  final List<InfractionEntity> infractions;
  final List<InfractionEntity> filteredInfractions;
  final InfractionStatus? currentFilter;
  final String? searchQuery;
  final Map<String, int> statusCounts;
  
  const InfractionsLoaded({
    required this.infractions,
    List<InfractionEntity>? filteredInfractions,
    this.currentFilter,
    this.searchQuery,
    required this.statusCounts,
  }) : filteredInfractions = filteredInfractions ?? infractions;
  
  @override
  List<Object?> get props => [
    infractions, filteredInfractions, currentFilter, searchQuery, statusCounts,
  ];
  
  InfractionsLoaded copyWith({
    List<InfractionEntity>? infractions,
    List<InfractionEntity>? filteredInfractions,
    InfractionStatus? currentFilter,
    String? searchQuery,
    Map<String, int>? statusCounts,
  }) {
    return InfractionsLoaded(
      infractions: infractions ?? this.infractions,
      filteredInfractions: filteredInfractions ?? this.filteredInfractions,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      statusCounts: statusCounts ?? this.statusCounts,
    );
  }
}

class InfractionCreating extends InfractionState {
  final double progress;
  final String currentTask;
  
  const InfractionCreating({
    required this.progress,
    required this.currentTask,
  });
  
  @override
  List<Object> get props => [progress, currentTask];
}

class InfractionCreated extends InfractionState {
  final String infractionId;
  final String message;
  
  const InfractionCreated({
    required this.infractionId,
    required this.message,
  });
  
  @override
  List<Object> get props => [infractionId, message];
}

class InfractionStatusUpdating extends InfractionState {
  final String infractionId;
  
  const InfractionStatusUpdating({required this.infractionId});
  
  @override
  List<Object> get props => [infractionId];
}

class InfractionStatusUpdated extends InfractionState {
  final String infractionId;
  final InfractionStatus newStatus;
  final String message;
  
  const InfractionStatusUpdated({
    required this.infractionId,
    required this.newStatus,
    required this.message,
  });
  
  @override
  List<Object> get props => [infractionId, newStatus, message];
}

class ImagesUploading extends InfractionState {
  final double progress;
  final int currentImage;
  final int totalImages;
  
  const ImagesUploading({
    required this.progress,
    required this.currentImage,
    required this.totalImages,
  });
  
  @override
  List<Object> get props => [progress, currentImage, totalImages];
}

class ImagesUploaded extends InfractionState {
  final List<String> imageUrls;
  final String message;
  
  const ImagesUploaded({
    required this.imageUrls,
    required this.message,
  });
  
  @override
  List<Object> get props => [imageUrls, message];
}

class InfractionError extends InfractionState {
  final String message;
  final String? errorCode;
  final bool canRetry;
  
  const InfractionError({
    required this.message,
    this.errorCode,
    this.canRetry = true,
  });
  
  @override
  List<Object?> get props => [message, errorCode, canRetry];
}

// BLoC
class InfractionBloc extends Bloc<InfractionEvent, InfractionState> {
  final GetInfractionsByInspector getInfractionsByInspector;
  final CreateInfraction createInfraction;
  final UpdateInfractionStatus updateInfractionStatus;
  final UploadInfractionImage uploadInfractionImage;

  InfractionBloc({
    required this.getInfractionsByInspector,
    required this.createInfraction,
    required this.updateInfractionStatus,
    required this.uploadInfractionImage,
  }) : super(InfractionInitial()) {
    on<LoadInfractionsByInspectorEvent>(_onLoadInfractionsByInspector);
    on<CreateInfractionEvent>(_onCreateInfraction);
    on<UpdateInfractionStatusEvent>(_onUpdateInfractionStatus);
    on<UploadInfractionImagesEvent>(_onUploadInfractionImages);
    on<FilterInfractionsEvent>(_onFilterInfractions);
    on<RefreshInfractionsEvent>(_onRefreshInfractions);
  }

  Future<void> _onLoadInfractionsByInspector(
    LoadInfractionsByInspectorEvent event,
    Emitter<InfractionState> emit,
  ) async {
    if (state is! InfractionsLoaded) {
      emit(const InfractionLoading(message: 'Cargando infracciones...'));
    }
    
    try {
      final result = await getInfractionsByInspector(event.inspectorId);
      
      result.fold(
        (failure) => emit(InfractionError(message: failure.message)),
        (infractions) {
          final statusCounts = _calculateStatusCounts(infractions);
          
          emit(InfractionsLoaded(
            infractions: infractions,
            statusCounts: statusCounts,
          ));
        },
      );
    } catch (e) {
      emit(InfractionError(
        message: 'Error inesperado: ${e.toString()}',
      ));
    }
  }

  Future<void> _onCreateInfraction(
    CreateInfractionEvent event,
    Emitter<InfractionState> emit,
  ) async {
    emit(const InfractionCreating(
      progress: 0.1,
      currentTask: 'Preparando infracción...',
    ));

    try {
      emit(const InfractionCreating(
        progress: 0.3,
        currentTask: 'Subiendo evidencia...',
      ));

      final result = await createInfraction(
        CreateInfractionParams(
          title: event.title,
          description: event.description,
          ordinanceRef: event.ordinanceRef,
          location: event.location,
          offenderId: event.offenderId,
          offenderName: event.offenderName,
          offenderDocument: event.offenderDocument,
          inspectorId: event.inspectorId,
          evidence: event.evidence,
        ),
      );

      result.fold(
        (failure) => emit(InfractionError(message: failure.message)),
        (infractionId) {
          emit(const InfractionCreating(
            progress: 1.0,
            currentTask: 'Completado',
          ));
          
          emit(InfractionCreated(
            infractionId: infractionId,
            message: 'Infracción creada exitosamente',
          ));
        },
      );
    } catch (e) {
      emit(InfractionError(
        message: 'Error al crear infracción: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateInfractionStatus(
    UpdateInfractionStatusEvent event,
    Emitter<InfractionState> emit,
  ) async {
    emit(InfractionStatusUpdating(infractionId: event.infractionId));
    
    try {
      final result = await updateInfractionStatus(
        UpdateInfractionStatusParams(
          infractionId: event.infractionId,
          status: event.status,
          comment: event.comment,
        ),
      );
      
      result.fold(
        (failure) => emit(InfractionError(message: failure.message)),
        (_) => emit(InfractionStatusUpdated(
          infractionId: event.infractionId,
          newStatus: event.status,
          message: 'Estado actualizado a ${event.status.displayName}',
        )),
      );
    } catch (e) {
      emit(InfractionError(
        message: 'Error al actualizar estado: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUploadInfractionImages(
    UploadInfractionImagesEvent event,
    Emitter<InfractionState> emit,
  ) async {
    emit(ImagesUploading(
      progress: 0.0,
      currentImage: 0,
      totalImages: event.images.length,
    ));

    try {
      final result = await uploadInfractionImage(
        UploadInfractionImageParams(
          images: event.images,
          infractionId: event.infractionId,
        ),
      );

      result.fold(
        (failure) => emit(InfractionError(message: failure.message)),
        (imageUrls) => emit(ImagesUploaded(
          imageUrls: imageUrls,
          message: 'Imágenes subidas exitosamente',
        )),
      );
    } catch (e) {
      emit(InfractionError(
        message: 'Error al subir imágenes: ${e.toString()}',
      ));
    }
  }

  void _onFilterInfractions(
    FilterInfractionsEvent event,
    Emitter<InfractionState> emit,
  ) {
    if (state is InfractionsLoaded) {
      final currentState = state as InfractionsLoaded;
      
      List<InfractionEntity> filteredInfractions = currentState.infractions;
      
      // Aplicar filtro por estado
      if (event.status != null) {
        filteredInfractions = filteredInfractions
            .where((infraction) => infraction.status == event.status)
            .toList();
      }
      
      // Aplicar filtro de búsqueda
      if (event.searchQuery != null && event.searchQuery!.isNotEmpty) {
        filteredInfractions = filteredInfractions
            .where((infraction) =>
                infraction.title.toLowerCase().contains(event.searchQuery!.toLowerCase()) ||
                infraction.description.toLowerCase().contains(event.searchQuery!.toLowerCase()) ||
                infraction.offenderName.toLowerCase().contains(event.searchQuery!.toLowerCase()) ||
                infraction.offenderDocument.contains(event.searchQuery!))
            .toList();
      }
      
      emit(currentState.copyWith(
        filteredInfractions: filteredInfractions,
        currentFilter: event.status,
        searchQuery: event.searchQuery,
      ));
    }
  }

  Future<void> _onRefreshInfractions(
    RefreshInfractionsEvent event,
    Emitter<InfractionState> emit,
  ) async {
    add(LoadInfractionsByInspectorEvent(inspectorId: event.inspectorId));
  }

  Map<String, int> _calculateStatusCounts(List<InfractionEntity> infractions) {
    final counts = <String, int>{};
    
    for (final infraction in infractions) {
      final status = infraction.status.name;
      counts[status] = (counts[status] ?? 0) + 1;
    }
    
    return counts;
  }
}