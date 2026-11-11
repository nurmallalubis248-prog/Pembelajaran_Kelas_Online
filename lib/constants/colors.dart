import 'package:flutter/material.dart';

class AppColors {
  // Primary Maroon / Deep Crimson from Figma
  static const Color primaryMaroon = Color(0xFF800E13); // #800E13
  static const Color primaryMaroonDark = Color(0xFF6B0B10);
  static const Color primaryMaroonLight = Color(0xFF9E141B);

  // Backgrounds
  static const Color cardBackground = Colors.white;
  static const Color inputBackground = Color(0xFFE8E5F3);
  static const Color inputBackgroundLight = Color(0xFFF1F0F7);

  // Typography
  static const Color textDark = Color(0xFF1F2937);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textWhite = Colors.white;
  static const Color textSubtitle = Color(0xFFF3F4F6);

  // Social & Accent
  static const Color socialButtonBg = Color(0xFF800E13);

  // ---- Tambahan (dipakai halaman Konfirmasi, Buat Profil, dialog) ----
  static const Color white = Color(0xFFFFFFFF); // #FFFFFF
  static const Color primary = primaryMaroon; // alias
  static const Color fieldBorder = Color(0xFFC4727A); // garis kolom Buat Profil
  static const Color textGrey = Color(0xFF6B6B6B);
}
