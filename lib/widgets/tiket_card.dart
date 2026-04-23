import 'package:flutter/material.dart';
import 'package:e_ticketing_helpdesk/models/tiket_model.dart';
import 'status_badge.dart';

class TiketCard extends StatelessWidget {
  final TiketModel tiket;
  final VoidCallback onTap;

  const TiketCard({
    super.key,
    required this.tiket,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: onTap,
        title: Text(
          tiket.judul,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              tiket.deskripsi,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              'Tanggal: ${tiket.createdAt.toString().substring(0, 10)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: StatusBadge(status: tiket.status),
      ),
    );
  }
}