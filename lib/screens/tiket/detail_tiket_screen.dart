import 'package:flutter/material.dart';
import '../../models/tiket_model.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/app_text_field.dart';

class DetailTiketScreen extends StatefulWidget {
  final TiketModel tiket;
  final String role;

  const DetailTiketScreen({
    super.key,
    required this.tiket,
    required this.role,
  });

  @override
  State<DetailTiketScreen> createState() => _DetailTiketScreenState();
}

class _DetailTiketScreenState extends State<DetailTiketScreen> {
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, dynamic>> _komentarList = [
    {'nama': 'Admin', 'peran': 'Helpdesk', 'pesan': 'Mohon ditunggu, jaringan sedang kami periksa kembali.', 'role': 'admin'},
    {'nama': 'User 1', 'peran': 'Pelapor', 'pesan': 'Baik, terima kasih pak.', 'role': 'user'},
  ];

  late StatusTiket _currentStatus;
  late StatusTiket _tempStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.tiket.status;
    _tempStatus = widget.tiket.status;
  }

  String _statusToString(StatusTiket status) {
    switch (status) {
      case StatusTiket.open: return 'Open';
      case StatusTiket.inProgress: return 'In Progress';
      case StatusTiket.resolved: return 'Resolved';
      case StatusTiket.closed: return 'Closed';
    }
  }

  StatusTiket _stringToStatus(String status) {
    switch (status) {
      case 'Open': return StatusTiket.open;
      case 'In Progress': return StatusTiket.inProgress;
      case 'Resolved': return StatusTiket.resolved;
      case 'Closed': return StatusTiket.closed;
      default: return StatusTiket.open;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

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
                                'Tiket #${widget.tiket.id}',
                                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                              ),
                              StatusBadge(status: _currentStatus),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.tiket.judul,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Dibuat pada: ${widget.tiket.createdAt.toString().substring(0, 16)}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const Divider(height: 32),
                          const Text(
                            'Deskripsi:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(widget.tiket.deskripsi),
                        ],
                      ),
                    ),
                  ),

                  if (widget.role == 'admin') ...[
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
                              initialValue: _statusToString(_tempStatus),
                              items: ['Open', 'In Progress', 'Resolved', 'Closed']
                                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _tempStatus = _stringToStatus(val);
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Assign (Tugaskan Ke)',
                                border: OutlineInputBorder(),
                              ),
                              initialValue: 'Belum di-assign',
                              items: ['Belum di-assign', 'Admin Ali', 'Admin Budi', 'Helpdesk Cici']
                                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                  .toList(),
                              onChanged: (val) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Ditugaskan kepada $val (Simulasi)')),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _currentStatus = _tempStatus;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Perubahan tiket berhasil disimpan!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Simpan Perubahan'),
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
                  
                  ..._komentarList.map((k) => _buildCommentBubble(
                    namapengirim: k['nama'], 
                    peran: k['peran'], 
                    pesan: k['pesan'], 
                    isMe: widget.role == k['role']
                  )),
                  
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
                Expanded(
                  child: AppTextField(
                    controller: _commentController,
                    label: '',
                    hint: 'Ketik balasan / komentar...',
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    if (_commentController.text.trim().isEmpty) return;
                    setState(() {
                      _komentarList.add({
                        'nama': widget.role == 'admin' ? 'Admin' : 'User 1',
                        'peran': widget.role == 'admin' ? 'Helpdesk' : 'Pelapor',
                        'pesan': _commentController.text.trim(),
                        'role': widget.role,
                      });
                      _commentController.clear();
                    });
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
