import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../widgets/confirmation_view.dart';

/// "Konfirmasi Sukses" - akun berhasil dibuat -> lanjut Buat Profil.
class AccountConfirmedScreen extends StatelessWidget {
  const AccountConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ConfirmationView(
      message: 'Akun Anda Sekarang Telah Berhasil\ndibuat.',
      buttonLabel: 'Buat Profil',
      onPressed: () =>
          Navigator.of(context).pushReplacementNamed(AppRoutes.createProfile),
    );
  }
}
