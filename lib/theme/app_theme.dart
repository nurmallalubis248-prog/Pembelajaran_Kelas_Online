import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Warna & gaya dasar NeXa (diambil dari desain Figma).
class AppColors {
  // Palet utama NeXa
  static const maroon = Color(0xFF800E13); // #800E13
  static const white = Color(0xFFFFFFFF); // #FFFFFF

  /// Alias: warna utama aplikasi = maroon.
  static const primary = maroon;

  static const fieldBorder = Color(0xFFC4727A);
  static const textDark = Color(0xFF1A1A1A);
  static const textGrey = Color(0xFF6B6B6B);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
        fontFamily: 'Poppins',
        // Transisi halaman ala app mobile: geser dari kanan saat maju,
        // geser balik saat kembali (+ swipe dari tepi kiri untuk kembali).
        // Berlaku di Android dan iOS, jadi seragam di semua halaman.
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      );
}
