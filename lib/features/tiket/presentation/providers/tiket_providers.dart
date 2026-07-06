import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_ticketing_helpdesk/core/providers/supabase_client_provider.dart';
import 'package:e_ticketing_helpdesk/features/tiket/data/datasources/supabase_tiket_datasource.dart';
import 'package:e_ticketing_helpdesk/features/tiket/data/repositories/tiket_repository_impl.dart';
import 'package:e_ticketing_helpdesk/features/tiket/domain/entities/komentar_entity.dart';
import 'package:e_ticketing_helpdesk/features/tiket/domain/entities/tiket_entity.dart';
import 'package:e_ticketing_helpdesk/features/tiket/domain/repositories/tiket_repository.dart';
import 'package:e_ticketing_helpdesk/features/tiket/domain/usecases/add_komentar_usecase.dart';
import 'package:e_ticketing_helpdesk/features/tiket/domain/usecases/create_tiket_usecase.dart';
import 'package:e_ticketing_helpdesk/features/tiket/domain/usecases/get_komentar_list_usecase.dart';
import 'package:e_ticketing_helpdesk/features/tiket/domain/usecases/get_tiket_detail_usecase.dart';
import 'package:e_ticketing_helpdesk/features/tiket/domain/usecases/get_tiket_list_usecase.dart';
import 'package:e_ticketing_helpdesk/features/tiket/domain/usecases/update_tiket_status_usecase.dart';

class TiketListParams {
  final String userId;
  final String userRole;
  final TiketStatus? statusFilter;

  const TiketListParams({
    required this.userId,
    required this.userRole,
    this.statusFilter,
  });
}

class TiketDetailParams {
  final String tiketId;

  const TiketDetailParams({required this.tiketId});
}

class KomentarParams {
  final String tiketId;

  const KomentarParams({required this.tiketId});
}

final tiketDataSourceProvider = Provider<SupabaseTiketDataSource>((ref) {
  return SupabaseTiketDataSourceImpl(ref.read(supabaseClientProvider));
});

final tiketRepositoryProvider = Provider<TiketRepository>((ref) {
  return TiketRepositoryImpl(ref.read(tiketDataSourceProvider));
});

final createTiketUseCaseProvider = Provider<CreateTiketUseCase>((ref) {
  return CreateTiketUseCase(ref.read(tiketRepositoryProvider));
});

final getTiketListUseCaseProvider = Provider<GetTiketListUseCase>((ref) {
  return GetTiketListUseCase(ref.read(tiketRepositoryProvider));
});

final getTiketDetailUseCaseProvider = Provider<GetTiketDetailUseCase>((ref) {
  return GetTiketDetailUseCase(ref.read(tiketRepositoryProvider));
});

final updateTiketStatusUseCaseProvider = Provider<UpdateTiketStatusUseCase>((ref) {
  return UpdateTiketStatusUseCase(ref.read(tiketRepositoryProvider));
});

final addKomentarUseCaseProvider = Provider<AddKomentarUseCase>((ref) {
  return AddKomentarUseCase(ref.read(tiketRepositoryProvider));
});

final getKomentarListUseCaseProvider = Provider<GetKomentarListUseCase>((ref) {
  return GetKomentarListUseCase(ref.read(tiketRepositoryProvider));
});

final tiketListProvider = FutureProvider.family<List<TiketEntity>, TiketListParams>((ref, params) async {
  final result = await ref.read(getTiketListUseCaseProvider).call(
        userId: params.userId,
        userRole: params.userRole,
        statusFilter: params.statusFilter,
      );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (tiketList) => tiketList,
  );
});

final tiketDetailProvider = FutureProvider.family<TiketEntity, TiketDetailParams>((ref, params) async {
  final result = await ref.read(getTiketDetailUseCaseProvider).call(
        tiketId: params.tiketId,
      );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (tiket) => tiket,
  );
});

final komentarListProvider = FutureProvider.family<List<KomentarEntity>, KomentarParams>((ref, params) async {
  final result = await ref.read(getKomentarListUseCaseProvider).call(
        tiketId: params.tiketId,
      );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (komentarList) => komentarList,
  );
});
