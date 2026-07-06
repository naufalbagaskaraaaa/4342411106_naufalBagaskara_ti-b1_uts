import 'package:dartz/dartz.dart';
import '../entities/tiket_entity.dart';
import '../entities/komentar_entity.dart';

/// Failure types for ticket operations
class TiketFailure {
  final String message;
  final int? statusCode;

  const TiketFailure(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Repository interface for ticket operations following the repository pattern.
///
/// This interface defines all ticket-related operations that will be implemented
/// in the data layer. Use cases interact with this interface, maintaining
/// Clean Architecture principles.
abstract class TiketRepository {
  /// Create a new ticket with status set to 'open' automatically
  ///
  /// Returns Right(TiketEntity) on success or Left(TiketFailure) on failure
  Future<Either<TiketFailure, TiketEntity>> createTiket({
    required String judul,
    required String deskripsi,
    required String idUser,
  });

  /// Get list of tickets based on user role
  ///
  /// For regular users: returns only their own tickets
  /// For admin/helpdesk: returns all tickets
  ///
  /// Returns Right(List<TiketEntity>) on success or Left(TiketFailure) on failure
  Future<Either<TiketFailure, List<TiketEntity>>> getTiketList({
    required String userId,
    required String userRole,
    TiketStatus? statusFilter, // Optional filter by status
  });

  /// Get a single ticket by ID with all comments
  ///
  /// Returns Right(TiketEntity) on success or Left(TiketFailure) on failure
  Future<Either<TiketFailure, TiketEntity>> getTiketDetail({
    required String tiketId,
  });

  /// Accept a ticket (admin only) - changes status from 'open' to 'assign'
  ///
  /// This is the ONLY way to transition a ticket from 'open' to 'assign'
  ///
  /// Returns Right(TiketEntity) on success or Left(TiketFailure) on failure
  Future<Either<TiketFailure, TiketEntity>> acceptTiket({
    required String tiketId,
    required String adminId,
  });

  /// Assign a ticket to helpdesk (admin only) - changes status from 'assign' to 'in_progress'
  ///
  /// This is the ONLY way to transition a ticket from 'assign' to 'in_progress'
  ///
  /// Returns Right(TiketEntity) on success or Left(TiketFailure) on failure
  Future<Either<TiketFailure, TiketEntity>> assignTiket({
    required String tiketId,
    required String adminId,
    required String helpdeskId,
  });

  /// Mark ticket as finished (helpdesk only) - changes status from 'in_progress' to 'close'
  ///
  /// This is the ONLY way to transition a ticket from 'in_progress' to 'close'
  ///
  /// Returns Right(TiketEntity) on success or Left(TiketFailure) on failure
  Future<Either<TiketFailure, TiketEntity>> finishTiket({
    required String tiketId,
    required String helpdeskId,
  });

  /// Add a comment to a ticket
  ///
  /// Returns Right(KomentarEntity) on success or Left(TiketFailure) on failure
  Future<Either<TiketFailure, KomentarEntity>> addKomentar({
    required String tiketId,
    required String userId,
    required String isi,
  });

  /// Get all comments for a specific ticket
  ///
  /// Returns Right(List<KomentarEntity>) on success or Left(TiketFailure) on failure
  Future<Either<TiketFailure, List<KomentarEntity>>> getKomentarList({
    required String tiketId,
  });

  /// Watch ticket updates in real-time
  ///
  /// Returns a Stream that emits new TiketEntity whenever the ticket changes
  /// Useful for real-time UI updates
  Stream<TiketEntity> watchTiket(String tiketId);

  /// Watch ticket list updates in real-time
  ///
  /// Returns a Stream that emits new List<TiketEntity> whenever tickets change
  /// Useful for real-time UI updates for ticket lists
  Stream<List<TiketEntity>> watchTiketList({
    required String userId,
    required String userRole,
    TiketStatus? statusFilter,
  });
}