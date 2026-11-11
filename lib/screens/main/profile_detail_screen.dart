import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/user_account.dart';
import '../../routes/app_routes.dart';
import '../../services/app_session.dart';
import '../../widgets/curved_header.dart';
import '../../widgets/primary_button.dart';

/// "Profil Saya": menampilkan data diri akun yang sedang masuk.
/// Akun baru yang belum mengisi profil -> kolom kosong + tombol Lengkapi Profil.
class ProfileDetailScreen extends StatelessWidget {
  const ProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSession.instance,
      builder: (context, _) {
        final user = AppSession.instance.userOrGuest;
        return Scaffold(
          backgroundColor: AppColors.white,
          body: Column(
            children: [
              const BackHeader(title: 'Profil Saya'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Column(
                          children: [
                            Icon(Icons.account_circle_outlined,
                                size: 76, color: AppColors.primary),
                            SizedBox(height: 10),
                            Text('Instruktur',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _Info(label: 'Nama Lengkap', value: user.name),
                      _Info(label: 'Tentang Saya', value: user.about),
                      _Info(label: 'Pendidikan Terakhir', value: user.education),
                      _Info(label: 'Pengalaman Bekerja', value: user.experience),
                      const SizedBox(height: 14),
                      _EditButton(user: user),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EditButton extends StatelessWidget {
  final UserAccount user;
  const _EditButton({required this.user});

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: user.isProfileComplete ? 'Ubah Profil' : 'Lengkapi Profil',
      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.createProfile),
    );
  }
}

class _Info extends StatelessWidget {
  final String label;
  final String value;
  const _Info({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final empty = value.trim().isEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(label,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black)),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.fieldBorder, width: 1),
            ),
            child: Text(
              empty ? 'Belum diisi' : value,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                height: 1.45,
                color: empty ? const Color(0xFF9E9E9E) : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
