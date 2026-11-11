import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Tampilan "kosong" untuk akun baru yang belum punya data.
class EmptyHint extends StatelessWidget {
  final IconData icon;
  final String text;

  const EmptyHint({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.fieldBorder),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.5,
                height: 1.5,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
