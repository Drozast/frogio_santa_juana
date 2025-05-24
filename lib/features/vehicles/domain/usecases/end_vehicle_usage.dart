import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/vehicle_log_entity.dart';
import '../repositories/vehicle_repository.dart';

class EndVehicleUsage extends UseCase<VehicleLogEntity, EndVehicleUsageParams> {
  final VehicleRepository repository;

  EndVehicleUsage({required this.repository});

  @override
  Future<Either<Failure, VehicleLogEntity>> call(EndVehicleUsageParams params) async {
    return await repository.endVehicleUsage(
      logId: params.logId,
      endKm: params.endKm,
      observations: params.observations,
      route: params.route,
    );
  }
}

class EndVehicleUsageParams extends Equatable {
  final String logId;
  final double endKm;
  final String? observations;
  final List<Map<String, double>>? route;

  const EndVehicleUsageParams({
    required this.logId,
    required this.endKm,
    this.observations,
    this.route,
  });

  @override
  List<Object?> get props => [logId, endKm, observations, route];
}