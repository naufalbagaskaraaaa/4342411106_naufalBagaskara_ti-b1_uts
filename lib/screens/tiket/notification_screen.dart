import 'package:flutter/material.dart';
import '../../core/dummy/dummy_data.dart';
import 'detail_tiket_screen.dart';

class NotificationScreen extends StatelessWidget {
  final String role;
  const NotificationScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dummyNotifUser = [
      {
        'title': 'Tiket Diperbarui',
        'message': 'Status tiket "Internet Mati" Anda telah diubah menjadi "In Progress".',
        'isRead': false,
        'time': '10 menit yang lalu',
        'relatedTiketId': 't1',
      },
      {
        'title': 'Komentar Baru',
        'message': 'Admin membalas keluhan Anda pada tiket "Mouse Rusak".',
        'isRead': true,
        'time': '2 jam yang lalu',
        'relatedTiketId': 't5',
      },
      {
        'title': 'Tiket Selesai',
        'message': 'Tiket "Layar Blank" telah ditandai sebagai Resolved. Terima kasih.',
        'isRead': true,
        'time': '1 hari yang lalu',
        'relatedTiketId': 't3',
      },
    ];

    final List<Map<String, dynamic>> dummyNotifAdmin = [
      {
        'title': 'Tiket Baru Masuk',
        'message': 'Budi Santoso membuat tiket baru: "Internet Mati".',
        'isRead': false,
        'time': 'Baru saja',
        'relatedTiketId': 't1',
      },
      {
        'title': 'Ditugaskan (Assigned)',
        'message': 'Anda ditugaskan (assigned) untuk menangani keluhan "Printer Error".',
        'isRead': false,
        'time': '1 jam yang lalu',
        'relatedTiketId': 't2',
      },
    ];

    final notifications = role == 'admin' ? dummyNotifAdmin : dummyNotifUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi Saya'),
      ),
      body: notifications.isEmpty
          ? const Center(child: Text('Belum ada notifikasi.'))
          : ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  tileColor: notif['isRead'] as bool
                      ? Colors.transparent
                      : Colors.blue.withOpacity(0.05), // indikator belum dibaca
                  leading: CircleAvatar(
                    backgroundColor: (notif['isRead'] as bool) ? Colors.grey[300] : Colors.blue[100],
                    child: Icon(
                      Icons.notifications,
                      color: (notif['isRead'] as bool) ? Colors.grey : Colors.blue,
                    ),
                  ),
                  title: Text(
                    notif['title'] as String,
                    style: TextStyle(
                      fontWeight: (notif['isRead'] as bool) ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(notif['message'] as String),
                      const SizedBox(height: 4),
                      Text(
                        notif['time'] as String,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  onTap: () {
                    final tiketRelevan = DummyData.tikets.firstWhere(
                      (t) => t.id == notif['relatedTiketId'],
                      orElse: () => DummyData.tikets.first, // fallback pencegah error
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailTiketScreen(
                          tiket: tiketRelevan,
                          role: role,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
