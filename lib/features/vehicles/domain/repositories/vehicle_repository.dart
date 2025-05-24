import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/vehicle_entity.dart';
import '../entities/vehicle_log_entity.dart';

abstract class VehicleRepository {
  /// Obtiene la lista de vehículos disponibles
  Future<Either<Failure, List<VehicleEntity>>> getVehicles(String muniId);

  /// Inicia el uso de un vehículo
  Future<Either<Failure, VehicleLogEntity>> startVehicleUsage({
    required String vehicleId,
    required String driverId,
    required double startKm,
    String? purpose,
  });

  /// Finaliza el uso de un vehículo
  Future<Either<Failure, VehicleLogEntity>> endVehicleUsage({
    required String logId,
    required double endKm,
    String? observations,
    List<Map<String, double>>? route,
  });

  /// Obtiene el historial de uso de un vehículo
  Future<Either<Failure, List<VehicleLogEntity>>> getVehicleLogs(String vehicleId);

  /// Obtiene el uso actual de un vehículo (si existe)
  Future<Either<Failure, VehicleLogEntity?>> getCurrentVehicleUsage(String vehicleId);
}