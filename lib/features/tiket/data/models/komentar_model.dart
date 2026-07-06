import '../../domain/entities/komentar_entity.dart';

/// Data transfer object for Komentar entity
/// Used for data mapping between Supabase and domain layer
class KomentarModel {
  final String id;
  final String idTiket;
  final String idUser;
  final String isi;
  final DateTime createdAt;

  KomentarModel({
    required this.id,
    required this.idTiket,
    required this.idUser,
    required this.isi,
    required this.createdAt,
  });

  /// Create KomentarModel from database record (Map)
  factory KomentarModel.fromJson(Map<String, dynamic> json) {
    return KomentarModel(
      id: json['id'] as String,
      idTiket: json['id_tiket'] as String,
      idUser: json['id_user'] as String,
      isi: json['isi'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to database JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_tiket': idTiket,
      'id_user': idUser,
      'isi': isi,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convert to domain entity
  KomentarEntity toEntity() {
    return KomentarEntity(
      id: id,
      idTiket: idTiket,
      idUser: idUser,
      isi: isi,
      createdAt: createdAt,
    );
  }

  /// Create KomentarModel from domain entity
  factory KomentarModel.fromEntity(KomentarEntity entity) {
    return KomentarModel(
      id: entity.id,
      idTiket: entity.idTiket,
      idUser: entity.idUser,
      isi: entity.isi,
      createdAt: entity.createdAt,
    );
  }
}
