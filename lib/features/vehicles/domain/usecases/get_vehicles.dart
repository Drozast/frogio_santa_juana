// lib/features/vehicles/domain/usecases/get_vehicles.dart
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

class GetVehicles implements UseCase<List<VehicleEntity>, String> {
  final VehicleRepository repository;

  GetVehicles(this.repository);

  @override
  Future<Either<Failure, List<VehicleEntity>>> call(String muniId) async {
    try {
      if (muniId.isEmpty) {
        return const Left(ServerFailure('ID de municipalidad requerido'));
      }

      return await repository.getVehicles(muniId);
    } catch (e) {
      return Left(ServerFailure('Error al obtener vehículos: ${e.toString()}'));
    }
  }
}

// lib/features/vehicles/domain/usecases/start_vehicle_usage.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

class StartVehicleUsage implements UseCase<String, StartVehicleUsageParams> {
  final VehicleRepository repository;

  StartVehicleUsage(this.repository);

  @override
  Future<Either<Failure, String>> call(StartVehicleUsageParams params) async {
    try {
      // Validaciones
      final validationResult = _validateParams(params);
      if (validationResult != null) {
        return Left(ServerFailure(validationResult));
      }

      return await repository.startVehicleUsage(
        vehicleId: params.vehicleId,
        driverId: params.driverId,
        driverName: params.driverName,
        startKm: params.startKm,
        usageType: params.usageType,
        purpose: params.purpose,
      );
    } catch (e) {
      return Left(ServerFailure('Error al iniciar uso de vehículo: ${e.toString()}'));
    }
  }

  String? _validateParams(StartVehicleUsageParams params) {
    if (params.vehicleId.isEmpty) {
      return 'ID de vehículo requerido';
    }

    if (params.driverId.isEmpty) {
      return 'ID de conductor requerido';
    }

    if (params.driverName.trim().isEmpty) {
      return 'Nombre del conductor requerido';
    }

    if (params.startKm < 0) {
      return 'Kilometraje inicial inválido';
    }

    return null;
  }
}

class StartVehicleUsageParams extends Equatable {
  final String vehicleId;
  final String driverId;
  final String driverName;
  final double startKm;
  final UsageType usageType;
  final String? purpose;

  const StartVehicleUsageParams({
    required this.vehicleId,
    required this.driverId,
    required this.driverName,
    required this.startKm,
    required this.usageType,
    this.purpose,
  });

  @override
  List<Object?> get props => [
    vehicleId, driverId, driverName, startKm, usageType, purpose,
  ];
}

// lib/features/vehicles/domain/usecases/end_vehicle_usage.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/vehicle_repository.dart';

class EndVehicleUsage implements UseCase<void, EndVehicleUsageParams> {
  final VehicleRepository repository;

  EndVehicleUsage(this.repository);

  @override
  Future<Either<Failure, void>> call(EndVehicleUsageParams params) async {
    try {
      // Validaciones
      final validationResult = _validateParams(params);
      if (validationResult != null) {
        return Left(ServerFailure(validationResult));
      }

      return await repository.endVehicleUsage(
        logId: params.logId,
        endKm: params.endKm,
        observations: params.observations,
        attachments: params.attachments,
      );
    } catch (e) {
      return Left(ServerFailure('Error al finalizar uso de vehículo: ${e.toString()}'));
    }
  }

  String? _validateParams(EndVehicleUsageParams params) {
    if (params.logId.isEmpty) {
      return 'ID de registro requerido';
    }

    if (params.endKm < 0) {
      return 'Kilometraje final inválido';
    }

    return null;
  }
}

class EndVehicleUsageParams extends Equatable {
  final String logId;
  final double endKm;
  final String? observations;
  final List<String>? attachments;

  const EndVehicleUsageParams({
    required this.logId,
    required this.endKm,
    this.observations,
    this.attachments,
  });

  @override
  List<Object?> get props => [logId, endKm, observations, attachments];
}