/// Comment entity representing a comment/updates on a support ticket.
///
/// Users can add comments to tickets to provide additional information,
/// updates, or resolution details.
class KomentarEntity {
  /// Unique identifier for the comment
  final String id;

  /// ID of the ticket this comment belongs to
  final String idTiket;

  /// ID of the user who wrote this comment
  final String idUser;

  /// Content of the comment
  final String isi;

  /// Timestamp when comment was created
  final DateTime createdAt;

  const KomentarEntity({
    required this.id,
    required this.idTiket,
    required this.idUser,
    required this.isi,
    required this.createdAt,
  });

  /// Creates a copy of this comment with updated fields
  KomentarEntity copyWith({
    String? id,
    String? idTiket,
    String? idUser,
    String? isi,
    DateTime? createdAt,
  }) {
    return KomentarEntity(
      id: id ?? this.id,
      idTiket: idTiket ?? this.idTiket,
      idUser: idUser ?? this.idUser,
      isi: isi ?? this.isi,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is KomentarEntity &&
      other.id == id &&
      other.idTiket == idTiket &&
      other.idUser == idUser &&
      other.isi == isi &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      idTiket.hashCode ^
      idUser.hashCode ^
      isi.hashCode ^
      createdAt.hashCode;
  }
}