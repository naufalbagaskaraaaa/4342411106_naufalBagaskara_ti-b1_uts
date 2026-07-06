import '../datasources/supabase_auth_datasource.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository using Supabase data source
/// Bridges domain layer with data layer
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseAuthDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await dataSource.login(email, password);
      return userModel.toEntity();
    } on AppAuthException {
      rethrow;
    } catch (e) {
      throw AppAuthException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String nama,
    String role = 'user',
  }) async {
    try {
      final userModel = await dataSource.register(email, password, nama, role);
      return userModel.toEntity();
    } on AppAuthException {
      rethrow;
    } catch (e) {
      throw AppAuthException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<bool> resetPassword({
    required String email,
  }) async {
    try {
      return await dataSource.resetPassword(email);
    } on AppAuthException {
      rethrow;
    } catch (e) {
      throw AppAuthException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<bool> logout() async {
    try {
      return await dataSource.logout();
    } on AppAuthException {
      rethrow;
    } catch (e) {
      throw AppAuthException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final userModel = await dataSource.getCurrentUser();
      return userModel?.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return dataSource.isAuthenticated();
  }

  @override
  Future<UserEntity> updateProfile({
    required String userId,
    String? nama,
    String? email,
  }) async {
    try {
      final userModel = await dataSource.updateProfile(
        userId,
        nama: nama,
        email: email,
      );
      return userModel.toEntity();
    } on AppAuthException {
      rethrow;
    } catch (e) {
      throw AppAuthException('Unexpected error: ${e.toString()}');
    }
  }
}
