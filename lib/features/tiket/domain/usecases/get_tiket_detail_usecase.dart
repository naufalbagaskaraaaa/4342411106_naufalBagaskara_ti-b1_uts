import 'package:dartz/dartz.dart';
import '../entities/tiket_entity.dart';
import '../repositories/tiket_repository.dart';

/// Use case for retrieving detailed information about a specific ticket.
///
/// This use case fetches a single ticket along with all its comments.
class GetTiketDetailUseCase {
  final TiketRepository _repository;

  GetTiketDetailUseCase(this._repository);

  /// Execute the use case to get ticket details
  ///
  /// Parameters:
  /// - tiketId: ID of the ticket to retrieve
  ///
  /// Returns Right(TiketEntity) with all ticket details and comments on success
  /// Returns Left(TiketFailure) on failure
  Future<Either<TiketFailure, TiketEntity>> call({
    required String tiketId,
  }) async {
    // Validate input
    if (tiketId.trim().isEmpty) {
      return Left(TiketFailure('Ticket ID cannot be empty'));
    }

    // Get ticket details from repository
    final result = await _repository.getTiketDetail(
      tiketId: tiketId.trim(),
    );

    return result;
  }

  /// Get ticket detail with role-based access validation
  ///
  /// This method ensures users can only view tickets they have access to:
  /// - Regular users: can only view their own tickets
  /// - Admin: can view all tickets
  /// - Helpdesk: can view all tickets (especially assigned ones)
  Future<Either<TiketFailure, TiketEntity>> callWithAccessValidation({
    required String tiketId,
    required String userId,
    required String userRole,
  }) async {
    // Validate input
    if (tiketId.trim().isEmpty) {
      return Left(TiketFailure('Ticket ID cannot be empty'));
    }

    if (userId.trim().isEmpty) {
      return Left(TiketFailure('User ID cannot be empty'));
    }

    // Get ticket details
    final result = await _repository.getTiketDetail(
      tiketId: tiketId.trim(),
    );

    // Apply role-based access control
    return result.fold(
      (failure) => Left(failure),
      (tiket) {
        final role = UserRole.fromString(userRole);

        // Regular users can only view their own tickets
        if (role == UserRole.user && tiket.idUser != userId) {
          return Left(TiketFailure(
            'Access denied: You can only view your own tickets',
          ));
        }

        // Helpdesk can view all tickets, but warn if not assigned
        if (role == UserRole.helpdesk && tiket.idHelpdesk != userId) {
          // Helpdesk can still view, but this might be logged for audit
        }

        return Right(tiket);
      },
    );
  }
}

/// User roles for role-based access control
enum UserRole {
  user,
  admin,
  helpdesk;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'helpdesk':
        return UserRole.helpdesk;
      case 'user':
      default:
        return UserRole.user;
    }
  }
}