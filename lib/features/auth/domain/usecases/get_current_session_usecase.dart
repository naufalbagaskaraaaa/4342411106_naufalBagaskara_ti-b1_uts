import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Result of current session check
class SessionResult {
  final UserEntity? user;
  final bool isAuthenticated;

  const SessionResult({
    required this.isAuthenticated,
    this.user,
  });
}

/// Use case for getting current authentication session
class GetCurrentSessionUseCase {
  final AuthRepository _authRepository;

  const GetCurrentSessionUseCase(this._authRepository);

  /// Execute get current session use case
  ///
  /// Returns [SessionResult] containing current user and auth state
  Future<SessionResult> execute() async {
    try {
      final isAuthenticated = await _authRepository.isAuthenticated();

      if (!isAuthenticated) {
        return const SessionResult(isAuthenticated: false);
      }

      final user = await _authRepository.getCurrentUser();
      return SessionResult(
        user: user,
        isAuthenticated: true,
      );
    } on AppAuthException {
      rethrow;
    } catch (e) {
      throw AppAuthException('Failed to get current session: ${e.toString()}');
    }
  }
}
