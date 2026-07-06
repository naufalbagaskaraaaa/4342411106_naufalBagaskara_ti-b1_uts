import '../repositories/auth_repository.dart';

/// Use case for user logout
class LogoutUseCase {
  final AuthRepository _authRepository;

  const LogoutUseCase(this._authRepository);

  /// Execute logout use case
  ///
  /// Returns true on successful logout
  /// Throws [AppAuthException] on failure
  Future<bool> execute() async {
    try {
      final success = await _authRepository.logout();
      return success;
    } on AppAuthException {
      rethrow;
    } catch (e) {
      throw AppAuthException('Logout failed: ${e.toString()}');
    }
  }
}
