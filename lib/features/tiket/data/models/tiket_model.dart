import '../../domain/entities/tiket_entity.dart';

/// Data transfer object for Tiket entity
/// Used for data mapping between Supabase and domain layer
class TiketModel {
  final String id;
  final String judul;
  final String deskripsi;
  final TiketStatus status;
  final String idUser;
  final String? idAdmin;
  final String? idHelpdesk;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TiketModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.status,
    required this.idUser,
    this.idAdmin,
    this.idHelpdesk,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create TiketModel from database record (Map)
  factory TiketModel.fromJson(Map<String, dynamic> json) {
    return TiketModel(
      id: json['id'] as String,
      judul: json['judul'] as String,
      deskripsi: json['deskripsi'] as String,
      status: _parseStatus(json['status'] as String),
      idUser: json['id_user'] as String,
      idAdmin: json['id_admin'] as String?,
      idHelpdesk: json['id_helpdesk'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to database JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'status': _statusToString(status),
      'id_user': idUser,
      'id_admin': idAdmin,
      'id_helpdesk': idHelpdesk,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to domain entity
  TiketEntity toEntity() {
    return TiketEntity(
      id: id,
      judul: judul,
      deskripsi: deskripsi,
      status: status,
      idUser: idUser,
      idAdmin: idAdmin,
      idHelpdesk: idHelpdesk,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create TiketModel from domain entity
  factory TiketModel.fromEntity(TiketEntity entity) {
    return TiketModel(
      id: entity.id,
      judul: entity.judul,
      deskripsi: entity.deskripsi,
      status: entity.status,
      idUser: entity.idUser,
      idAdmin: entity.idAdmin,
      idHelpdesk: entity.idHelpdesk,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static TiketStatus _parseStatus(String statusStr) {
    switch (statusStr.toLowerCase()) {
      case 'assign':
        return TiketStatus.assign;
      case 'in_progress':
        return TiketStatus.inProgress;
      case 'close':
        return TiketStatus.close;
      case 'open':
      default:
        return TiketStatus.open;
    }
  }

  static String _statusToString(TiketStatus status) {
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
