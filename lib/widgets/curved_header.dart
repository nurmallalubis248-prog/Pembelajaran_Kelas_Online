import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Kepala merah dengan sudut bawah melengkung besar
/// (dipakai di Beranda & Kursus).
class CurvedHeader extends StatelessWidget {
  final double contentHeight; // tinggi di bawah status bar
  final Widget child;

  const CurvedHeader({super.key, this.contentHeight = 132, required this.child});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      height: top + contentHeight,
      padding: EdgeInsets.fromLTRB(26, top + 22, 26, 0),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(90)),
      ),
      child: child,
    );
  }
}

/// Kepala merah kecil dengan tombol kembali (Profil Saya).
class BackHeader extends StatelessWidget {
  final String title;
  const BackHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 16, 16, 22),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            child: const Icon(Icons.arrow_back, color: AppColors.white),
          ),
          const SizedBox(width: 14),
          Text(title,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white)),
        ],
      ),
    );
  }
}
