import 'package:flutter/material.dart';

const Color _maroon = Color(0xFF800F14);

class KebijakanPrivasi extends StatelessWidget {
  const KebijakanPrivasi({super.key});

  static const List<(String, String)> _isi = [
    (
      '1. Informasi Pengguna',
      'Aplikasi mengumpulkan informasi seperti nama, alamat email, dan data '
          'akun untuk mendukung proses pembelajaran.'
    ),
    (
      '2. Penggunaan Data',
      'Data pengguna digunakan untuk mengelola akun, menyimpan progres '
          'belajar, dan memberikan informasi terkait kelas online.'
    ),
    (
      '3. Keamanan Data',
      'Kami berupaya menjaga keamanan informasi pengguna agar tidak '
          'disalahgunakan oleh pihak yang tidak berwenang.'
    ),
    (
      '4. Riwayat Pembelajaran',
      'Aplikasi dapat menyimpan riwayat kelas yang diikuti dan progres '
          'belajar untuk memudahkan pengguna melanjutkan pembelajaran.'
    ),
    (
      '5. Kontak',
      'Jika memiliki pertanyaan mengenai privasi, pengguna dapat '
          'menghubungi layanan bantuan aplikasi.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: _maroon,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              bottom: 18,
              left: 12,
              right: 12,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Kebijakan Privasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                const Text('Kebijakan  Privasi',
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
