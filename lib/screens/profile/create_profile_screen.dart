import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../constants/colors.dart';
import '../../services/app_session.dart';
import '../../widgets/app_alert_dialog.dart';
import '../../widgets/nexa_keyboard.dart';
import '../../widgets/primary_button.dart';

/// "Buat Profil Pengajar". Semua field wajib diisi; jika ada yang kosong
/// tampil dialog "Harap Isi Keterangan Terlebih Dahulu!" (bukan "Gagal Ke
/// Akun!", itu khusus Login).
class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _name = TextEditingController();
  final _about = TextEditingController();
  final _education = TextEditingController();
  final _experience = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Akun baru -> semua kosong. Akun yang sudah punya profil -> terisi
    // (dipakai saat "Ubah Profil").
    final u = AppSession.instance.user;
    if (u != null) {
      _name.text = u.name;
      _about.text = u.about;
      _education.text = u.education;
      _experience.text = u.experience;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _about.dispose();
    _education.dispose();
    _experience.dispose();
    super.dispose();
  }

  void _save() {
    final empty = [_name, _about, _education, _experience]
        .any((c) => c.text.trim().isEmpty);
    if (empty) {
      showFillWarningDialog(
        context,
        text: 'Harap Isi Keterangan Terlebih Dahulu!',
      );
      return;
    }
    AppSession.instance.saveProfile(
      name: _name.text,
      about: _about.text,
      education: _education.text,
      experience: _experience.text,
    );
    // CATATAN: simpan juga ke backend/Firebase di sini.
    Navigator.of(context).pushReplacementNamed(AppRoutes.profileConfirmed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          _Header(onBack: () => Navigator.of(context).maybePop()),
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
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
                          _RoleLabel(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _Label('Nama Lengkap'),
                    _Field(controller: _name),
                    const SizedBox(height: 14),
                    const _Label('Tentang Saya'),
                    _Field(controller: _about, minLines: 4, maxLines: 6),
                    const SizedBox(height: 14),
                    const _Label('Pendidikan Terakhir'),
                    _Field(controller: _education, minLines: 2, maxLines: 4),
                    const SizedBox(height: 14),
                    const _Label('Pengalaman Bekerja'),
                    _Field(controller: _experience),
                    const SizedBox(height: 32),
                    PrimaryButton(
                        label: 'Simpan dan Lanjutkan', onPressed: _save),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;
  const _Header({required this.onBack});

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
            onTap: onBack,
            child: const Icon(Icons.arrow_back, color: AppColors.white),
          ),
          const SizedBox(width: 14),
          Text('Buat Profil Pengajar',
              style: TextStyle(fontFamily: 'Poppins', 
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white)),
        ],
      ),
    );
  }
}

class _RoleLabel extends StatelessWidget {
  const _RoleLabel();
  @override
  Widget build(BuildContext context) => Text('Instruktur',
      style: TextStyle(fontFamily: 'Poppins', 
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primary));
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: TextStyle(fontFamily: 'Poppins', 
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black)),
      );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final int minLines;
  final int maxLines;
  const _Field(
      {required this.controller, this.minLines = 1, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c, double w) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c, width: w),
        );
    return NexaKeyboardField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.black),
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        enabledBorder: border(AppColors.fieldBorder, 1),
        border: border(AppColors.fieldBorder, 1),
        focusedBorder: border(AppColors.primary, 1.4),
      ),
    );
  }
}
