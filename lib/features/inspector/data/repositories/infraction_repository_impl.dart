import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/infraction_entity.dart';
import '../../domain/repositories/infraction_repository.dart';
import '../datasources/infraction_remote_data_source.dart';
import '../models/infraction_model.dart';

class InfractionRepositoryImpl implements InfractionRepository {
  final InfractionRemoteDataSource remoteDataSource;

  InfractionRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<InfractionEntity>>> getInfractionsByInspector(
      String inspectorId) async {
    try {
      final infractions = await remoteDataSource.getInfractionsByInspector(inspectorId);
      return Right(infractions.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure('Error al obtener infracciones del inspector: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, InfractionEntity>> getInfractionById(String infractionId) async {
    try {
      final infraction = await remoteDataSource.getInfractionById(infractionId);
      return Right(infraction.toEntity());
    } catch (e) {
      return Left(ServerFailure('Error al obtener infracción: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> createInfraction({
    required String title,
    required String description,
    required String ordinanceRef,
    required LocationData location,
    required String offenderId,
    required String offenderName,
    required String offenderDocument,
    required String inspectorId,
    required List<File> evidence,
  }) async {
    try {
      // Subir imágenes de evidencia primero
      List<String> evidenceUrls = [];
      for (File file in evidence) {
        final url = await remoteDataSource.uploadEvidenceImage('temp', file);
        evidenceUrls.add(url);
      }

      // Crear el modelo de infracción
      final model = InfractionModel(
        id: '', // Se generará en el backend
        title: title,
        description: description,
        ordinanceRef: ordinanceRef,
        location: {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'address': location.address,
          'city': location.city,
          'region': location.region,
          'country': location.country,
        },
        offenderId: offenderId,
        offenderName: offenderName,
        offenderDocument: offenderDocument,
        inspectorId: inspectorId,
        muniId: '', // Debería venir del contexto
        evidence: evidenceUrls,
        signatures: [],
        status: 'pending',
        createdAt: DateTime.now(),
      );

      final createdInfraction = await remoteDataSource.createInfraction(model);
      return Right(createdInfraction.id);
    } catch (e) {
      return Left(ServerFailure('Error al crear infracción: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, InfractionEntity>> updateInfraction(
      InfractionEntity infraction) async {
    try {
      final model = InfractionModel.fromEntity(infraction);
      final updatedInfraction = await remoteDataSource.updateInfraction(model);
      return Right(updatedInfraction.toEntity());
    } catch (e) {
      return Left(ServerFailure('Error al actualizar infracción: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateInfractionStatus(
      String infractionId, InfractionStatus status, String? reason) async {
    try {
      // Convertir enum a string
      String statusString = _infractionStatusToString(status);
      await remoteDataSource.updateInfractionStatus(infractionId, statusString);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al actualizar estado de infracción: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> uploadInfractionImages(
      String infractionId, List<File> images) async {
    try {
      List<String> urls = [];
      for (File image in images) {
        final url = await remoteDataSource.uploadEvidenceImage(infractionId, image);
        urls.add(url);
      }
      return Right(urls);
    } catch (e) {
      return Left(ServerFailure('Error al subir imágenes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> addSignature(
      String infractionId, String signatureData) async {
    try {
      final url = await remoteDataSource.uploadSignature(infractionId, signatureData);
      return Right(url);
    } catch (e) {
      return Left(ServerFailure('Error al agregar firma: ${e.toString()}'));
    }
  }

  // Métodos auxiliares privados
  String _infractionStatusToString(InfractionStatus status) {
    switch (status) {
      case InfractionStatus.pending:
        return 'pending';
      case InfractionStatus.confirmed:
        return 'confirmed';
      case InfractionStatus.appealed:
        return 'appealed';
      case InfractionStatus.cancelled:
        return 'cancelled';
      case InfractionStatus.paid:
        return 'paid';
      default:
        return 'pending';
    }
  }

  // Métodos adicionales que podrían estar en la interfaz pero no son override obligatorios
  Future<Either<Failure, String>> uploadEvidenceImage(
      String infractionId, File image) async {
    try {
      final url = await remoteDataSource.uploadEvidenceImage(infractionId, image);
      return Right(url);
    } catch (e) {
      return Left(ServerFailure('Error al subir imagen de evidencia: ${e.toString()}'));
    }
  }

  Future<Either<Failure, String>> uploadSignature(
      String infractionId, String signatureData) async {
    try {
      final url = await remoteDataSource.uploadSignature(infractionId, signatureData);
      return Right(url);
    } catch (e) {
      return Left(ServerFailure('Error al subir firma: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteInfraction(String infractionId) async {
    try {
      await remoteDataSource.deleteInfraction(infractionId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al eliminar infracción: ${e.toString()}'));
    }
  }
}