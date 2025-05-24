import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/vehicle_log_entity.dart';
import '../repositories/vehicle_repository.dart';

class StartVehicleUsage extends UseCase<VehicleLogEntity, StartVehicleUsageParams> {
  final VehicleRepository repository;

  StartVehicleUsage({required this.repository});

  @override
  Future<Either<Failure, VehicleLogEntity>> call(StartVehicleUsageParams params) async {
    return await repository.startVehicleUsage(
      vehicleId: params.vehicleId,
      driverId: params.driverId,
      startKm: params.startKm,
      purpose: params.purpose,
    );
  }
}

class StartVehicleUsageParams extends Equatable {
  final String vehicleId;
  final String driverId;
  final double startKm;
  final String? purpose;

  const StartVehicleUsageParams({
    required this.vehicleId,
    required this.driverId,
    required this.startKm,
    this.purpose,
  });

  @override
  List<Object?> get props => [vehicleId, driverId, startKm, purpose];
}