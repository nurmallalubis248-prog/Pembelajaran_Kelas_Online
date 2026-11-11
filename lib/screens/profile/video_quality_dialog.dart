import 'package:flutter/material.dart';
import '../../data/upload_prefs.dart';
import 'nexa_tokens.dart';

/// Frame toggle "Kualitas" (popup). Pilihan disimpan lewat UploadPrefs.
/// Panggil dari item "Kualitas Upload video" di tab Profil.
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
  KualitasVideo _selected = UploadPrefs.bawaan;

  @override
  void initState() {
    super.initState();
    UploadPrefs.muat().then((k) {
      if (mounted) setState(() => _selected = k);
    });
  }

  Future<void> _select(KualitasVideo k) async {
    setState(() => _selected = k);
    await UploadPrefs.simpan(k);
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
              for (final k in KualitasVideo.values)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(k.label, style: nexaText(13, weight: FontWeight.w600)),
                            Text(k.resolusi, style: nexaText(11, color: Colors.black45)),
                          ],
                        ),
                      ),
                      Switch(
                        value: _selected == k,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        thumbColor: const WidgetStatePropertyAll(Colors.white),
                        trackColor: WidgetStateProperty.resolveWith(
                          (s) => s.contains(WidgetState.selected)
                              ? kMaroon
                              : const Color(0xFF4B4B4B),
                        ),
                        trackOutlineColor:
                            const WidgetStatePropertyAll(Colors.transparent),
                        // hanya satu kualitas yang boleh aktif
                        onChanged: (on) {
                          if (on) _select(k);
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
