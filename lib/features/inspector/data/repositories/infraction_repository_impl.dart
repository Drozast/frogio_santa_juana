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
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, InfractionEntity>> getInfractionById(String infractionId) async {
    try {
      final infraction = await remoteDataSource.getInfractionById(infractionId);
      return Right(infraction.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, InfractionEntity>> createInfraction(
      InfractionEntity infraction) async {
    try {
      final model = InfractionModel.fromEntity(infraction);
      final createdInfraction = await remoteDataSource.createInfraction(model);
      return Right(createdInfraction.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
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
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateInfractionStatus(
      String infractionId, String status) async {
    try {
      await remoteDataSource.updateInfractionStatus(infractionId, status);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadEvidenceImage(
      String infractionId, File image) async {
    try {
      final url = await remoteDataSource.uploadEvidenceImage(infractionId, image);
      return Right(url);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadSignature(
      String infractionId, String signatureData) async {
    try {
      final url = await remoteDataSource.uploadSignature(infractionId, signatureData);
      return Right(url);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteInfraction(String infractionId) async {
    try {
      await remoteDataSource.deleteInfraction(infractionId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}