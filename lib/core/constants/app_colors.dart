import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color secondary = Color(0xFF03A9F4);
  
  // background & text (Light Mode)
  static const Color bgLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Colors.white;
  static const Color textLight = Color(0xFF333333);
  
  // background & text (Dark Mode)
  static const Color bgDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textDark = Color(0xFFE0E0E0);
  
  // warna status tiket
  static const Color statusOpen = Color(0xFF2196F3);       // Biru
  static const Color statusInProgress = Color(0xFFFFC107); // Kuning
  static const Color statusResolved = Color(0xFF4CAF50);   // Hijau
  static const Color statusClosed = Color(0xFF9E9E9E);     // Abu-abu
}