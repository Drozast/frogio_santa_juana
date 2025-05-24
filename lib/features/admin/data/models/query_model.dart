import 'package:equatable/equatable.dart';

import '../../domain/entities/query_entity.dart';

class QueryModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String citizenId;
  final String muniId;
  final String status;
  final String? response;
  final String? responderId;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime? answeredAt;

  const QueryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.citizenId,
    required this.muniId,
    required this.status,
    this.response,
    this.responderId,
    required this.imageUrls,
    required this.createdAt,
    this.answeredAt,
  });

  factory QueryModel.fromJson(Map<String, dynamic> json) {
    return QueryModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      citizenId: json['citizenId'] ?? '',
      muniId: json['muniId'] ?? '',
      status: json['status'] ?? 'pending',
      response: json['response'],
      responderId: json['responderId'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      createdAt: (json['createdAt'] as dynamic).toDate() ?? DateTime.now(),
      answeredAt: json['answeredAt'] != null 
          ? (json['answeredAt'] as dynamic).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'citizenId': citizenId,
      'muniId': muniId,
      'status': status,
      'response': response,
      'responderId': responderId,
      'imageUrls': imageUrls,
      'createdAt': createdAt,
      'answeredAt': answeredAt,
    };
  }

  QueryEntity toEntity() {
    return QueryEntity(
      id: id,
      title: title,
      description: description,
      citizenId: citizenId,
      muniId: muniId,
      status: status,
      response: response,
      responderId: responderId,
      imageUrls: imageUrls,
      createdAt: createdAt,
      answeredAt: answeredAt, citizenName: '', citizenEmail: '', category: null, priority: null, updatedAt: null, historyLog: [], isUrgent: null, tags: [],
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        citizenId,
        muniId,
        status,
        response,
        responderId,
        imageUrls,
        createdAt,
        answeredAt,
      ];
}