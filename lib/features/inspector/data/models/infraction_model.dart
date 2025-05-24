import 'package:equatable/equatable.dart';

import '../../domain/entities/infraction_entity.dart';

class InfractionModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String ordinanceRef;
  final Map<String, dynamic> location;
  final String offenderId;
  final String offenderName;
  final String offenderDocument;
  final String inspectorId;
  final String muniId;
  final List<String> evidence;
  final List<String> signatures;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const InfractionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.ordinanceRef,
    required this.location,
    required this.offenderId,
    required this.offenderName,
    required this.offenderDocument,
    required this.inspectorId,
    required this.muniId,
    required this.evidence,
    required this.signatures,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory InfractionModel.fromJson(Map<String, dynamic> json) {
    return InfractionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      ordinanceRef: json['ordinanceRef'] ?? '',
      location: json['location'] ?? {},
      offenderId: json['offenderId'] ?? '',
      offenderName: json['offenderName'] ?? '',
      offenderDocument: json['offenderDocument'] ?? '',
      inspectorId: json['inspectorId'] ?? '',
      muniId: json['muniId'] ?? '',
      evidence: List<String>.from(json['evidence'] ?? []),
      signatures: List<String>.from(json['signatures'] ?? []),
      status: json['status'] ?? 'pending',
      createdAt: (json['createdAt'] as dynamic).toDate() ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? (json['updatedAt'] as dynamic).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'ordinanceRef': ordinanceRef,
      'location': location,
      'offenderId': offenderId,
      'offenderName': offenderName,
      'offenderDocument': offenderDocument,
      'inspectorId': inspectorId,
      'muniId': muniId,
      'evidence': evidence,
      'signatures': signatures,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  InfractionEntity toEntity() {
    return InfractionEntity(
      id: id,
      title: title,
      description: description,
      ordinanceRef: ordinanceRef,
      location: location,
      offenderId: offenderId,
      offenderName: offenderName,
      offenderDocument: offenderDocument,
      inspectorId: inspectorId,
      muniId: muniId,
      evidence: evidence,
      signatures: signatures,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory InfractionModel.fromEntity(InfractionEntity entity) {
    return InfractionModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      ordinanceRef: entity.ordinanceRef,
      location: entity.location,
      offenderId: entity.offenderId,
      offenderName: entity.offenderName,
      offenderDocument: entity.offenderDocument,
      inspectorId: entity.inspectorId,
      muniId: entity.muniId,
      evidence: entity.evidence,
      signatures: entity.signatures,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  InfractionModel copyWith({
    String? id,
    String? title,
    String? description,
    String? ordinanceRef,
    Map<String, dynamic>? location,
    String? offenderId,
    String? offenderName,
    String? offenderDocument,
    String? inspectorId,
    String? muniId,
    List<String>? evidence,
    List<String>? signatures,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InfractionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      ordinanceRef: ordinanceRef ?? this.ordinanceRef,
      location: location ?? this.location,
      offenderId: offenderId ?? this.offenderId,
      offenderName: offenderName ?? this.offenderName,
      offenderDocument: offenderDocument ?? this.offenderDocument,
      inspectorId: inspectorId ?? this.inspectorId,
      muniId: muniId ?? this.muniId,
      evidence: evidence ?? this.evidence,
      signatures: signatures ?? this.signatures,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        ordinanceRef,
        location,
        offenderId,
        offenderName,
        offenderDocument,
        inspectorId,
        muniId,
        evidence,
        signatures,
        status,
        createdAt,
        updatedAt,
      ];
}