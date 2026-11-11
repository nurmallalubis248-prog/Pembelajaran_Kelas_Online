import 'package:flutter/material.dart';
import '../constants/colors.dart';

enum SocialProvider { google, facebook }

/// Pop-up pilih akun Google / Facebook (sesuai "contoh Google login" &
/// "contoh login facebook"). Mengembalikan true bila akun dipilih.
///
/// Ini TAMPILAN SAJA. Untuk login sungguhan, ganti dengan
/// google_sign_in / flutter_facebook_auth.
Future<bool> showAccountChooser(
  BuildContext context, {
  required SocialProvider provider,
  required String accountLabel, // contoh: 'igna@gmail.com' / 'Ignatius Gaming'
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: AppColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            provider == SocialProvider.google
                ? const _GoogleWordmark()
                : const _FacebookWordmark(),
            const SizedBox(height: 4),
            Text(
              provider == SocialProvider.google
                  ? 'Masuk dengan sekali klik\nmenggunakan akun google kamu.'
                  : 'Masuk dengan sekali klik\nmenggunakan akun facebook kamu.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 9, color: AppColors.textGrey),
            ),
            const SizedBox(height: 18),
            _Row(
              icon: Icons.account_circle_outlined,
              iconColor: AppColors.primary,
              text: accountLabel,
              onTap: () => Navigator.of(ctx).pop(true),
            ),
            const SizedBox(height: 10),
            _Row(
              icon: Icons.person_add_alt_1_outlined,
              iconColor: AppColors.textDark,
              text: 'Tambahkan akun lainnya',
              onTap: () => Navigator.of(ctx).pop(false),
            ),
            const SizedBox(height: 22),
            Text('Kebijakan Privasi | Persyaratan Layanan',
                style: TextStyle(fontFamily: 'Poppins', 
                    fontSize: 8, color: AppColors.textGrey)),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

class _Row extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  final VoidCallback onTap;
  const _Row(
      {required this.icon,
      required this.iconColor,
      required this.text,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 26, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: 'Poppins', 
                      fontSize: 13, color: AppColors.textDark)),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleWordmark extends StatelessWidget {
  const _GoogleWordmark();
  @override
  Widget build(BuildContext context) {
    const colors = [
      Color(0xFF4285F4), Color(0xFFEA4335), Color(0xFFFBBC05),
      Color(0xFF4285F4), Color(0xFF34A853), Color(0xFFEA4335),
    ];
    const letters = ['G', 'o', 'o', 'g', 'l', 'e'];
    return RichText(
      text: TextSpan(
        children: [
          for (var i = 0; i < letters.length; i++)
            TextSpan(
              text: letters[i],
              style: TextStyle(fontFamily: 'Poppins', 
                  fontSize: 32, fontWeight: FontWeight.w600, color: colors[i]),
            ),
        ],
      ),
    );
  }
}

class _FacebookWordmark extends StatelessWidget {
  const _FacebookWordmark();
  @override
  Widget build(BuildContext context) => Text('Facebook',
      style: TextStyle(fontFamily: 'Poppins', 
          fontSize: 30,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1877F2)));
}
