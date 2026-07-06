import 'package:dartz/dartz.dart';
import '../entities/tiket_entity.dart';
import '../repositories/tiket_repository.dart';

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

/// Use case for retrieving ticket lists with role-based filtering.
///
/// This use case enforces role-based access control:
/// - Regular users: can only see their own tickets
/// - Admin: can see all tickets
/// - Helpdesk: can see all tickets (primarily interested in assigned ones)
class GetTiketListUseCase {
  final TiketRepository _repository;

  GetTiketListUseCase(this._repository);

  /// Execute the use case to get ticket list
  ///
  /// Parameters:
  /// - userId: ID of the user requesting the list
  /// - userRole: Role of the user ('user', 'admin', or 'helpdesk')
  /// - statusFilter: Optional filter to show only specific status tickets
  ///
  /// Returns Right(List<TiketEntity>) on success
  /// Returns Left(TiketFailure) on failure
  Future<Either<TiketFailure, List<TiketEntity>>> call({
    required String userId,
    required String userRole,
    TiketStatus? statusFilter,
  }) async {
    // Validate input
    if (userId.trim().isEmpty) {
      return Left(TiketFailure('User ID cannot be empty'));
    }

    final role = UserRole.fromString(userRole);

    // Get tickets from repository
    final result = await _repository.getTiketList(
      userId: userId.trim(),
      userRole: role.name,
      statusFilter: statusFilter,
    );

    return result.fold(
      (failure) => Left(failure),
      (tiketList) {
        // Additional role-based filtering if needed
        // (Repository should handle this, but we add extra safety)
        final filteredList = role == UserRole.user
          ? tiketList.where((tiket) => tiket.idUser == userId).toList()
          : tiketList;

        return Right(filteredList);
      },
    );
  }

  /// Convenience method to get only open tickets for admin
  Future<Either<TiketFailure, List<TiketEntity>>> getOpenTickets({
    required String userId,
    required String userRole,
  }) {
    return call(
      userId: userId,
      userRole: userRole,
      statusFilter: TiketStatus.open,
    );
  }

  /// Convenience method to get assigned tickets for helpdesk
  Future<Either<TiketFailure, List<TiketEntity>>> getAssignedTickets({
    required String userId,
    required String userRole,
  }) {
    return call(
      userId: userId,
      userRole: userRole,
      statusFilter: TiketStatus.inProgress,
    );
  }

  /// Convenience method to get tickets in progress for admin
  Future<Either<TiketFailure, List<TiketEntity>>> getInProgressTickets({
    required String userId,
    required String userRole,
  }) {
    return call(
      userId: userId,
      userRole: userRole,
      statusFilter: TiketStatus.inProgress,
    );
  }

  /// Convenience method to get closed tickets
  Future<Either<TiketFailure, List<TiketEntity>>> getClosedTickets({
    required String userId,
    required String userRole,
  }) {
    return call(
      userId: userId,
      userRole: userRole,
      statusFilter: TiketStatus.close,
    );
  }
}