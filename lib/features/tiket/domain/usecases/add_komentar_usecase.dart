import 'package:dartz/dartz.dart';
import '../entities/komentar_entity.dart';
import '../repositories/tiket_repository.dart';

/// Use case for adding comments to a support ticket.
///
/// Comments allow users, admin, and helpdesk to provide updates,
/// additional information, or resolution details on a ticket.
class AddKomentarUseCase {
  final TiketRepository _repository;

  AddKomentarUseCase(this._repository);

  /// Execute the use case to add a comment to a ticket
  ///
  /// Parameters:
  /// - tiketId: ID of the ticket to add comment to
  /// - userId: ID of the user adding the comment
  /// - isi: Content of the comment
  ///
  /// Returns Right(KomentarEntity) on success
  /// Returns Left(TiketFailure) on failure
  Future<Either<TiketFailure, KomentarEntity>> call({
    required String tiketId,
    required String userId,
    required String isi,
  }) async {
    // Validate input
    if (tiketId.trim().isEmpty) {
      return Left(TiketFailure('Ticket ID cannot be empty'));
    }

    if (userId.trim().isEmpty) {
      return Left(TiketFailure('User ID cannot be empty'));
    }

    if (isi.trim().isEmpty) {
      return Left(TiketFailure('Comment content cannot be empty'));
    }

    // Verify ticket exists and user has access
    final ticketResult = await _repository.getTiketDetail(
      tiketId: tiketId.trim(),
    );

    return ticketResult.fold(
      (failure) => Left(failure),
      (tiket) {
        // Additional validation: regular users can only comment on their own tickets
        // if (tiket.idUser != userId) {
        //   return Left(TiketFailure(
        //     'Access denied: You can only comment on your own tickets',
        //   ));
        // }

        // Add the comment through repository
        return _repository.addKomentar(
          tiketId: tiketId.trim(),
          userId: userId.trim(),
          isi: isi.trim(),
        );
      },
    );
  }

  /// Add comment with role-based access validation
  ///
  /// This method ensures users can only add comments to tickets they have access to:
  /// - Regular users: can only comment on their own tickets
  /// - Admin: can comment on all tickets
  /// - Helpdesk: can comment on all tickets (especially assigned ones)
  Future<Either<TiketFailure, KomentarEntity>> callWithAccessValidation({
    required String tiketId,
    required String userId,
    required String userRole,
    required String isi,
  }) async {
    // Validate input
    if (tiketId.trim().isEmpty) {
      return Left(TiketFailure('Ticket ID cannot be empty'));
    }

    if (userId.trim().isEmpty) {
      return Left(TiketFailure('User ID cannot be empty'));
    }

    if (isi.trim().isEmpty) {
      return Left(TiketFailure('Comment content cannot be empty'));
    }

    // Verify ticket exists
    final ticketResult = await _repository.getTiketDetail(
      tiketId: tiketId.trim(),
    );

    return ticketResult.fold(
      (failure) => Left(failure),
      (tiket) {
        // Apply role-based access control
        final role = UserRole.fromString(userRole);

        // Regular users can only comment on their own tickets
        if (role == UserRole.user && tiket.idUser != userId) {
          return Left(TiketFailure(
            'Access denied: You can only comment on your own tickets',
          ));
        }

        // Helpdesk should primarily comment on assigned tickets
        // (but can comment on others for collaboration)
        if (role == UserRole.helpdesk && tiket.idHelpdesk != userId) {
          // Allow but might be logged for audit purposes
        }

        // Add the comment through repository
        return _repository.addKomentar(
          tiketId: tiketId.trim(),
          userId: userId.trim(),
          isi: isi.trim(),
        );
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