import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'nexa_tokens.dart';

const _prefKey = 'video_upload_quality';

// (key, judul, keterangan) -> SESUAIKAN teks dengan frame Figma "Kualitas".
const _options = <(String, String, String)>[
  ('hemat', 'Hemat Data', '240p'),
  ('baik', 'Baik', '480p'),
  ('lebih_baik', 'Lebih Baik', '720p'),
  ('terbaik', 'Terbaik', '1080p'),
];

Future<String> loadVideoQuality() async {
  final p = await SharedPreferences.getInstance();
  return p.getString(_prefKey) ?? 'terbaik';
}

/// Panggil dari item "Kualitas Upload Video" di halaman Akun.
Future<void> showVideoQualityDialog(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Tutup',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (ctx, anim1, anim2) => const _VideoQualityCard(),
    transitionBuilder: (ctx, anim, anim2, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
      return FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _VideoQualityCard extends StatefulWidget {
  const _VideoQualityCard();
  @override
  State<_VideoQualityCard> createState() => _VideoQualityCardState();
}

class _VideoQualityCardState extends State<_VideoQualityCard> {
  String _selected = 'terbaik';

  @override
  void initState() {
    super.initState();
    loadVideoQuality().then((v) {
      if (mounted) setState(() => _selected = v);
    });
  }

  Future<void> _select(String key) async {
    setState(() => _selected = key);
    final p = await SharedPreferences.getInstance();
    await p.setString(_prefKey, key);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih kualitas video untuk setiap upload. Semakin tinggi '
                'kualitas, semakin besar penyimpanan dan waktu upload.',
                style: nexaText(11, color: Colors.black54),
              ),
              const SizedBox(height: 14),
              for (final o in _options)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.$2, style: nexaText(13, weight: FontWeight.w600)),
                            Text(o.$3, style: nexaText(11, color: Colors.black45)),
                          ],
                        ),
                      ),
                      Switch(
                        value: _selected == o.$1,
                        activeTrackColor: kMaroon,
                        activeThumbColor: Colors.white,
                        // hanya satu kualitas yang boleh aktif
                        onChanged: (on) {
                          if (on) _select(o.$1);
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
