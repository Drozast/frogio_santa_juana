// lib/features/vehicles/domain/entities/vehicle_entity.dart
import 'package:equatable/equatable.dart';

class VehicleEntity extends Equatable {
  final String id;
  final String plate;
  final String model;
  final String brand;
  final int year;
  final String muniId;
  final VehicleStatus status;
  final VehicleType type;
  final double currentKm;
  final DateTime? lastMaintenance;
  final DateTime? nextMaintenance;
  final String? currentDriverId;
  final String? currentDriverName;
  final List<String> assignedAreas;
  final DateTime createdAt;
  final DateTime updatedAt;
  final VehicleSpecs specs;

  const VehicleEntity({
    required this.id,
    required this.plate,
    required this.model,
    required this.brand,
    required this.year,
    required this.muniId,
    required this.status,
    required this.type,
    required this.currentKm,
    this.lastMaintenance,
    this.nextMaintenance,
    this.currentDriverId,
    this.currentDriverName,
    required this.assignedAreas,
    required this.createdAt,
    required this.updatedAt,
    required this.specs,
  });

  @override
  List<Object?> get props => [
    id, plate, model, brand, year, muniId, status, type, currentKm,
    lastMaintenance, nextMaintenance, currentDriverId, currentDriverName,
    assignedAreas, createdAt, updatedAt, specs,
  ];

  VehicleEntity copyWith({
    String? id,
    String? plate,
    String? model,
    String? brand,
    int? year,
    String? muniId,
    VehicleStatus? status,
    VehicleType? type,
    double? currentKm,
    DateTime? lastMaintenance,
    DateTime? nextMaintenance,
    String? currentDriverId,
    String? currentDriverName,
    List<String>? assignedAreas,
    DateTime? createdAt,
    DateTime? updatedAt,
    VehicleSpecs? specs,
  }) {
    return VehicleEntity(
      id: id ?? this.id,
      plate: plate ?? this.plate,
      model: model ?? this.model,
      brand: brand ?? this.brand,
      year: year ?? this.year,
      muniId: muniId ?? this.muniId,
      status: status ?? this.status,
      type: type ?? this.type,
      currentKm: currentKm ?? this.currentKm,
      lastMaintenance: lastMaintenance ?? this.lastMaintenance,
      nextMaintenance: nextMaintenance ?? this.nextMaintenance,
      currentDriverId: currentDriverId ?? this.currentDriverId,
      currentDriverName: currentDriverName ?? this.currentDriverName,
      assignedAreas: assignedAreas ?? this.assignedAreas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      specs: specs ?? this.specs,
    );
  }

  bool get isAvailable => status == VehicleStatus.available;
  bool get isInUse => status == VehicleStatus.inUse;
  bool get needsMaintenance => 
      nextMaintenance != null && DateTime.now().isAfter(nextMaintenance!);
}

enum VehicleStatus {
  available,
  inUse,
  maintenance,
  outOfService;

  String get displayName {
    switch (this) {
      case VehicleStatus.available:
        return 'Disponible';
      case VehicleStatus.inUse:
        return 'En Uso';
      case VehicleStatus.maintenance:
        return 'En Mantenimiento';
      case VehicleStatus.outOfService:
        return 'Fuera de Servicio';
    }
  }
}

enum VehicleType {
  car,
  motorcycle,
  truck,
  van,
  bicycle;

  String get displayName {
    switch (this) {
      case VehicleType.car:
        return 'Automóvil';
      case VehicleType.motorcycle:
        return 'Motocicleta';
      case VehicleType.truck:
        return 'Camión';
      case VehicleType.van:
        return 'Furgoneta';
      case VehicleType.bicycle:
        return 'Bicicleta';
    }
  }
}

class VehicleSpecs extends Equatable {
  final String? color;
  final String? engine;
  final String? transmission;
  final String? fuelType;
  final double? fuelCapacity;
  final int? seatingCapacity;
  final Map<String, dynamic>? additionalInfo;

  const VehicleSpecs({
    this.color,
    this.engine,
    this.transmission,
    this.fuelType,
    this.fuelCapacity,
    this.seatingCapacity,
    this.additionalInfo,
  });

  @override
  List<Object?> get props => [
    color, engine, transmission, fuelType, fuelCapacity,
    seatingCapacity, additionalInfo,
  ];
}

class VehicleLogEntity extends Equatable {
  final String id;
  final String vehicleId;
  final String driverId;
  final String driverName;
  final double startKm;
  final double? endKm;
  final DateTime startTime;
  final DateTime? endTime;
  final List<LocationPoint> route;
  final String? observations;
  final UsageType usageType;
  final String? purpose;
  final List<String> attachments;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VehicleLogEntity({
    required this.id,
    required this.vehicleId,
    required this.driverId,
    required this.driverName,
    required this.startKm,
    this.endKm,
    required this.startTime,
    this.endTime,
    required this.route,
    this.observations,
    required this.usageType,
    this.purpose,
    required this.attachments,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id, vehicleId, driverId, driverName, startKm, endKm,
    startTime, endTime, route, observations, usageType,
    purpose, attachments, createdAt, updatedAt,
  ];

  bool get isActive => endTime == null;
  
  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }
  
  double? get distanceTraveled {
    if (endKm == null) return null;
    return endKm! - startKm;
  }
}

enum UsageType {
  patrol,
  emergency,
  maintenance,
  transport,
  other;

  String get displayName {
    switch (this) {
      case UsageType.patrol:
        return 'Patrullaje';
      case UsageType.emergency:
        return 'Emergencia';
      case UsageType.maintenance:
        return 'Mantenimiento';
      case UsageType.transport:
        return 'Transporte';
      case UsageType.other:
        return 'Otro';
    }
  }
}

class LocationPoint extends Equatable {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? speed;
  final double? accuracy;

  const LocationPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.speed,
    this.accuracy,
  });

  @override
  List<Object?> get props => [latitude, longitude, timestamp, speed, accuracy];
}