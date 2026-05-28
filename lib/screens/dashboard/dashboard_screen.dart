import 'package:flutter/material.dart';
import '../../core/dummy/dummy_data.dart';
import '../../widgets/tiket_card.dart';
import '../tiket/detail_tiket_screen.dart';
import '../tiket/notification_screen.dart';

class DashboardScreen extends StatelessWidget {
  final String role;
  const DashboardScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final tiketTerbaru = role == 'admin' 
        ? DummyData.tikets.take(3).toList() 
        : DummyData.tikets.where((t) => t.idUser == 'u2').take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(role == 'admin' ? 'Dashboard Admin' : 'Dashboard Saya'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationScreen(role: role),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Tiket',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard(context, 'Total', DummyData.tikets.length.toString(), Colors.blue),
                const SizedBox(width: 12),
                _buildStatCard(context, 'Aktif', '3', Colors.orange),
                const SizedBox(width: 12),
                _buildStatCard(context, 'Selesai', '2', Colors.green),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Tiket Terbaru',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // biar bisa digulir bersama layar
              itemCount: tiketTerbaru.length,
              itemBuilder: (context, index) {
                return TiketCard(
                  tiket: tiketTerbaru[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailTiketScreen(
                          tiket: tiketTerbaru[index],
                          role: role,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
