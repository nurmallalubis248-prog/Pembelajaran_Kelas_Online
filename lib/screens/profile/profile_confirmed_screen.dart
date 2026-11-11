import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../widgets/confirmation_view.dart';

/// "Konfirmasi Sukses" - profil aktif -> tombol Masuk ke Home.
class ProfileConfirmedScreen extends StatelessWidget {
  const ProfileConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ConfirmationView(
      showBack: true,
      message: 'Profil Anda sekarang sudah aktif dan\n'
          'dapat dilihat oleh calon siswa. Anda\n'
          'bisa memperbaruinya kapan saja\n'
          'melalui menu profil',
      buttonLabel: 'Masuk',
      onPressed: () => Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
    );
  }
}
