import 'package:flutter/material.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Lengkapi data diri Anda',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Akses penuh untuk pembuatan tiket keluhan.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const AppTextField(
              label: 'Nama Lengkap',
              hint: 'Contoh: Budi Santoso',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            const AppTextField(
              label: 'Email',
              hint: 'Masukkan email aktif',
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 16),
            const AppTextField(
              label: 'Password',
              hint: 'Buat password yang kuat',
              isPassword: true,
              prefixIcon: Icons.lock_outline,
            ),
            const SizedBox(height: 16),
            const AppTextField(
              label: 'Konfirmasi Password',
              hint: 'Ketik ulang password',
              isPassword: true,
              prefixIcon: Icons.lock_outline,
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Daftar Sekarang',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Registrasi Berhasil! Silakan masuk.'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
