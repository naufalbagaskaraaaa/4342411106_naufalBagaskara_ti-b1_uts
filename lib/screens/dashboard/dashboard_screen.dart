import 'package:flutter/material.dart';
import '../../core/dummy/dummy_data.dart';
import '../../models/tiket_model.dart';
import '../../widgets/tiket_card.dart';
import '../tiket/detail_tiket_screen.dart';
import '../tiket/notification_screen.dart';

class DashboardScreen extends StatelessWidget {
  final String role;
  const DashboardScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final myTikets = role == 'admin' 
        ? DummyData.tikets 
        : DummyData.tikets.where((t) => t.idUser == 'u2').toList();
    final tiketTerbaru = myTikets.take(5).toList();

    int countTotal = myTikets.length;
    int countOpen = myTikets.where((t) => t.status == StatusTiket.open).length;
    int countProgress = myTikets.where((t) => t.status == StatusTiket.inProgress).length;
    int countResolved = myTikets.where((t) => t.status == StatusTiket.resolved).length;
    int countClosed = myTikets.where((t) => t.status == StatusTiket.closed).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(role == 'admin' ? 'Dashboard Admin' : 'Dashboard Saya'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
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
              'Dashboard Tiket',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatCard(context, 'Total', countTotal.toString(), Colors.blue),
                  const SizedBox(width: 12),
                  _buildStatCard(context, 'Open', countOpen.toString(), Colors.redAccent),
                  const SizedBox(width: 12),
                  _buildStatCard(context, 'In Progress', countProgress.toString(), Colors.orange),
                  const SizedBox(width: 12),
                  _buildStatCard(context, 'Resolved', countResolved.toString(), Colors.purple),
                  const SizedBox(width: 12),
                  _buildStatCard(context, 'Closed', countClosed.toString(), Colors.green),
                ],
              ),
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
    return Container(
      width: 110,
      height: 96,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
