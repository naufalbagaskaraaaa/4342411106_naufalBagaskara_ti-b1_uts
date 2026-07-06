import 'package:dartz/dartz.dart';
import '../entities/tiket_entity.dart';
import '../repositories/tiket_repository.dart';

/// Use case for updating ticket status through the automated workflow.
///
/// ⚠️ CRITICAL BUSINESS LOGIC ⚠️
/// This use case enforces the automated status workflow where:
/// 1. User creates ticket → status: open
/// 2. Admin accepts ticket → status: assign
/// 3. Admin assigns to helpdesk → status: in_progress
/// 4. Helpdesk clicks "Selesai/Finish" → status: close
///
/// IMPORTANT: There is NO manual status change method.
/// All status transitions MUST go through specific workflow methods.
class UpdateTiketStatusUseCase {
  final TiketRepository _repository;

  UpdateTiketStatusUseCase(this._repository);

  /// Accept a ticket (admin only) - transitions from 'open' to 'assign'
  ///
  /// This is the ONLY way to change a ticket status from 'open' to 'assign'
  ///
  /// Parameters:
  /// - tiketId: ID of the ticket to accept
  /// - adminId: ID of the admin accepting the ticket
  ///
  /// Returns Right(TiketEntity) with updated status on success
  /// Returns Left(TiketFailure) on failure
  Future<Either<TiketFailure, TiketEntity>> acceptTiket({
    required String tiketId,
    required String adminId,
  }) async {
    // Validate input
    if (tiketId.trim().isEmpty) {
      return Left(TiketFailure('Ticket ID cannot be empty'));
    }

    if (adminId.trim().isEmpty) {
      return Left(TiketFailure('Admin ID cannot be empty'));
    }

    // Accept the ticket through repository
    final result = await _repository.acceptTiket(
      tiketId: tiketId.trim(),
      adminId: adminId.trim(),
    );

    // Verify the status transition
    return result.fold(
      (failure) => Left(failure),
      (tiket) {
        if (tiket.status != TiketStatus.assign) {
          return Left(TiketFailure(
            'Invalid status transition: Accepted tickets must have status "assign"',
          ));
        }
        if (tiket.idAdmin != adminId) {
          return Left(TiketFailure(
            'Invalid admin assignment: Admin ID mismatch',
          ));
        }
        return Right(tiket);
      },
    );
  }

  /// Assign a ticket to helpdesk (admin only) - transitions from 'assign' to 'in_progress'
  ///
  /// This is the ONLY way to change a ticket status from 'assign' to 'in_progress'
  ///
  /// Parameters:
  /// - tiketId: ID of the ticket to assign
  /// - adminId: ID of the admin making the assignment
  /// - helpdeskId: ID of the helpdesk to assign the ticket to
  ///
  /// Returns Right(TiketEntity) with updated status on success
  /// Returns Left(TiketFailure) on failure
  Future<Either<TiketFailure, TiketEntity>> assignTiket({
    required String tiketId,
    required String adminId,
    required String helpdeskId,
  }) async {
    // Validate input
    if (tiketId.trim().isEmpty) {
      return Left(TiketFailure('Ticket ID cannot be empty'));
    }

    if (adminId.trim().isEmpty) {
      return Left(TiketFailure('Admin ID cannot be empty'));
    }

    if (helpdeskId.trim().isEmpty) {
      return Left(TiketFailure('Helpdesk ID cannot be empty'));
    }

    // Assign the ticket through repository
    final result = await _repository.assignTiket(
      tiketId: tiketId.trim(),
      adminId: adminId.trim(),
      helpdeskId: helpdeskId.trim(),
    );

    // Verify the status transition
    return result.fold(
      (failure) => Left(failure),
      (tiket) {
        if (tiket.status != TiketStatus.inProgress) {
          return Left(TiketFailure(
            'Invalid status transition: Assigned tickets must have status "in_progress"',
          ));
        }
        if (tiket.idAdmin != adminId) {
          return Left(TiketFailure(
            'Invalid admin assignment: Admin ID mismatch',
          ));
        }
        if (tiket.idHelpdesk != helpdeskId) {
          return Left(TiketFailure(
            'Invalid helpdesk assignment: Helpdesk ID mismatch',
          ));
        }
        return Right(tiket);
      },
    );
  }

  /// Mark ticket as finished (helpdesk only) - transitions from 'in_progress' to 'close'
  ///
  /// This is the ONLY way to change a ticket status from 'in_progress' to 'close'
  ///
  /// Parameters:
  /// - tiketId: ID of the ticket to finish
  /// - helpdeskId: ID of the helpdesk marking the ticket as finished
  ///
  /// Returns Right(TiketEntity) with updated status on success
  /// Returns Left(TiketFailure) on failure
  Future<Either<TiketFailure, TiketEntity>> finishTiket({
    required String tiketId,
    required String helpdeskId,
  }) async {
    // Validate input
    if (tiketId.trim().isEmpty) {
      return Left(TiketFailure('Ticket ID cannot be empty'));
    }

    if (helpdeskId.trim().isEmpty) {
      return Left(TiketFailure('Helpdesk ID cannot be empty'));
    }

    // Finish the ticket through repository
    final result = await _repository.finishTiket(
      tiketId: tiketId.trim(),
      helpdeskId: helpdeskId.trim(),
    );

    // Verify the status transition
    return result.fold(
      (failure) => Left(failure),
      (tiket) {
        if (tiket.status != TiketStatus.close) {
          return Left(TiketFailure(
            'Invalid status transition: Finished tickets must have status "close"',
          ));
        }
        if (tiket.idHelpdesk != helpdeskId) {
          return Left(TiketFailure(
            'Invalid helpdesk verification: Helpdesk ID mismatch',
          ));
        }
        return Right(tiket);
      },
    );
  }

  /// Validate if a status transition is allowed
  ///
  /// This method checks if a transition from currentStatus to targetStatus
  /// follows the automated workflow rules
  ///
  /// Returns true if the transition is allowed, false otherwise
  bool canTransitionTo(TiketStatus currentStatus, TiketStatus targetStatus) {
    return currentStatus.canTransitionTo(targetStatus);
  }

  /// Get the next status in the workflow for a given current status
  ///
  /// Returns the next status if there is one, null if ticket is closed
  TiketStatus? getNextStatus(TiketStatus currentStatus) {
    return currentStatus.nextStatus;
  }
}