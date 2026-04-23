class KomentarModel {
  final String id;
  final String idTiket;
  final String idUser; // ID komentar
  final String isi;
  final DateTime createdAt;

  const KomentarModel({
    required this.id,
    required this.idTiket,
    required this.idUser,
    required this.isi,
    required this.createdAt,
  });
}