import '../../domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<UserEntity> signInWithEmailAndPassword(String email, String password);
  Future<UserEntity> registerWithEmailAndPassword(String email, String password, String name);
  Future<void> signOut();
  Future<UserEntity?> getCurrentUser();
  Future<void> forgotPassword(String email);
}