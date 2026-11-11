import 'package:flutter/material.dart';
import '../constants/colors.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool showArrow;
  final double height;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.showArrow = false,
    this.height = 44,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              label,
              style: TextStyle(fontFamily: 'Poppins', 
                  fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.white),
            ),
            if (showArrow)
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.chevron_right_rounded,
                    size: 32, color: AppColors.white),
              ),
          ],
        ),
      ),
    );
  }
}
