// lib/features/citizen/data/models/enhanced_report_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/enhanced_report_entity.dart';

class ReportModel extends ReportEntity {
  const ReportModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    super.references,
    required super.location,
    required super.citizenId,
    required super.muniId,
    required super.status,
    required super.priority,
    required super.attachments,
    required super.createdAt,
    required super.updatedAt,
    required super.statusHistory,
    required super.responses,
    super.assignedToId,
    super.assignedToName,
  });

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ReportModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      references: data['references'],
      location: LocationDataModel.fromMap(data['location'] ?? {}),
      citizenId: data['citizenId'] ?? '',
      muniId: data['muniId'] ?? '',
      status: ReportStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => ReportStatus.submitted,
      ),
      priority: Priority.values.firstWhere(
        (priority) => priority.name == data['priority'],
        orElse: () => Priority.medium,
      ),
      attachments: _parseAttachments(data['attachments']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      statusHistory: _parseStatusHistory(data['statusHistory']),
      responses: _parseResponses(data['responses']),
      assignedToId: data['assignedToId'],
      assignedToName: data['assignedToName'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'references': references,
      'location': LocationDataModel.fromEntity(location).toMap(),
      'citizenId': citizenId,
      'muniId': muniId,
      'status': status.name,
      'priority': priority.name,
      'attachments': attachments.map((a) => MediaAttachmentModel.fromEntity(a).toMap()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'statusHistory': statusHistory.map((s) => StatusHistoryItemModel.fromEntity(s).toMap()).toList(),
      'responses': responses.map((r) => ReportResponseModel.fromEntity(r).toMap()).toList(),
      'assignedToId': assignedToId,
      'assignedToName': assignedToName,
    };
  }

  static List<MediaAttachment> _parseAttachments(dynamic attachmentsData) {
    if (attachmentsData == null) return [];
    
    return (attachmentsData as List)
        .map((data) => MediaAttachmentModel.fromMap(data as Map<String, dynamic>))
        .toList();
  }

  static List<StatusHistoryItem> _parseStatusHistory(dynamic historyData) {
    if (historyData == null) return [];
    
    return (historyData as List)
        .map((data) => StatusHistoryItemModel.fromMap(data as Map<String, dynamic>))
        .toList();
  }

  static List<ReportResponse> _parseResponses(dynamic responsesData) {
    if (responsesData == null) return [];
    
    return (responsesData as List)
        .map((data) => ReportResponseModel.fromMap(data as Map<String, dynamic>))
        .toList();
  }
}

class LocationDataModel extends LocationData {
  const LocationDataModel({
    required super.latitude,
    required super.longitude,
    super.address,
    super.manualAddress,
    required super.source,
  });

  factory LocationDataModel.fromMap(Map<String, dynamic> map) {
    return LocationDataModel(
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      address: map['address'],
      manualAddress: map['manualAddress'],
      source: LocationSource.values.firstWhere(
        (source) => source.name == map['source'],
        orElse: () => LocationSource.manual,
      ),
    );
  }

  factory LocationDataModel.fromEntity(LocationData entity) {
    return LocationDataModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
      address: entity.address,
      manualAddress: entity.manualAddress,
      source: entity.source,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'manualAddress': manualAddress,
      'source': source.name,
    };
  }
}

class MediaAttachmentModel extends MediaAttachment {
  const MediaAttachmentModel({
    required super.id,
    required super.url,
    required super.fileName,
    required super.type,
    super.fileSize,
    required super.uploadedAt,
  });

  factory MediaAttachmentModel.fromMap(Map<String, dynamic> map) {
    return MediaAttachmentModel(
      id: map['id'] ?? '',
      url: map['url'] ?? '',
      fileName: map['fileName'] ?? '',
      type: MediaType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => MediaType.image,
      ),
      fileSize: map['fileSize'],
      uploadedAt: (map['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory MediaAttachmentModel.fromEntity(MediaAttachment entity) {
    return MediaAttachmentModel(
      id: entity.id,
      url: entity.url,
      fileName: entity.fileName,
      type: entity.type,
      fileSize: entity.fileSize,
      uploadedAt: entity.uploadedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'fileName': fileName,
      'type': type.name,
      'fileSize': fileSize,
      'uploadedAt': uploadedAt,
    };
  }
}

class StatusHistoryItemModel extends StatusHistoryItem {
  const StatusHistoryItemModel({
    required super.timestamp,
    required super.status,
    super.comment,
    super.userId,
    super.userName,
  });

  factory StatusHistoryItemModel.fromMap(Map<String, dynamic> map) {
    return StatusHistoryItemModel(
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: ReportStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => ReportStatus.submitted,
      ),
      comment: map['comment'],
      userId: map['userId'],
      userName: map['userName'],
    );
  }

  factory StatusHistoryItemModel.fromEntity(StatusHistoryItem entity) {
    return StatusHistoryItemModel(
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

class ReportResponseModel extends ReportResponse {
  const ReportResponseModel({
    required super.id,
    required super.responderId,
    required super.responderName,
    required super.message,
    required super.attachments,
    required super.isPublic,
    required super.createdAt,
  });

  factory ReportResponseModel.fromMap(Map<String, dynamic> map) {
    return ReportResponseModel(
      id: map['id'] ?? '',
      responderId: map['responderId'] ?? '',
      responderName: map['responderName'] ?? '',
      message: map['message'] ?? '',
      attachments: _parseAttachments(map['attachments']),
      isPublic: map['isPublic'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory ReportResponseModel.fromEntity(ReportResponse entity) {
    return ReportResponseModel(
      id: entity.id,
      responderId: entity.responderId,
      responderName: entity.responderName,
      message: entity.message,
      attachments: entity.attachments,
      isPublic: entity.isPublic,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'responderId': responderId,
      'responderName': responderName,
      'message': message,
      'attachments': attachments.map((a) => MediaAttachmentModel.fromEntity(a).toMap()).toList(),
      'isPublic': isPublic,
      'createdAt': createdAt,
    };
  }

  static List<MediaAttachment> _parseAttachments(dynamic attachmentsData) {
    if (attachmentsData == null) return [];
    
    return (attachmentsData as List)
        .map((data) => MediaAttachmentModel.fromMap(data as Map<String, dynamic>))
        .toList();
  }
}