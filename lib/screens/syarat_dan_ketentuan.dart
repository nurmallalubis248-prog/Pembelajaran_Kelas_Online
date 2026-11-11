import 'package:flutter/material.dart';

import 'header_maroon.dart';

class SyaratDanKetentuan extends StatelessWidget {
  const SyaratDanKetentuan({super.key});

  static const List<(String, String)> _isi = [
    (
      '1. Penggunaan Akun',
      'Pengguna wajib memberikan informasi yang benar dan menjaga '
          'kerahasiaan akun masing-masing.'
    ),
    (
      '2. Penggunaan Materi',
      'Materi pembelajaran hanya boleh digunakan untuk keperluan belajar '
          'pribadi dan tidak boleh disebarluaskan tanpa izin.'
    ),
    (
      '3. Hak dan Kewajiban',
      'Pengguna berhak mengakses kelas sesuai ketentuan aplikasi serta '
          'wajib menggunakan layanan dengan baik.'
    ),
    (
      '4. Larangan',
      'Pengguna dilarang menyalahgunakan aplikasi, membagikan akun secara '
          'tidak sah, atau mengganggu pengguna lain.'
    ),
    (
      '5. Perubahan Ketentuan',
      'Aplikasi dapat memperbarui syarat dan ketentuan sesuai kebutuhan. '
          'Perubahan akan diinformasikan kepada pengguna.'
    ),
    (
      '6. Bantuan Pengguna',
      'Jika mengalami kendala, pengguna dapat menghubungi Customer Service '
          'melalui aplikasi.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          const HeaderMaroon(judul: 'Syarat dan Ketentuan'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                const Text('Syarat dan Ketentuan',
                    style: TextStyle(fontSize: 15)),
                const SizedBox(height: 14),
                for (final (judul, isi) in _isi) ...[
                  Text(
                    judul,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(isi, style: const TextStyle(fontSize: 15, height: 1.4)),
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
