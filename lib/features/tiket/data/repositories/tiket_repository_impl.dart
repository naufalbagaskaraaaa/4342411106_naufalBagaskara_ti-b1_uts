import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../datasources/supabase_tiket_datasource.dart';
import '../models/komentar_model.dart';
import '../models/tiket_model.dart';
import '../../domain/entities/komentar_entity.dart';
import '../../domain/entities/tiket_entity.dart';
import '../../domain/repositories/tiket_repository.dart';

/// Implementation of TiketRepository using Supabase data source.
/// Bridges the domain layer with the data layer.
class TiketRepositoryImpl implements TiketRepository {
  final SupabaseTiketDataSource dataSource;
  static const _uuid = Uuid();

  TiketRepositoryImpl(this.dataSource);

  @override
  Future<Either<TiketFailure, TiketEntity>> createTiket({
    required String judul,
    required String deskripsi,
    required String idUser,
  }) async {
    try {
      final tiketModel = TiketModel(
        id: _generateId(),
        judul: judul,
        deskripsi: deskripsi,
        status: TiketStatus.open,
        idUser: idUser,
        idAdmin: null,
        idHelpdesk: null,
        createdAt: DateTime.now(),
      );

      final createdModel = await dataSource.createTiket(tiketModel);
      return Right(createdModel.toEntity());
    } catch (e) {
      return Left(TiketFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<TiketFailure, List<TiketEntity>>> getTiketList({
    required String userId,
    required String userRole,
    TiketStatus? statusFilter,
  }) async {
    try {
      var tiketModels = await dataSource.getTiketList(userId, userRole);
      if (statusFilter != null) {
        tiketModels = tiketModels.where((model) => model.status == statusFilter).toList();
      }

      return Right(tiketModels.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(TiketFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<TiketFailure, TiketEntity>> getTiketDetail({
    required String tiketId,
  }) async {
    try {
      final tiketModel = await dataSource.getTiketDetail(tiketId);
      final komentarModels = await dataSource.getKomentarList(tiketId);
      final tiketEntity = tiketModel.toEntity().copyWith(
        komentar: komentarModels.map((model) => model.toEntity()).toList(),
      );
      return Right(tiketEntity);
    } catch (e) {
      return Left(TiketFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<TiketFailure, TiketEntity>> acceptTiket({
    required String tiketId,
    required String adminId,
  }) async {
    try {
      final updatedModel = await dataSource.updateTiketStatus(
        tiketId,
        TiketStatus.assign,
        adminId: adminId,
      );
      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(_mapStatusTransitionError(e));
    }
  }

  @override
  Future<Either<TiketFailure, TiketEntity>> assignTiket({
    required String tiketId,
    required String adminId,
    required String helpdeskId,
  }) async {
    try {
      final updatedModel = await dataSource.updateTiketStatus(
        tiketId,
        TiketStatus.inProgress,
        adminId: adminId,
        helpdeskId: helpdeskId,
      );
      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(_mapStatusTransitionError(e));
    }
  }

  @override
  Future<Either<TiketFailure, TiketEntity>> finishTiket({
    required String tiketId,
    required String helpdeskId,
  }) async {
    try {
      final updatedModel = await dataSource.updateTiketStatus(
        tiketId,
        TiketStatus.close,
        helpdeskId: helpdeskId,
      );
      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(_mapStatusTransitionError(e));
    }
  }

  @override
  Future<Either<TiketFailure, KomentarEntity>> addKomentar({
    required String tiketId,
    required String userId,
    required String isi,
  }) async {
    try {
      final komentarModel = KomentarModel(
        id: _generateId(),
        idTiket: tiketId,
        idUser: userId,
        isi: isi,
        createdAt: DateTime.now(),
      );

      final createdModel = await dataSource.addKomentar(komentarModel);
      return Right(createdModel.toEntity());
    } catch (e) {
      return Left(TiketFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<TiketFailure, List<KomentarEntity>>> getKomentarList({
    required String tiketId,
  }) async {
    try {
      final komentarModels = await dataSource.getKomentarList(tiketId);
      return Right(komentarModels.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(TiketFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Stream<TiketEntity> watchTiket(String tiketId) {
    return dataSource.watchTiket(tiketId).map((model) => model.toEntity());
  }

  @override
  Stream<List<TiketEntity>> watchTiketList({
    required String userId,
    required String userRole,
    TiketStatus? statusFilter,
  }) {
    return dataSource.watchTiketList(userId, userRole).map((tiketModels) {
      var filtered = tiketModels;
      if (statusFilter != null) {
        filtered = filtered.where((model) => model.status == statusFilter).toList();
      }
      return filtered.map((model) => model.toEntity()).toList();
    });
  }

  /// FIXED: sebelumnya pakai `DateTime.now().microsecondsSinceEpoch.toString()`,
  /// yang menghasilkan string angka BUKAN UUID valid. Kolom `id` di tabel
  /// `tickets`/`comments` bertipe UUID (`DEFAULT gen_random_uuid()`), jadi id
  /// buatan sendiri harus benar-benar berformat UUID v4, atau insert akan gagal
  /// dengan error "invalid input syntax for type uuid".
  String _generateId() => _uuid.v4();

  /// Mengekstrak pesan asli dari trigger Postgres (RAISE EXCEPTION) supaya
  /// pesan error yang sampai ke use case/UI bersih, bukan string
  /// "Unexpected error: Failed to update ticket status: PostgrestException(...)"
  /// yang berlapis-lapis dan sulit ditampilkan ke pengguna.
  TiketFailure _mapStatusTransitionError(Object e) {
    final raw = e.toString();

    // PostgrestException biasanya berbentuk:
    // PostgrestException(message: <pesan RAISE EXCEPTION>, code: P0001, ...)
    final match = RegExp(r'message:\s*([^,]+(?:,[^,]+)*?)(?:,\s*code:|\))')
        .firstMatch(raw);

    if (match != null) {
      final cleanMessage = match.group(1)?.trim();
      if (cleanMessage != null && cleanMessage.isNotEmpty) {
        return TiketFailure(cleanMessage);
      }
    }

    return TiketFailure('Gagal mengubah status tiket: $raw');
  }
}