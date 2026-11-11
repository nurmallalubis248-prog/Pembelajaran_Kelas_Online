import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'primary_button.dart';

/// Layout "Konfirmasi Sukses" yang dipakai di 2 halaman
/// (akun berhasil dibuat & profil berhasil disimpan).
class ConfirmationView extends StatelessWidget {
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;
  final bool showBack;

  const ConfirmationView({
    super.key,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 48,
                child: showBack
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: AppColors.textGrey),
                        onPressed: () => Navigator.of(context).maybePop(),
                      )
                    : null,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 118,
                      height: 118,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 7),
                      ),
                      child: const Icon(Icons.check_rounded,
                          size: 70, color: AppColors.primary),
                    ),
                    const SizedBox(height: 22),
                    Text('Konfirmasi Sukses',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Poppins', 
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                    const SizedBox(height: 18),
                    Text(message,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Poppins', 
                            fontSize: 14, height: 1.5, color: AppColors.textGrey)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(35, 0, 35, 28),
              child: PrimaryButton(
                label: buttonLabel,
                showArrow: true,
                height: 48,
                onPressed: onPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
