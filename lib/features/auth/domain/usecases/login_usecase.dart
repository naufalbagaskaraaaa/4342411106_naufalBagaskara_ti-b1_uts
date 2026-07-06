import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for user login
class LoginUseCase {
  final AuthRepository _authRepository;

  const LoginUseCase(this._authRepository);

  /// Execute login use case
  ///
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  ///
  /// Returns [UserEntity] on successful login
  /// Throws [AppAuthException] on authentication failure
  Future<UserEntity> execute({
    required String email,
    required String password,
  }) async {
    // Validate input
    if (email.isEmpty) {
      throw const AppAuthException('Email cannot be empty');
    }
    if (password.isEmpty) {
      throw const AppAuthException('Password cannot be empty');
    }

    // Basic email format validation
    if (!_isValidEmail(email)) {
      throw const AppAuthException('Invalid email format');
    }

    // Execute login
    try {
      final user = await _authRepository.login(
        email: email,
        password: password,
      );
      return user;
    } on AppAuthException {
      rethrow;
    } catch (e) {
      throw AppAuthException('Login failed: ${e.toString()}');
    }
  }

  /// Basic email format validation
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
