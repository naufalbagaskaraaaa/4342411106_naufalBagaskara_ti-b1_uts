import 'package:flutter/material.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Masukkan email Anda yang terdaftar, kami akan mengirimkan tautan untuk mengatur ulang kata sandi Anda.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const AppTextField(
              label: 'Email',
              hint: 'contoh: udin@email.com',
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Kirim Instruksi (Simulasi)',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Instruksi reset password berhasil dikirim ke email!'),
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
