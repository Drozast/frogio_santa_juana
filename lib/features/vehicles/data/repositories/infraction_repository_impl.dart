// lib/features/inspector/data/repositories/infraction_repository_impl.dart
import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/infraction_entity.dart';
import '../../domain/repositories/infraction_repository.dart';
import '../datasources/infraction_remote_data_source.dart';
import '../models/infraction_model.dart';

class InfractionRepositoryImpl implements InfractionRepository {
  final InfractionRemoteDataSource remoteDataSource;

  InfractionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<InfractionEntity>>> getInfractionsByInspector(String inspectorId) async {
    try {
      final infractions = await remoteDataSource.getInfractionsByInspector(inspectorId);
      return Right(infractions);
    } catch (e) {
      return Left(ServerFailure('Error al obtener infracciones: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, InfractionEntity>> getInfractionById(String infractionId) async {
    try {
      final infraction = await remoteDataSource.getInfractionById(infractionId);
      return Right(infraction);
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
      final locationModel = LocationDataModel.fromEntity(location);
      
      final infractionId = await remoteDataSource.createInfraction(
        title: title,
        description: description,
        ordinanceRef: ordinanceRef,
        location: locationModel,
        offenderId: offenderId,
        offenderName: offenderName,
        offenderDocument: offenderDocument,
        inspectorId: inspectorId,
        evidence: evidence,
      );
      
      return Right(infractionId);
    } catch (e) {
      return Left(ServerFailure('Error al crear infracción: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateInfractionStatus(
    String infractionId, 
    InfractionStatus status, 
    String? comment,
  ) async {
    try {
      await remoteDataSource.updateInfractionStatus(
        infractionId, 
        status.name, 
        comment,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al actualizar estado: ${e.toString()}'));
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

  @override
  Future<Either<Failure, List<String>>> uploadInfractionImages(
    List<File> images, 
    String infractionId,
  ) async {
    try {
      final imageUrls = await remoteDataSource.uploadInfractionImages(images, infractionId);
      return Right(imageUrls);
    } catch (e) {
      return Left(ServerFailure('Error al subir imágenes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> addSignature(String infractionId, String signatureUrl) async {
    try {
      await remoteDataSource.addSignature(infractionId, signatureUrl);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al agregar firma: ${e.toString()}'));
    }
  }
}