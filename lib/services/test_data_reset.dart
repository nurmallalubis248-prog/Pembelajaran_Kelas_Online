import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../finance/finance_service.dart';
import 'app_session.dart';

/// Menghapus data UJI COBA supaya tidak tersimpan permanen:
///  * kursus baru, penjualan & saldo -> kembali ke data awal desain
///  * riwayat penarikan dana -> kosong lagi (kembali ke data awal)
///  * rating, video materi & file upload yang tersimpan di perangkat
/// Akun (email & sandi) dan profil TIDAK dihapus.
class TestDataReset {
  TestDataReset._();

  /// Dipanggil saat Log Out.
  static Future<void> reset() async {
    AppSession.instance.resetTestData();
    FinanceService.instance.resetAll();
    await clearPersisted();
  }

  /// Hapus data uji coba yang tersimpan di perangkat. Aman dipanggil
  /// berulang kali; kegagalan diabaikan.
  static Future<void> clearPersisted() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.remove('kursus_v1');
      await p.remove('course_ratings_v1');
    } catch (_) {}
    try {
      final docs = await getApplicationDocumentsDirectory();
      for (final name in const ['nexa_videos', 'kursus']) {
        final d = Directory('${docs.path}${Platform.pathSeparator}$name');
        if (await d.exists()) await d.delete(recursive: true);
      }
    } catch (_) {}
    try {
      final t = Directory(
          '${Directory.systemTemp.path}${Platform.pathSeparator}nexa_courses');
      if (await t.exists()) await t.delete(recursive: true);
    } catch (_) {}
  }
}
