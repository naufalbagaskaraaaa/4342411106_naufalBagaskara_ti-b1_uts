import '../repositories/auth_repository.dart';

/// Use case for password reset
class ResetPasswordUseCase {
  final AuthRepository _authRepository;

  const ResetPasswordUseCase(this._authRepository);

  /// Execute password reset use case
  ///
  /// Parameters:
  /// - [email]: User's email address for password reset
  ///
  /// Returns true if reset email sent successfully
  /// Throws [AppAuthException] on failure
  Future<bool> execute({
    required String email,
  }) async {
    // Validate input
    if (email.isEmpty) {
      throw const AppAuthException('Email cannot be empty');
    }

    // Validate email format
    if (!_isValidEmail(email)) {
      throw const AppAuthException('Invalid email format');
    }

    // Execute password reset
    try {
      final success = await _authRepository.resetPassword(email: email);
      return success;
    } on AppAuthException {
      rethrow;
    } catch (e) {
      throw AppAuthException('Password reset failed: ${e.toString()}');
    }
  }

  /// Basic email format validation
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4');
    return emailRegex.hasMatch(email);
  }
}
