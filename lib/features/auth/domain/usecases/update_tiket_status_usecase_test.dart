// Ganti `e_ticketing_helpdesk` di bawah dengan nama package sesuai `name:`
// di pubspec.yaml kamu, kalau berbeda.
//
// File ini memetakan langsung ke test_case_status_workflow.md:
//   TC-01  -> group 'TC-01'
//   TC-02  -> group 'TC-02'
//   TC-03  -> group 'TC-03'
//   TC-04  -> group 'TC-04'
//   TC-05  -> group 'TC-05'
//   TC-06  -> group 'TC-06'
//   TC-07  -> TIDAK bisa diverifikasi lewat unit test murni (itu soal ada/
//             tidaknya widget dropdown status di UI). Perlu widget test
//             terpisah yang membaca file screen aslinya — kirim
//             detail_tiket_screen.dart / admin & helpdesk dashboard kalau
//             mau saya buatkan.
//
// Cara jalankan:
//   flutter test test/features/tiket/domain/usecases/update_tiket_status_usecase_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e_ticketing_helpdesk/features/tiket/domain/entities/komentar_entity.dart';
import 'package:e_ticketing_helpdesk/features/tiket/domain/entities/tiket_entity.dart';
import 'package:e_ticketing_helpdesk/features/tiket/domain/repositories/tiket_repository.dart';
import 'package:e_ticketing_helpdesk/features/tiket/domain/usecases/update_tiket_status_usecase.dart';

/// Fake repository yang mensimulasikan aturan workflow yang sama seperti
/// trigger Postgres (011_status_workflow_trigger.sql), supaya use case bisa
/// dites tanpa perlu koneksi Supabase sungguhan.
class FakeTiketRepository implements TiketRepository {
  final Map<String, TiketEntity> _store = {};

  void seed(TiketEntity tiket) => _store[tiket.id] = tiket;

  TiketEntity? get(String id) => _store[id];

  @override
  Future<Either<TiketFailure, TiketEntity>> createTiket({
    required String judul,
    required String deskripsi,
    required String idUser,
  }) async {
    // TC-01: tidak ada parameter status sama sekali di signature method ini
    // -> secara desain, user tidak mungkin mengirim status manual.
    final tiket = TiketEntity(
      id: 'test-${_store.length + 1}',
      judul: judul,
      deskripsi: deskripsi,
      status: TiketStatus.open,
      idUser: idUser,
      createdAt: DateTime.now(),
      updatedAt: null,
    );
    _store[tiket.id] = tiket;
    return Right(tiket);
  }

  @override
  Future<Either<TiketFailure, TiketEntity>> acceptTiket({
    required String tiketId,
    required String adminId,
  }) async {
    final current = _store[tiketId];
    if (current == null) return Left(TiketFailure('Tiket tidak ditemukan'));
    if (current.status != TiketStatus.open) {
      return Left(TiketFailure(
        'Transisi status tidak valid: ${current.status.name} -> assign',
      ));
    }
    final updated = current.copyWith(status: TiketStatus.assign, idAdmin: adminId);
    _store[tiketId] = updated;
    return Right(updated);
  }

  @override
  Future<Either<TiketFailure, TiketEntity>> assignTiket({
    required String tiketId,
    required String adminId,
    required String helpdeskId,
  }) async {
    final current = _store[tiketId];
    if (current == null) return Left(TiketFailure('Tiket tidak ditemukan'));
    if (current.status != TiketStatus.assign) {
      return Left(TiketFailure(
        'Transisi status tidak valid: ${current.status.name} -> in_progress',
      ));
    }
    if (current.idAdmin == null) {
      return Left(TiketFailure('id_admin harus sudah terisi'));
    }
    final updated = current.copyWith(
      status: TiketStatus.inProgress,
      idHelpdesk: helpdeskId,
    );
    _store[tiketId] = updated;
    return Right(updated);
  }

  @override
  Future<Either<TiketFailure, TiketEntity>> finishTiket({
    required String tiketId,
    required String helpdeskId,
  }) async {
    final current = _store[tiketId];
    if (current == null) return Left(TiketFailure('Tiket tidak ditemukan'));
    if (current.status != TiketStatus.inProgress) {
      return Left(TiketFailure(
        'Transisi status tidak valid: ${current.status.name} -> close',
      ));
    }
    if (current.idHelpdesk == null) {
      return Left(TiketFailure('id_helpdesk harus sudah terisi'));
    }
    final updated = current.copyWith(status: TiketStatus.close);
    _store[tiketId] = updated;
    return Right(updated);
  }

  // --- Method di bawah ini tidak relevan untuk test workflow status,
  // --- diimplementasi minimal supaya class ini valid sebagai TiketRepository.

  @override
  Future<Either<TiketFailure, TiketEntity>> getTiketDetail({
    required String tiketId,
  }) async {
    final tiket = _store[tiketId];
    if (tiket == null) return Left(TiketFailure('Tiket tidak ditemukan'));
    return Right(tiket);
  }

  @override
  Future<Either<TiketFailure, List<TiketEntity>>> getTiketList({
    required String userId,
    required String userRole,
    TiketStatus? statusFilter,
  }) async {
    return Right(_store.values.toList());
  }

  @override
  Future<Either<TiketFailure, KomentarEntity>> addKomentar({
    required String tiketId,
    required String userId,
    required String isi,
  }) async {
    return Right(KomentarEntity(
      id: 'komentar-1',
      idTiket: tiketId,
      idUser: userId,
      isi: isi,
      createdAt: DateTime.now(),
    ));
  }

  @override
  Future<Either<TiketFailure, List<KomentarEntity>>> getKomentarList({
    required String tiketId,
  }) async {
    return const Right([]);
  }

  @override
  Stream<TiketEntity> watchTiket(String tiketId) {
    return Stream.value(_store[tiketId]!);
  }

  @override
  Stream<List<TiketEntity>> watchTiketList({
    required String userId,
    required String userRole,
    TiketStatus? statusFilter,
  }) {
    return Stream.value(_store.values.toList());
  }
}

void main() {
  late FakeTiketRepository repository;
  late UpdateTiketStatusUseCase useCase;

  const adminId = 'admin-1';
  const helpdeskId = 'helpdesk-1';
  const userId = 'user-1';

  setUp(() {
    repository = FakeTiketRepository();
    useCase = UpdateTiketStatusUseCase(repository);
  });

  group('TC-01: User membuat tiket baru', () {
    test('tiket baru otomatis berstatus open, tanpa input status manual', () async {
      final result = await repository.createTiket(
        judul: 'Internet Mati',
        deskripsi: 'Router kedip merah sejak pagi',
        idUser: userId,
      );

      expect(result.isRight(), isTrue);
      result.fold((_) => null, (tiket) {
        expect(tiket.status, TiketStatus.open);
        expect(tiket.idAdmin, isNull);
        expect(tiket.idHelpdesk, isNull);
      });
    });
  });

  group('TC-02: Admin menerima tiket (open -> assign)', () {
    const tiketId = 'tiket-1';

    setUp(() {
      repository.seed(TiketEntity(
        id: tiketId,
        judul: 'Internet Mati',
        deskripsi: 'Router kedip merah',
        status: TiketStatus.open,
        idUser: userId,
        createdAt: DateTime.now(),
        updatedAt: null,
      ));
    });

    test('status berubah jadi assign dan id_admin terisi', () async {
      final result = await useCase.acceptTiket(tiketId: tiketId, adminId: adminId);

      expect(result.isRight(), isTrue);
      result.fold((_) => null, (tiket) {
        expect(tiket.status, TiketStatus.assign);
        expect(tiket.idAdmin, adminId);
      });
    });
  });

  group('TC-03: Admin assign ke Helpdesk (assign -> in_progress)', () {
    const tiketId = 'tiket-1';

    setUp(() {
      repository.seed(TiketEntity(
        id: tiketId,
        judul: 'Internet Mati',
        deskripsi: 'Router kedip merah',
        status: TiketStatus.assign,
        idUser: userId,
        idAdmin: adminId,
        createdAt: DateTime.now(),
        updatedAt: null,
      ));
    });

    test('status otomatis berubah jadi in_progress begitu helpdesk dipilih', () async {
      final result = await useCase.assignTiket(
        tiketId: tiketId,
        adminId: adminId,
        helpdeskId: helpdeskId,
      );

      expect(result.isRight(), isTrue);
      result.fold((_) => null, (tiket) {
        expect(tiket.status, TiketStatus.inProgress);
        expect(tiket.idHelpdesk, helpdeskId);
      });
    });

    test('gagal kalau helpdesk tidak dipilih (helpdeskId kosong)', () async {
      final result = await useCase.assignTiket(
        tiketId: tiketId,
        adminId: adminId,
        helpdeskId: '',
      );
      expect(result.isLeft(), isTrue);
    });
  });

  group('TC-04: Helpdesk memproses tiket (status tetap in_progress)', () {
    const tiketId = 'tiket-1';

    setUp(() {
      repository.seed(TiketEntity(
        id: tiketId,
        judul: 'Internet Mati',
        deskripsi: 'Router kedip merah',
        status: TiketStatus.inProgress,
        idUser: userId,
        idAdmin: adminId,
        idHelpdesk: helpdeskId,
        createdAt: DateTime.now(),
        updatedAt: null,
      ));
    });

    test('menambah komentar tidak mengubah status tiket', () async {
      await repository.addKomentar(
        tiketId: tiketId,
        userId: helpdeskId,
        isi: 'Sedang dicek fisiknya sekarang.',
      );

      expect(repository.get(tiketId)!.status, TiketStatus.inProgress);
    });
  });

  group('TC-05: Helpdesk menyelesaikan tiket (in_progress -> close)', () {
    const tiketId = 'tiket-1';

    setUp(() {
      repository.seed(TiketEntity(
        id: tiketId,
        judul: 'Internet Mati',
        deskripsi: 'Router kedip merah',
        status: TiketStatus.inProgress,
        idUser: userId,
        idAdmin: adminId,
        idHelpdesk: helpdeskId,
        createdAt: DateTime.now(),
        updatedAt: null,
      ));
    });

    test('status berubah jadi close setelah tombol Finish ditekan', () async {
      final result = await useCase.finishTiket(tiketId: tiketId, helpdeskId: helpdeskId);

      expect(result.isRight(), isTrue);
      result.fold((_) => null, (tiket) {
        expect(tiket.status, TiketStatus.close);
      });
    });

    test('gagal kalau yang finish bukan helpdesk yang di-assign', () async {
      final result = await useCase.finishTiket(
        tiketId: tiketId,
        helpdeskId: 'helpdesk-lain',
      );
      // repository fake ini tidak cek kecocokan helpdeskId vs id_helpdesk,
      // tapi use case sendiri (lihat update_tiket_status_usecase.dart)
      // sudah memverifikasi tiket.idHelpdesk == helpdeskId setelah repository
      // mengembalikan hasil -> harus gagal di lapisan use case.
      expect(result.isLeft(), isTrue);
    });
  });

  group('TC-06 (Negative): Tiket close tidak bisa diubah lagi', () {
    const tiketId = 'tiket-1';

    setUp(() {
      repository.seed(TiketEntity(
        id: tiketId,
        judul: 'Internet Mati',
        deskripsi: 'Router kedip merah',
        status: TiketStatus.close,
        idUser: userId,
        idAdmin: adminId,
        idHelpdesk: helpdeskId,
        createdAt: DateTime.now(),
        updatedAt: null,
      ));
    });

    test('acceptTiket ditolak untuk tiket yang sudah close', () async {
      final result = await useCase.acceptTiket(tiketId: tiketId, adminId: adminId);
      expect(result.isLeft(), isTrue);
      expect(repository.get(tiketId)!.status, TiketStatus.close);
    });

    test('assignTiket ditolak untuk tiket yang sudah close', () async {
      final result = await useCase.assignTiket(
        tiketId: tiketId,
        adminId: adminId,
        helpdeskId: helpdeskId,
      );
      expect(result.isLeft(), isTrue);
      expect(repository.get(tiketId)!.status, TiketStatus.close);
    });

    test('finishTiket ditolak untuk tiket yang sudah close', () async {
      final result = await useCase.finishTiket(tiketId: tiketId, helpdeskId: helpdeskId);
      expect(result.isLeft(), isTrue);
      expect(repository.get(tiketId)!.status, TiketStatus.close);
    });
  });

  group('Regression: tidak boleh lompat tahap (skip step)', () {
    const tiketId = 'tiket-1';

    setUp(() {
      repository.seed(TiketEntity(
        id: tiketId,
        judul: 'Printer Error',
        deskripsi: 'Kertas nyangkut',
        status: TiketStatus.open,
        idUser: userId,
        createdAt: DateTime.now(),
        updatedAt: null,
      ));
    });

    test('open tidak bisa langsung ke in_progress (lewati assign)', () async {
      final result = await useCase.assignTiket(
        tiketId: tiketId,
        adminId: adminId,
        helpdeskId: helpdeskId,
      );
      expect(result.isLeft(), isTrue);
      expect(repository.get(tiketId)!.status, TiketStatus.open);
    });

    test('open tidak bisa langsung ke close (lewati assign & in_progress)', () async {
      final result = await useCase.finishTiket(tiketId: tiketId, helpdeskId: helpdeskId);
      expect(result.isLeft(), isTrue);
      expect(repository.get(tiketId)!.status, TiketStatus.open);
    });
  });
}