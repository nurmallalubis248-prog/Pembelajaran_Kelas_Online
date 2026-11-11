import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'header_maroon.dart';

class CustomerServis extends StatelessWidget {
  const CustomerServis({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          const HeaderMaroon(judul: 'Customer Servis'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
              children: const [
                Text(
                  'Bantuan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 14),
                _KartuKontak(judul: 'Call Center', isi: '0123456789'),
                SizedBox(height: 14),
                _KartuKontak(judul: 'Email', isi: 'Nexa@gmail.com'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KartuKontak extends StatelessWidget {
  const _KartuKontak({required this.judul, required this.isi});
  final String judul;
  final String isi;

  Future<void> _hubungi(BuildContext context) async {
    // Tanpa paket tambahan: salin ke clipboard.
    // Untuk membuka telepon/email langsung, pakai paket url_launcher.
    await Clipboard.setData(ClipboardData(text: isi));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$judul disalin: $isi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kMaroon,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _hubungi(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      judul,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isi,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Text(
                'HUBUNGI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
