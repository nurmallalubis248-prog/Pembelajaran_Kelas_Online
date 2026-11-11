import 'package:flutter/material.dart';
import '../screens/main/main_shell.dart';
import 'pendapatan_page.dart';
import 'riwayat_page.dart';
import 'tarik_dana_page.dart';

/// Pintu masuk ke halaman keuangan. Pakai ini untuk mengganti semua
/// tombol yang masih menampilkan "akan segera tersedia".
///
///   Histori      -> FinanceNav.openRiwayat(context)
///   Lihat Semua  -> FinanceNav.openPendapatan(context)
///   Tarik Dana   -> FinanceNav.openTarikDana(context)
class FinanceNav {
  FinanceNav._();

  /// Navbar bawah tampil di halaman History & Pendapatan sesuai desain Figma.
  /// [onNavTap] opsional: isi kalau mau pindah ke tab tertentu di halaman utama
  /// (0 Beranda, 1 Kursus, 2 Keuangan, 3 Profil). Kalau kosong, tap tab
  /// akan kembali ke halaman utama.
  static void _defaultNavTap(BuildContext context, int index) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => MainShell(initialIndex: index)),
      (route) => false,
    );
  }

  static Future<void> openRiwayat(BuildContext context,
      {ValueChanged<int>? onNavTap}) {
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RiwayatPage(
        showBottomNav: true,
        onNavTap: onNavTap ?? (i) => _defaultNavTap(context, i),
      ),
    ));
  }

  static Future<void> openPendapatan(BuildContext context,
      {ValueChanged<int>? onNavTap}) {
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PendapatanPage(
        showBottomNav: true,
        onNavTap: onNavTap ?? (i) => _defaultNavTap(context, i),
      ),
    ));
  }

  static Future<void> openTarikDana(BuildContext context) {
    return Navigator.of(context).push(MaterialPageRoute(
      settings: const RouteSettings(name: TarikDanaPage.routeName),
      builder: (_) => const TarikDanaPage(),
    ));
  }
}
