import 'package:flutter/material.dart';
import '../../core/theme/theme_notifier.dart';
import '../../widgets/app_button.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String role;
  
  const ProfileScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final String namaUser = role == 'admin' ? 'Admin Helpdesk' : 'Budi Santoso';
    final String emailUser = role == 'admin' ? 'admin@helpdesk.com' : 'budi@student.com';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              namaUser,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              emailUser,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                role.toUpperCase(),
                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            
            ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (context, currentMode, _) {
                return SwitchListTile(
                  title: const Text('Mode Gelap (Dark Mode)'),
                  secondary: const Icon(Icons.dark_mode_outlined),
                  value: currentMode == ThemeMode.dark,
                  onChanged: (bool value) {
                    themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                  },
                );
              },
            ),
            
            const Divider(),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Riwayat Aktivitas'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Menampilkan riwayat...')),
                );
              },
            ),
            const Divider(),
            const SizedBox(height: 32),
            
            AppButton(
              text: 'Keluar (Logout)',
              backgroundColor: Colors.red,
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
