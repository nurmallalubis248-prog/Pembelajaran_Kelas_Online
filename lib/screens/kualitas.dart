import 'package:flutter/material.dart';

import '../data/upload_prefs.dart';
import 'header_maroon.dart';

/// Halaman "Kualitas Upload Video".
///
/// Cara pakai di menu Akun:
///   Kualitas.show(context);                       // muncul sebagai frame (bottom sheet)
///   atau Navigator.push(context, MaterialPageRoute(builder: (_) => const Kualitas()));
class Kualitas extends StatelessWidget {
  const Kualitas({super.key});

  /// Menampilkan frame toggle dari bawah layar. Mengembalikan pilihan terakhir.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kualitas Upload Video',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 10),
              KualitasPanel(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          const HeaderMaroon(judul: 'Kualitas Upload Video'),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const KualitasPanel(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Isi frame: deskripsi + 4 toggle. Hanya satu toggle yang bisa aktif.
class KualitasPanel extends StatefulWidget {
  const KualitasPanel({super.key, this.onChanged});
  final ValueChanged<KualitasVideo>? onChanged;

  @override
  State<KualitasPanel> createState() => _KualitasPanelState();
}

class _KualitasPanelState extends State<KualitasPanel> {
  KualitasVideo _dipilih = UploadPrefs.bawaan;

  @override
  void initState() {
    super.initState();
    UploadPrefs.muat().then((v) {
      if (mounted) setState(() => _dipilih = v);
    });
  }

  Future<void> _pilih(KualitasVideo k) async {
    setState(() => _dipilih = k);
    await UploadPrefs.simpan(k);
    widget.onChanged?.call(k);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Pilih kualitas video untuk anda unduh. Semakin tinggi kualitas, '
          'semakin banyak penyimpanan terpakai',
          style: TextStyle(fontSize: 13, color: Color(0xFF444444), height: 1.4),
        ),
        const SizedBox(height: 14),
        for (final k in KualitasVideo.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        k.label,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        k.resolusi,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF555555)),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _dipilih == k,
                  // Menekan toggle yang sedang aktif diabaikan (harus ada 1 pilihan).
                  onChanged: (on) {
                    if (on) _pilih(k);
                  },
                  activeThumbColor: Colors.white,
                  activeTrackColor: kMaroon,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: const Color(0xFF5A5A5A),
                  trackOutlineColor:
                      WidgetStateProperty.all(Colors.transparent),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
