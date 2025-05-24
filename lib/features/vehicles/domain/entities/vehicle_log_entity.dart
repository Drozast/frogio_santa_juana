import 'package:equatable/equatable.dart';

class VehicleLogEntity extends Equatable {
  final String id;
  final String vehicleId;
  final String driverId;
  final double startKm;
  final double? endKm;
  final DateTime startTime;
  final DateTime? endTime;
  final List<Map<String, double>>? route;
  final String? observations;
  final String? purpose;
  final DateTime createdAt;

  const VehicleLogEntity({
    required this.id,
    required this.vehicleId,
    required this.driverId,
    required this.startKm,
    this.endKm,
    required this.startTime,
    this.endTime,
    this.route,
    this.observations,
    this.purpose,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        vehicleId,
        driverId,
        startKm,
        endKm,
        startTime,
        endTime,
        route,
        observations,
        purpose,
        createdAt,
      ];
}