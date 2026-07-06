import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for user registration
class RegisterUseCase {
  final AuthRepository _authRepository;

  const RegisterUseCase(this._authRepository);

  /// Execute registration use case
  ///
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password (min 6 characters)
  /// - [nama]: User's full name
  /// - [role]: User role (default: 'user')
  ///
  /// Returns [UserEntity] on successful registration
  /// Throws [AppAuthException] on registration failure
  Future<UserEntity> execute({
    required String email,
    required String password,
    required String nama,
    String role = 'user',
  }) async {
    // Validate input
    if (email.isEmpty) {
      throw const AppAuthException('Email cannot be empty');
    }
    if (password.isEmpty) {
      throw const AppAuthException('Password cannot be empty');
    }
    if (nama.isEmpty) {
      throw const AppAuthException('Name cannot be empty');
    }

    // Validate email format
    if (!_isValidEmail(email)) {
      throw const AppAuthException('Invalid email format');
    }

    // Validate password strength (min 6 characters)
    if (password.length < 6) {
      throw const AppAuthException('Password must be at least 6 characters');
    }

    // Validate role
    if (!_isValidRole(role)) {
      throw const AppAuthException('Invalid role. Must be: user, admin, or helpdesk');
    }

    // Execute registration
    try {
      final user = await _authRepository.register(
        email: email,
        password: password,
        nama: nama,
        role: role,
      );
      return user;
    } on AppAuthException {
      rethrow;
    } catch (e) {
      throw AppAuthException('Registration failed: ${e.toString()}');
    }
  }

  /// Basic email format validation
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Validate role against allowed values
  bool _isValidRole(String role) {
    const allowedRoles = ['user', 'admin', 'helpdesk'];
    return allowedRoles.contains(role);
  }
}
