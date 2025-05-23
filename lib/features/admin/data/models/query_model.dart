// lib/features/admin/data/models/query_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/query_entity.dart';

class QueryModel extends QueryEntity {
  const QueryModel({
    required super.id,
    required super.title,
    required super.description,
    required super.citizenId,
    required super.citizenName,
    required super.citizenEmail,
    required super.muniId,
    required super.status,
    required super.category,
    required super.priority,
    required super.imageUrls,
    super.response,
    super.responderId,
    super.responderName,
    required super.createdAt,
    super.answeredAt,
    required super.updatedAt,
    required super.historyLog,
    required super.isUrgent,
    required super.tags,
  });

  factory QueryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return QueryModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      citizenId: data['citizenId'] ?? '',
      citizenName: data['citizenName'] ?? '',
      citizenEmail: data['citizenEmail'] ?? '',
      muniId: data['muniId'] ?? '',
      status: QueryStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => QueryStatus.pending,
      ),
      category: QueryCategory.values.firstWhere(
        (category) => category.name == data['category'],
        orElse: () => QueryCategory.general,
      ),
      priority: QueryPriority.values.firstWhere(
        (priority) => priority.name == data['priority'],
        orElse: () => QueryPriority.normal,
      ),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      response: data['response'],
      responderId: data['responderId'],
      responderName: data['responderName'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      answeredAt: (data['answeredAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      historyLog: _parseHistoryLog(data['historyLog']),
      isUrgent: data['isUrgent'] ?? false,
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  factory QueryModel.fromMap(Map<String, dynamic> map) {
    return QueryModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      citizenId: map['citizenId'] ?? '',
      citizenName: map['citizenName'] ?? '',
      citizenEmail: map['citizenEmail'] ?? '',
      muniId: map['muniId'] ?? '',
      status: QueryStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => QueryStatus.pending,
      ),
      category: QueryCategory.values.firstWhere(
        (category) => category.name == map['category'],
        orElse: () => QueryCategory.general,
      ),
      priority: QueryPriority.values.firstWhere(
        (priority) => priority.name == map['priority'],
        orElse: () => QueryPriority.normal,
      ),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      response: map['response'],
      responderId: map['responderId'],
      responderName: map['responderName'],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      answeredAt: map['answeredAt'] is Timestamp
          ? (map['answeredAt'] as Timestamp).toDate()
          : map['answeredAt'] != null
              ? DateTime.parse(map['answeredAt'])
              : null,
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
      historyLog: _parseHistoryLog(map['historyLog']),
      isUrgent: map['isUrgent'] ?? false,
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'citizenId': citizenId,
      'citizenName': citizenName,
      'citizenEmail': citizenEmail,
      'muniId': muniId,
      'status': status.name,
      'category': category.name,
      'priority': priority.name,
      'imageUrls': imageUrls,
      'response': response,
      'responderId': responderId,
      'responderName': responderName,
      'createdAt': createdAt,
      'answeredAt': answeredAt,
      'updatedAt': updatedAt,
      'historyLog': historyLog.map((item) => QueryHistoryItemModel.fromEntity(item).toMap()).toList(),
      'isUrgent': isUrgent,
      'tags': tags,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'citizenId': citizenId,
      'citizenName': citizenName,
      'citizenEmail': citizenEmail,
      'muniId': muniId,
      'status': status.name,
      'category': category.name,
      'priority': priority.name,
      'imageUrls': imageUrls,
      'response': response,
      'responderId': responderId,  
      'responderName': responderName,
      'createdAt': createdAt.toIso8601String(),
      'answeredAt': answeredAt?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'historyLog': historyLog.map((item) => QueryHistoryItemModel.fromEntity(item).toMap()).toList(),
      'isUrgent': isUrgent,
      'tags': tags,
    };
  }

  static List<QueryHistoryItem> _parseHistoryLog(dynamic historyData) {
    if (historyData == null) return [];
    
    return (historyData as List)
        .map((data) => QueryHistoryItemModel.fromMap(data as Map<String, dynamic>))
        .toList();
  }
}

class QueryHistoryItemModel extends QueryHistoryItem {
  const QueryHistoryItemModel({
    required super.timestamp,
    required super.status,
    super.comment,
    super.userId,
    super.userName,
    super.userRole,
  });

  factory QueryHistoryItemModel.fromMap(Map<String, dynamic> map) {
    return QueryHistoryItemModel(
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      status: QueryStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => QueryStatus.pending,
      ),
      comment: map['comment'],
      userId: map['userId'],
      userName: map['userName'],
      userRole: map['userRole'],
    );
  }

  factory QueryHistoryItemModel.fromEntity(QueryHistoryItem entity) {
    return QueryHistoryItemModel(
      timestamp: entity.timestamp,
      status: entity.status,
      comment: entity.comment,
      userId: entity.userId,
      userName: entity.userName,
      userRole: entity.userRole,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp,
      'status': status.name,
      'comment': comment,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
    };
  }
}