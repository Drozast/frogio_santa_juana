// lib/features/inspector/data/models/infraction_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/infraction_entity.dart';

class InfractionModel extends InfractionEntity {
  const InfractionModel({
    required super.id,
    required super.title,
    required super.description,
    required super.ordinanceRef,
    required super.location,
    required super.offenderId,
    required super.offenderName,
    required super.offenderDocument,
    required super.inspectorId,
    required super.muniId,
    required super.evidence,
    required super.signatures,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    required super.historyLog,
  });

  factory InfractionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return InfractionModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      ordinanceRef: data['ordinanceRef'] ?? '',
      location: LocationDataModel.fromMap(data['location'] ?? {}),
      offenderId: data['offenderId'] ?? '',
      offenderName: data['offenderName'] ?? '',
      offenderDocument: data['offenderDocument'] ?? '',
      inspectorId: data['inspectorId'] ?? '',
      muniId: data['muniId'] ?? '',
      evidence: List<String>.from(data['evidence'] ?? []),
      signatures: List<String>.from(data['signatures'] ?? []),
      status: InfractionStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => InfractionStatus.created,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      historyLog: _parseHistoryLog(data['historyLog']),
    );
  }

  factory InfractionModel.fromMap(Map<String, dynamic> map) {
    return InfractionModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      ordinanceRef: map['ordinanceRef'] ?? '',
      location: LocationDataModel.fromMap(map['location'] ?? {}),
      offenderId: map['offenderId'] ?? '',
      offenderName: map['offenderName'] ?? '',
      offenderDocument: map['offenderDocument'] ?? '',
      inspectorId: map['inspectorId'] ?? '',
      muniId: map['muniId'] ?? '',
      evidence: List<String>.from(map['evidence'] ?? []),
      signatures: List<String>.from(map['signatures'] ?? []),
      status: InfractionStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => InfractionStatus.created,
      ),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
      historyLog: _parseHistoryLog(map['historyLog']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'ordinanceRef': ordinanceRef,
      'location': (location as LocationDataModel).toMap(),
      'offenderId': offenderId,
      'offenderName': offenderName,
      'offenderDocument': offenderDocument,
      'inspectorId': inspectorId,
      'muniId': muniId,
      'evidence': evidence,
      'signatures': signatures,
      'status': status.name,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'historyLog': historyLog.map((item) => InfractionHistoryItemModel.fromEntity(item).toMap()).toList(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'ordinanceRef': ordinanceRef,
      'location': (location as LocationDataModel).toMap(),
      'offenderId': offenderId,
      'offenderName': offenderName,
      'offenderDocument': offenderDocument,
      'inspectorId': inspectorId,
      'muniId': muniId,
      'evidence': evidence,
      'signatures': signatures,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'historyLog': historyLog.map((item) => InfractionHistoryItemModel.fromEntity(item).toMap()).toList(),
    };
  }

  static List<InfractionHistoryItem> _parseHistoryLog(dynamic historyData) {
    if (historyData == null) return [];
    
    return (historyData as List)
        .map((data) => InfractionHistoryItemModel.fromMap(data as Map<String, dynamic>))
        .toList();
  }
}

class LocationDataModel extends LocationData {
  const LocationDataModel({
    required super.latitude,
    required super.longitude,
    super.address,
  });

  factory LocationDataModel.fromMap(Map<String, dynamic> map) {
    return LocationDataModel(
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      address: map['address'],
    );
  }

  factory LocationDataModel.fromEntity(LocationData entity) {
    return LocationDataModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
      address: entity.address,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}

class InfractionHistoryItemModel extends InfractionHistoryItem {
  const InfractionHistoryItemModel({
    required super.timestamp,
    required super.status,
    super.comment,
    super.userId,
    super.userName,
  });

  factory InfractionHistoryItemModel.fromMap(Map<String, dynamic> map) {
    return InfractionHistoryItemModel(
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      status: InfractionStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => InfractionStatus.created,
      ),
      comment: map['comment'],
      userId: map['userId'],
      userName: map['userName'],
    );
  }

  factory InfractionHistoryItemModel.fromEntity(InfractionHistoryItem entity) {
    return InfractionHistoryItemModel(
      timestamp: entity.timestamp,
      status: entity.status,
      comment: entity.comment,
      userId: entity.userId,
      userName: entity.userName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp,
      'status': status.name,
      'comment': comment,
      'userId': userId,
      'userName': userName,
    };
  }
}