import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required String id,
    required String email,
    String? name,
    required String role,
    String? muniId,
    required DateTime createdAt,
  }) : super(
          id: id,
          email: email,
          name: name,
          role: role,
          muniId: muniId,
          createdAt: createdAt,
        );

  factory UserModel.fromFirebase(Map<String, dynamic> data, String uid) {
    return UserModel(
      id: uid,
      email: data['email'] ?? '',
      name: data['name'],
      role: data['role'] ?? 'citizen',
      muniId: data['muniId'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'muniId': muniId,
      'createdAt': createdAt,
    };
  }
}