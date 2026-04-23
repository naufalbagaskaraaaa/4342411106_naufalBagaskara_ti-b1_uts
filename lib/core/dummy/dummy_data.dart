import '../../models/user_model.dart';
import '../../models/tiket_model.dart';
import '../../models/komentar_model.dart';

class DummyData {
  static final List<UserModel> users = [
    const UserModel(id: 'u1', nama: 'Admin', email: 'admin@example.com', role: 'admin'),
    const UserModel(id: 'u2', nama: 'Naufal', email: 'naufal@example.com', role: 'user'),
    const UserModel(id: 'u3', nama: 'Bagaskara', email: 'bagaskara@example.com', role: 'user'),
  ];

  static final List<TiketModel> tikets = [
    TiketModel(id: 't1', judul: 'Internet Mati', deskripsi: 'Router kedip merah sejak pagi.', status: StatusTiket.open, createdAt: DateTime.now().subtract(const Duration(days: 2)), idUser: 'u2'),
    TiketModel(id: 't2', judul: 'Printer Error', deskripsi: 'Kertas nyangkut di dalam printer.', status: StatusTiket.inProgress, createdAt: DateTime.now().subtract(const Duration(days: 1)), idUser: 'u3', idAdmin: 'u1'),
    TiketModel(id: 't3', judul: 'Layar Blank', deskripsi: 'Monitor mati tapi PC nyala.', status: StatusTiket.resolved, createdAt: DateTime.now().subtract(const Duration(days: 3)), idUser: 'u2', idAdmin: 'u1'),
    TiketModel(id: 't4', judul: 'Lupa Password Email', deskripsi: 'Tolong reset password Outlook.', status: StatusTiket.closed, createdAt: DateTime.now().subtract(const Duration(days: 5)), idUser: 'u3', idAdmin: 'u1'),
    TiketModel(id: 't5', judul: 'Mouse Rusak', deskripsi: 'Kursor tidak bergerak sama sekali.', status: StatusTiket.open, createdAt: DateTime.now().subtract(const Duration(hours: 2)), idUser: 'u2'),
  ];

  static final List<KomentarModel> komentars = [
    KomentarModel(id: 'k1', idTiket: 't1', idUser: 'u2', isi: 'Tolong segera dibantu ya, butuh untuk meeting.', createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 20))),
    KomentarModel(id: 'k2', idTiket: 't1', idUser: 'u1', isi: 'Baik pak, tim sedang meluncur ke ruangan bapak.', createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 10))),

    KomentarModel(id: 'k3', idTiket: 't2', idUser: 'u3', isi: 'Printer di lantai 2 sebelah pantry.', createdAt: DateTime.now().subtract(const Duration(hours: 20))),
    KomentarModel(id: 'k4', idTiket: 't2', idUser: 'u1', isi: 'Siap, sedang saya cek fisiknya sekarang.', createdAt: DateTime.now().subtract(const Duration(hours: 2))),

    KomentarModel(id: 'k5', idTiket: 't3', idUser: 'u2', isi: 'Kabel VGA sudah saya cek tapi masih no signal.', createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 10))),
    KomentarModel(id: 'k6', idTiket: 't3', idUser: 'u1', isi: 'Kabelnya putus di dalam pak, sudah saya ganti baru.', createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 1))),

    KomentarModel(id: 'k7', idTiket: 't4', idUser: 'u3', isi: 'Bisa lewat WA saja password barunya?', createdAt: DateTime.now().subtract(const Duration(days: 4, hours: 20))),
    KomentarModel(id: 'k8', idTiket: 't4', idUser: 'u1', isi: 'Password baru sudah kami kirim via WhatsApp pribadi.', createdAt: DateTime.now().subtract(const Duration(days: 4, hours: 5))),

    KomentarModel(id: 'k9', idTiket: 't5', idUser: 'u2', isi: 'Baterai sudah diganti dua kali tetap mati.', createdAt: DateTime.now().subtract(const Duration(minutes: 50))),
    KomentarModel(id: 'k10', idTiket: 't5', idUser: 'u1', isi: 'Bawa memousenya ke ruang IT lantai 1 pak untuk ditukar.', createdAt: DateTime.now().subtract(const Duration(minutes: 10))),
  ];
}