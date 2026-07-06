import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../models/tiket_model.dart';
import '../models/komentar_model.dart';
import '../../domain/entities/tiket_entity.dart';
import '../../../auth/domain/repositories/auth_repository.dart' show AppAuthException;

/// Supabase implementation of tiket data source
/// Handles all direct Supabase tiket operations
abstract class SupabaseTiketDataSource {
  Future<TiketModel> createTiket(TiketModel tiket);
  Future<List<TiketModel>> getTiketList(String userId, String role);
  Future<TiketModel> getTiketDetail(String tiketId);
  Future<TiketModel> updateTiketStatus(
    String tiketId,
    TiketStatus newStatus, {
    String? adminId,
    String? helpdeskId,
  });
  Future<KomentarModel> addKomentar(KomentarModel komentar);
  Future<List<KomentarModel>> getKomentarList(String tiketId);
  Stream<TiketModel> watchTiket(String tiketId);
  Stream<List<TiketModel>> watchTiketList(String userId, String role);
  Stream<List<TiketModel>> subscribeToTiket(String userId, String role);
}

class SupabaseTiketDataSourceImpl implements SupabaseTiketDataSource {
  final SupabaseClient supabaseClient;

  SupabaseTiketDataSourceImpl(this.supabaseClient);

  @override
  Future<TiketModel> createTiket(TiketModel tiket) async {
    try {
      final response = await supabaseClient
          .from(SupabaseConstants.ticketsTable)
          .insert(tiket.toJson())
          .select()
          .single();

      return TiketModel.fromJson(response);
    } catch (e) {
      throw AppAuthException('Failed to create ticket: ${e.toString()}');
    }
  }

  @override
  Future<List<TiketModel>> getTiketList(String userId, String role) async {
    try {
      List<Map<String, dynamic>> response;

      if (role.toLowerCase() == 'admin') {
        // Admin can see all tickets
        response = await supabaseClient
            .from(SupabaseConstants.ticketsTable)
            .select()
            .order('created_at', ascending: false);
      } else if (role.toLowerCase() == 'helpdesk') {
        // Helpdesk can see assigned tickets
        response = await supabaseClient
            .from(SupabaseConstants.ticketsTable)
            .select()
            .eq('id_helpdesk', userId)
            .order('created_at', ascending: false);
      } else {
        // User can only see their own tickets
        response = await supabaseClient
            .from(SupabaseConstants.ticketsTable)
            .select()
            .eq('id_user', userId)
            .order('created_at', ascending: false);
      }

      return response.map((json) => TiketModel.fromJson(json)).toList();
    } catch (e) {
      throw AppAuthException('Failed to get ticket list: ${e.toString()}');
    }
  }

  @override
  Future<TiketModel> getTiketDetail(String tiketId) async {
    try {
      final response = await supabaseClient
          .from(SupabaseConstants.ticketsTable)
          .select()
          .eq('id', tiketId)
          .single();

      return TiketModel.fromJson(response);
    } catch (e) {
      throw AppAuthException('Failed to get ticket detail: ${e.toString()}');
    }
  }

  @override
  Future<TiketModel> updateTiketStatus(
    String tiketId,
    TiketStatus newStatus,
    {
    String? adminId,
    String? helpdeskId,
  }
  ) async {
    try {
      final statusStr = _statusToString(newStatus);
      final updateData = <String, dynamic>{
        'status': statusStr,
      };

      if (adminId != null) {
        updateData['id_admin'] = adminId;
      }
      if (helpdeskId != null) {
        updateData['id_helpdesk'] = helpdeskId;
      }

      final response = await supabaseClient
          .from(SupabaseConstants.ticketsTable)
          .update(updateData)
          .eq('id', tiketId)
          .select()
          .single();

      return TiketModel.fromJson(response);
    } catch (e) {
      throw AppAuthException('Failed to update ticket status: ${e.toString()}');
    }
  }

  @override
  Future<KomentarModel> addKomentar(KomentarModel komentar) async {
    try {
      final response = await supabaseClient
          .from(SupabaseConstants.commentsTable)
          .insert(komentar.toJson())
          .select()
          .single();

      return KomentarModel.fromJson(response);
    } catch (e) {
      throw AppAuthException('Failed to add comment: ${e.toString()}');
    }
  }

  @override
  Future<List<KomentarModel>> getKomentarList(String tiketId) async {
    try {
      final response = await supabaseClient
          .from(SupabaseConstants.commentsTable)
          .select()
          .eq('id_tiket', tiketId)
          .order('created_at', ascending: true);

      return response.map((json) => KomentarModel.fromJson(json)).toList();
    } catch (e) {
      throw AppAuthException('Failed to get comment list: ${e.toString()}');
    }
  }

  @override
  Stream<TiketModel> watchTiket(String tiketId) {
    return supabaseClient
        .from(SupabaseConstants.ticketsTable)
        .stream(primaryKey: ['id'])
        .eq('id', tiketId)
        .map((rows) => TiketModel.fromJson(rows.first));
  }

  @override
  Stream<List<TiketModel>> watchTiketList(String userId, String role) {
    return subscribeToTiket(userId, role);
  }

  @override
  Stream<List<TiketModel>> subscribeToTiket(String userId, String role) {
    if (role.toLowerCase() == 'admin') {
      // Admin subscribes to all tickets
      return supabaseClient
          .from(SupabaseConstants.ticketsTable)
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .map((list) => list.map((json) => TiketModel.fromJson(json)).toList());
    } else if (role.toLowerCase() == 'helpdesk') {
      // Helpdesk subscribes to assigned tickets
      return supabaseClient
          .from(SupabaseConstants.ticketsTable)
          .stream(primaryKey: ['id'])
          .eq('id_helpdesk', userId)
          .order('created_at', ascending: false)
          .map((list) => list.map((json) => TiketModel.fromJson(json)).toList());
    }

    // User subscribes to their own tickets
    return supabaseClient
        .from(SupabaseConstants.ticketsTable)
        .stream(primaryKey: ['id'])
        .eq('id_user', userId)
        .order('created_at', ascending: false)
        .map((list) => list.map((json) => TiketModel.fromJson(json)).toList());
  }

  String _statusToString(TiketStatus status) {
    switch (status) {
      case TiketStatus.assign:
        return 'assign';
      case TiketStatus.inProgress:
        return 'in_progress';
      case TiketStatus.close:
        return 'close';
      case TiketStatus.open:
        return 'open';
    }
  }
}
