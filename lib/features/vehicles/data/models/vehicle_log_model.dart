import 'package:equatable/equatable.dart';

import '../../domain/entities/vehicle_log_entity.dart';

class VehicleLogModel extends Equatable {
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

  const VehicleLogModel({
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

  factory VehicleLogModel.fromJson(Map<String, dynamic> json) {
    return VehicleLogModel(
      id: json['id'] ?? '',
      vehicleId: json['vehicleId'] ?? '',
      driverId: json['driverId'] ?? '',
      startKm: (json['startKm'] ?? 0).toDouble(),
      endKm: json['endKm'] != null ? (json['endKm']).toDouble() : null,
      startTime: (json['startTime'] as dynamic).toDate() ?? DateTime.now(),
      endTime: json['endTime'] != null 
          ? (json['endTime'] as dynamic).toDate() 
          : null,
      route: json['route'] != null 
          ? List<Map<String, double>>.from(
              (json['route'] as List).map((item) => 
                Map<String, double>.from(item.map((key, value) => 
                  MapEntry(key, value.toDouble())
                ))
              )
            )
          : null,
      observations: json['observations'],
      purpose: json['purpose'],
      createdAt: (json['createdAt'] as dynamic).toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'driverId': driverId,
      'startKm': startKm,
      'endKm': endKm,
      'startTime': startTime,
      'endTime': endTime,
      'route': route,
      'observations': observations,
      'purpose': purpose,
      'createdAt': createdAt,
    };
  }

  VehicleLogEntity toEntity() {
    return VehicleLogEntity(
      id: id,
      vehicleId: vehicleId,
      driverId: driverId,
      startKm: startKm,
      endKm: endKm,
      startTime: startTime,
      endTime: endTime,
      route: route,
      observations: observations,
      purpose: purpose,
      createdAt: createdAt,
    );
  }

  factory VehicleLogModel.fromEntity(VehicleLogEntity entity) {
    return VehicleLogModel(
      id: entity.id,
      vehicleId: entity.vehicleId,
      driverId: entity.driverId,
      startKm: entity.startKm,
      endKm: entity.endKm,
      startTime: entity.startTime,
      endTime: entity.endTime,
      route: entity.route,
      observations: entity.observations,
      purpose: entity.purpose,
      createdAt: entity.createdAt,
    );
  }

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