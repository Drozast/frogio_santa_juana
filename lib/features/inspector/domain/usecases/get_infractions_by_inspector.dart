// lib/features/inspector/domain/usecases/get_infractions_by_inspector.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/infraction_entity.dart';
import '../repositories/infraction_repository.dart';

class GetInfractionsByInspector implements UseCase<List<InfractionEntity>, String> {
  final InfractionRepository repository;

  GetInfractionsByInspector(this.repository);

  @override
  Future<Either<Failure, List<InfractionEntity>>> call(String inspectorId) {
    return repository.getInfractionsByInspector(inspectorId);
  }
}

// lib/features/inspector/domain/usecases/create_infraction.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/infraction_entity.dart';
import '../repositories/infraction_repository.dart';

class CreateInfraction implements UseCase<String, CreateInfractionParams> {
  final InfractionRepository repository;

  CreateInfraction(this.repository);

  @override
  Future<Either<Failure, String>> call(CreateInfractionParams params) {
    return repository.createInfraction(
      title: params.title,
      description: params.description,
      ordinanceRef: params.ordinanceRef,
      location: params.location,
      offenderId: params.offenderId,
      offenderName: params.offenderName,
      offenderDocument: params.offenderDocument,
      inspectorId: params.inspectorId,
      evidence: params.evidence,
    );
  }
}

class CreateInfractionParams extends Equatable {
  final String title;
  final String description;
  final String ordinanceRef;
  final LocationData location;
  final String offenderId;
  final String offenderName;
  final String offenderDocument;
  final String inspectorId;
  final List<File> evidence;

  const CreateInfractionParams({
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
  List<Object?> get props => [title, description, ordinanceRef, location, offenderId, offenderName, offenderDocument, inspectorId, evidence];
}

// lib/features/inspector/domain/usecases/update_infraction_status.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/infraction_entity.dart';
import '../repositories/infraction_repository.dart';

class UpdateInfractionStatus implements UseCase<void, UpdateInfractionStatusParams> {
  final InfractionRepository repository;

  UpdateInfractionStatus(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateInfractionStatusParams params) {
    return repository.updateInfractionStatus(params.infractionId, params.status, params.comment);
  }
}

class UpdateInfractionStatusParams extends Equatable {
  final String infractionId;
  final InfractionStatus status;
  final String? comment;

  const UpdateInfractionStatusParams({
    required this.infractionId,
    required this.status,
    this.comment,
  });

  @override
  List<Object?> get props => [infractionId, status, comment];
}

// lib/features/inspector/domain/usecases/upload_infraction_image.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/infraction_repository.dart';

class UploadInfractionImage implements UseCase<List<String>, UploadInfractionImageParams> {
  final InfractionRepository repository;

  UploadInfractionImage(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(UploadInfractionImageParams params) {
    return repository.uploadInfractionImages(params.images, params.infractionId);
  }
}

class UploadInfractionImageParams extends Equatable {
  final List<File> images;
  final String infractionId;

  const UploadInfractionImageParams({
    required this.images,
    required this.infractionId,
  });

  @override
  List<Object> get props => [images, infractionId];
}