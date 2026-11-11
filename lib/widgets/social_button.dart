import 'package:flutter/material.dart';
import '../constants/assets.dart';

enum SocialType { google, facebook }

class SocialIconButton extends StatelessWidget {
  final SocialType type;
  final VoidCallback? onTap;

  const SocialIconButton({super.key, required this.type, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isGoogle = type == SocialType.google;
    final asset = isGoogle ? AppAssets.googleIcon : AppAssets.facebookIcon;

    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        asset,
        width: 44,
        height: 44,
        fit: BoxFit.contain,
        errorBuilder: (_, e, s) {
          debugPrint('Gagal memuat $asset: $e');
          return CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF800E13),
            child: Text(isGoogle ? 'G' : 'f',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          );
        },
      ),
    );
  }
}