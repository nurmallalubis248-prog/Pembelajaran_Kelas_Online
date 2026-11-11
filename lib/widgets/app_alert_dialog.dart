import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Dialog tanpa tombol: menutup sendiri setelah [duration], atau saat area
/// di luar kartu disentuh (sesuai desain Figma, tidak ada tombol).
class _AutoCloseDialog extends StatefulWidget {
  final Widget child;
  final Duration duration;
  const _AutoCloseDialog({required this.child, required this.duration});

  @override
  State<_AutoCloseDialog> createState() => _AutoCloseDialogState();
}

class _AutoCloseDialogState extends State<_AutoCloseDialog> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, () {
      // Hanya tutup bila dialog ini masih yang paling atas.
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Dialog kecil "Harap Isi ... Terlebih Dahulu!"
/// (ikon segitiga garis, judul maroon). Dipakai di Buat Profil
/// ("Keterangan") dan Buat Kursus ("Materi").
Future<void> showFillWarningDialog(
  BuildContext context, {
  required String text, // contoh: 'Harap Isi Keterangan Terlebih Dahulu!'
  Duration duration = const Duration(seconds: 2),
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => _AutoCloseDialog(
      duration: duration,
      child: Dialog(
        backgroundColor: AppColors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 70),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_outlined,
                  size: 52, color: AppColors.primary),
              const SizedBox(height: 10),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Dialog "Gagal Ke Akun!" khusus halaman Login
/// (ikon segitiga terisi, judul & teks hitam).
Future<void> showLoginFailedDialog(
  BuildContext context, {
  Duration duration = const Duration(seconds: 2),
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => _AutoCloseDialog(
      duration: duration,
      child: Dialog(
        backgroundColor: AppColors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 34),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_rounded,
                  size: 60, color: AppColors.primary),
              const SizedBox(height: 16),
              const Text(
                'Gagal Ke Akun!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Silahkan isi data diri kamu\nterlebih dulu',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  height: 1.5,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
