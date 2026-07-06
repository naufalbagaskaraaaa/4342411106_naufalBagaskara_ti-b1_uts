import '../entities/user_entity.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Login user with email and password
  /// Returns [UserEntity] on success
  /// Throws [AppAuthException] on failure
  Future<UserEntity> login({
    required String email,
    required String password,
  });

  /// Register new user
  /// Returns [UserEntity] on success
  /// Throws [AppAuthException] on failure
  Future<UserEntity> register({
    required String email,
    required String password,
    required String nama,
    String role = 'user',
  });

  /// Send password reset email
  /// Returns true if email sent successfully
  /// Throws [AppAuthException] on failure
  Future<bool> resetPassword({
    required String email,
  });

  /// Get current logged in user
  /// Returns [UserEntity] if user is logged in
  /// Returns null if no user is logged in
  Future<UserEntity?> getCurrentUser();

  /// Logout current user
  /// Returns true on success
  /// Throws [AppAuthException] on failure
  Future<bool> logout();

  /// Check if user is authenticated
  /// Returns true if user has valid session
  Future<bool> isAuthenticated();

  /// Update user profile
  /// Returns updated [UserEntity]
  /// Throws [AppAuthException] on failure
  Future<UserEntity> updateProfile({
    required String userId,
    String? nama,
    String? email,
  });
}

/// Custom exception for authentication errors
class AppAuthException implements Exception {
  final String message;
  final int? statusCode;

  const AppAuthException(this.message, [this.statusCode]);

  @override
  String toString() => 'AppAuthException: $message';
}
