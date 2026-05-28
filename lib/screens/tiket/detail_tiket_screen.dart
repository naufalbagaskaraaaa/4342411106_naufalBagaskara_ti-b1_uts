import 'package:flutter/material.dart';
import '../../models/tiket_model.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/app_text_field.dart';

class DetailTiketScreen extends StatelessWidget {
  final TiketModel tiket;
  final String role;

  const DetailTiketScreen({
    super.key,
    required this.tiket,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tiket'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tiket #${tiket.id}',
                                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                              ),
                              StatusBadge(status: tiket.status),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            tiket.judul,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Dibuat pada: ${tiket.createdAt.toString().substring(0, 16)}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const Divider(height: 32),
                          const Text(
                            'Deskripsi:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(tiket.deskripsi),
                        ],
                      ),
                    ),
                  ),

                  if (role == 'admin') ...[
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.blue.withOpacity(0.05),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Panel Admin (Aksi Helpdesk)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Update Status Tiket',
                                border: OutlineInputBorder(),
                              ),
                              value: 'Open',
                              items: ['Open', 'In Progress', 'Resolved', 'Closed']
                                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                  .toList(),
                              onChanged: (val) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Status diubah ke $val (Simulasi)')),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Assign (Tugaskan Ke)',
                                border: OutlineInputBorder(),
                              ),
                              value: 'Belum di-assign',
                              items: ['Belum di-assign', 'Admin Ali', 'Admin Budi', 'Helpdesk Cici']
                                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                  .toList(),
                              onChanged: (val) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Ditugaskan kepada $val (Simulasi)')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  const Text(
                    'Riwayat Komentar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildCommentBubble(namapengirim: 'Admin', peran: 'Helpdesk', pesan: 'Mohon ditunggu, jaringan sedang kami periksa kembali.', isMe: role == 'admin'),
                  _buildCommentBubble(namapengirim: 'User 1', peran: 'Pelapor', pesan: 'Baik, terima kasih pak.', isMe: role == 'user'),
                  
                ],
              ),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
            ),
            child: Row(
              children: [
                const Expanded(
                  child: AppTextField(
                    label: '',
                    hint: 'Ketik balasan / komentar...',
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Komentar berhasil dikirim!')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentBubble({required String namapengirim, required String peran, required String pesan, required bool isMe}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        width: 250,
        decoration: BoxDecoration(
          color: isMe ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isMe ? Colors.blue.withOpacity(0.3) : Colors.transparent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$namapengirim ($peran)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isMe ? Colors.blue : Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            Text(pesan),
          ],
        ),
      ),
    );
  }
}
