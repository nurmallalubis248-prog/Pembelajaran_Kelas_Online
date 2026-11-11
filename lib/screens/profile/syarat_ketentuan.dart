import 'package:flutter/material.dart';

const Color _maroon = Color(0xFF800F14);

class SyaratKetentuan extends StatelessWidget {
  const SyaratKetentuan({super.key});

  static const List<(String, String)> _isi = [
    (
      '1. Ketentuan Umum',
      'Dengan mengakses dan menggunakan aplikasi ini, Anda menyetujui untuk '
          'terikat oleh seluruh syarat dan ketentuan yang berlaku.'
    ),
    (
      '2. Akun Pengguna',
      'Pengguna bertanggung jawab untuk menjaga kerahasiaan kata sandi '
          'dan seluruh aktivitas yang terjadi di dalam akun mereka.'
    ),
    (
      '3. Hak Cipta & Materi',
      'Seluruh materi pembelajaran, video, dan modul di dalam aplikasi ini '
          'dilindungi oleh hak cipta dan tidak boleh disebarluaskan tanpa izin.'
    ),
    (
      '4. Pembayaran & Pembatalan',
      'Transaksi kelas yang telah berhasil diproses tidak dapat dibatalkan '
          'kecuali terdapat kendala teknis dari pihak penyedia layanan.'
    ),
    (
      '5. Perubahan Ketentuan',
      'Pihak pengembang berhak mengubah syarat dan ketentuan ini sewaktu-waktu '
          'tanpa pemberitahuan sebelumnya.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: _maroon,
        foregroundColor: Colors.white,
        title: const Text(
          'Syarat dan Ketentuan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          const Text(
            'Syarat & Ketentuan Layanan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          for (final (judul, isi) in _isi) ...[
            Text(
              judul,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _maroon,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isi,
              style: const TextStyle(fontSize: 14, height: 1.45),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
