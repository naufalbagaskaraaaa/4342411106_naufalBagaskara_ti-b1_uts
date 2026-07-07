import 'package:flutter/material.dart';
import 'package:e_ticketing_helpdesk/features/tiket/presentation/screens/list_tiket_screen.dart'
    as feature_tiket;
import 'dashboard_screen.dart';
import '../tiket/list_tiket_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  final String role;

  const MainScreen({super.key, required this.role});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    DashboardScreen(role: widget.role),
    // Regular users get the Riverpod-backed ticket screens; admin/helpdesk
    // still use the legacy list until their screens are migrated (Step 10).
    widget.role == 'user'
        ? const feature_tiket.ListTiketScreen()
        : ListTiketScreen(role: widget.role),
    ProfileScreen(role: widget.role),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Tiket',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
