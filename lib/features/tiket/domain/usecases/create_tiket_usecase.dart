import 'package:dartz/dartz.dart';
import '../entities/tiket_entity.dart';
import '../repositories/tiket_repository.dart';

/// Use case for creating a new support ticket.
///
/// This use case enforces the business rule that all new tickets
/// must start with status 'open' automatically.
class CreateTiketUseCase {
  final TiketRepository _repository;

  CreateTiketUseCase(this._repository);

  /// Execute the use case to create a new ticket
  ///
  /// Parameters:
  /// - judul: Title/subject of the ticket
  /// - deskripsi: Detailed description of the issue
  /// - idUser: ID of the user creating the ticket
  ///
  /// Returns Right(TiketEntity) with status='open' on success
  /// Returns Left(TiketFailure) on failure
  Future<Either<TiketFailure, TiketEntity>> call({
    required String judul,
    required String deskripsi,
    required String idUser,
  }) async {
    // Validate input
    if (judul.trim().isEmpty) {
      return Left(TiketFailure('Ticket title cannot be empty'));
    }

    if (deskripsi.trim().isEmpty) {
      return Left(TiketFailure('Ticket description cannot be empty'));
    }

    if (idUser.trim().isEmpty) {
      return Left(TiketFailure('User ID cannot be empty'));
    }

    // Create the ticket with status automatically set to 'open'
    final result = await _repository.createTiket(
      judul: judul.trim(),
      deskripsi: deskripsi.trim(),
      idUser: idUser.trim(),
    );

    // Verify that the created ticket has status 'open'
    return result.fold(
      (failure) => Left(failure),
      (tiket) {
        if (tiket.status != TiketStatus.open) {
          // This should never happen if repository is implemented correctly
          return Left(TiketFailure(
            'Invalid ticket status: New tickets must be created with status "open"',
          ));
        }
        return Right(tiket);
      },
    );
  }
}