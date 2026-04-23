enum StatusTiket { open, inProgress, resolved, closed }

class TiketModel {
  final String id;
  final String judul;
  final String deskripsi;
  final StatusTiket status;
  final DateTime createdAt;
  final String idUser; // ID Pelapor
  final String? idAdmin; // ID Admin yang menangani laporan

  const TiketModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.status,
    required this.createdAt,
    required this.idUser,
    this.idAdmin,
  });
}