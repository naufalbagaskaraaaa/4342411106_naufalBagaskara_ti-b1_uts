import 'package:flutter/material.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class CreateTiketScreen extends StatelessWidget {
  const CreateTiketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Tiket Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppTextField(
              label: 'Judul Keluhan',
              hint: 'Contoh: Internet Mati di Ruang Rapat',
            ),
            const SizedBox(height: 16),
            const AppTextField(
              label: 'Deskripsi Detail',
              hint: 'Jelaskan kronologi keluhan Anda...',
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Unggah Lampiran (Opsional)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Simulasi membuka Galeri Perangkat...')),
                      );
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeri'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Simulasi membuka Kamera...')),
                      );
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Kamera'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.5), style: BorderStyle.solid),
              ),
              child: const Center(
                child: Text('Belum ada lampiran dipilih', style: TextStyle(color: Colors.grey)),
              ),
            ),

            const SizedBox(height: 32),
            AppButton(
              text: 'Kirim Tiket',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tiket keluhan berhasil dibuat!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context); // Kembali ke list tiket
              },
            ),
          ],
        ),
      ),
    );
  }
}
