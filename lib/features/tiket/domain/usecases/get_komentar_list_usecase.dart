import 'package:dartz/dartz.dart';
import '../entities/komentar_entity.dart';
import '../repositories/tiket_repository.dart';

/// Use case for retrieving all comments for a specific ticket.
///
/// This use case fetches the comment history for a ticket,
/// allowing users to see the full conversation thread.
class GetKomentarListUseCase {
  final TiketRepository _repository;

  GetKomentarListUseCase(this._repository);

  /// Execute the use case to get comments for a ticket
  ///
  /// Parameters:
  /// - tiketId: ID of the ticket to get comments from
  ///
  /// Returns Right(List<KomentarEntity>) ordered by creation time on success
  /// Returns Left(TiketFailure) on failure
  Future<Either<TiketFailure, List<KomentarEntity>>> call({
    required String tiketId,
  }) async {
    // Validate input
    if (tiketId.trim().isEmpty) {
      return Left(TiketFailure('Ticket ID cannot be empty'));
    }

    // Get comments from repository
    final result = await _repository.getKomentarList(
      tiketId: tiketId.trim(),
    );

    // Sort comments by creation time (oldest first for chat-like display)
    return result.fold(
      (failure) => Left(failure),
      (komentarList) {
        final sortedList = List<KomentarEntity>.from(komentarList);
        sortedList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        return Right(sortedList);
      },
    );
  }

  /// Get comments with role-based access validation
  ///
  /// This method ensures users can only view comments for tickets they have access to:
  /// - Regular users: can only view comments for their own tickets
  /// - Admin: can view comments for all tickets
  /// - Helpdesk: can view comments for all tickets (especially assigned ones)
  Future<Either<TiketFailure, List<KomentarEntity>>> callWithAccessValidation({
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

    // Verify ticket exists and user has access
    final ticketResult = await _repository.getTiketDetail(
      tiketId: tiketId.trim(),
    );

    return ticketResult.fold(
      (failure) => Left(failure),
      (tiket) {
        // Apply role-based access control
        final role = UserRole.fromString(userRole);

        // Regular users can only view comments for their own tickets
        if (role == UserRole.user && tiket.idUser != userId) {
          return Left(TiketFailure(
            'Access denied: You can only view comments for your own tickets',
          ));
        }

        // Get comments from repository
        return _repository.getKomentarList(
          tiketId: tiketId.trim(),
        ).then((result) {
          return result.fold(
            (failure) => Left(failure),
            (komentarList) {
              // Sort comments by creation time
              final sortedList = List<KomentarEntity>.from(komentarList);
              sortedList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
              return Right(sortedList);
            },
          );
        });
      },
    );
  }

  /// Get comment count for a ticket
  ///
  /// Returns the number of comments on a ticket
  Future<Either<TiketFailure, int>> getCommentCount({
    required String tiketId,
  }) async {
    final result = await call(tiketId: tiketId);

    return result.fold(
      (failure) => Left(failure),
      (komentarList) => Right(komentarList.length),
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