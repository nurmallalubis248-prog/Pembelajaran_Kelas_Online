import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../state/app_session.dart';
import '../additional_frames.dart';
import '../auth_screen.dart';
import '../profile/create_profile_screen.dart';
import 'main_widgets.dart';

/// Tab "Profil" (layar Akun di desain).
class AccountTab extends StatelessWidget {
  const AccountTab({super.key});

  void _openProfile(BuildContext context) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const ProfileDetailScreen()));

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Keluar akun?', style: poppins(16, w: FontWeight.w600)),
        content: Text('Kamu akan kembali ke halaman masuk.', style: poppins(13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Batal', style: poppins(13, color: Colors.black54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Keluar', style: poppins(13, w: FontWeight.w600, color: AppColors.primary)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    AppSession.instance.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen(initialIsSignUp: false)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSession.instance,
      builder: (context, _) {
        final s = AppSession.instance;
        final complete = s.hasProfile;
        return Container(
          color: const Color(0xFFF8F7F7),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).padding.top + 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeSlideIn(
                        child: SizedBox(
                          width: double.infinity,
                          child: InkWell(
                            onTap: () => _openProfile(context),
                            child: Column(
                              children: [
                                const Icon(Icons.account_circle_outlined,
                                    size: 76, color: AppColors.primary),
                                const SizedBox(height: 8),
                                Text(s.profile?.name ?? 'Nama belum diisi',
                                    style: poppins(15,
                                        w: FontWeight.w600,
                                        color: complete ? Colors.black : Colors.black45)),
                                const SizedBox(height: 8),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.black38),
                                  ),
                                  child: Text(
                                    complete ? 'Profil Lengkap' : 'Profil Belum Lengkap',
                                    style: poppins(12, color: Colors.black54),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text('Instruktur',
                                    style: poppins(17, w: FontWeight.w600, color: AppColors.primary)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      FadeSlideIn(
                        delayMs: 100,
                        child: _NavRow(
                          title: 'Kualitas Upload video',
                          subtitle: '720p',
                          onTap: () => nexaPush(context, const NexaQualityScreen()),
                        ),
                      ),
                      FadeSlideIn(
                        delayMs: 160,
                        child: _SwitchRow(
                          title: 'Upload Melalui Wi-Fi saja',
                          value: s.wifiOnly,
                          onChanged: s.setWifiOnly,
                        ),
                      ),
                      FadeSlideIn(
                        delayMs: 220,
                        child: _SwitchRow(
                          title: 'Notifikasi',
                          value: s.notifications,
                          onChanged: s.setNotifications,
                        ),
                      ),
                      FadeSlideIn(
                        delayMs: 280,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('versi Aplikasi', style: poppins(15, w: FontWeight.w500)),
                              Text('0.0.1', style: poppins(11, color: Colors.black54)),
                            ],
                          ),
                        ),
                      ),
                      FadeSlideIn(
                        delayMs: 340,
                        child: _NavRow(
                          title: 'Kebijakan Privasi',
                          onTap: () => nexaPush(context, const NexaPrivacyScreen()),
                        ),
                      ),
                      FadeSlideIn(
                        delayMs: 400,
                        child: _NavRow(
                          title: 'Syarat dan Ketentuan',
                          onTap: () => nexaPush(context, const NexaTermsScreen()),
                        ),
                      ),
                      FadeSlideIn(
                        delayMs: 460,
                        child: _NavRow(
                          title: 'Costumer Service',
                          onTap: () => nexaPush(context, const NexaSupportScreen()),
                        ),
                      ),
                      const SizedBox(height: 26),
                      FadeSlideIn(
                        delayMs: 520,
                        child: InkWell(
                          onTap: () => _logout(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.logout, color: AppColors.primary, size: 22),
                                const SizedBox(width: 10),
                                Text('Log Out',
                                    style: poppins(15, w: FontWeight.w500, color: AppColors.primary)),
                              ],
                            ),
                          ),
                        ),
                      ),
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

class _NavRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  const _NavRow({required this.title, this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: poppins(15, w: FontWeight.w500)),
                    if (subtitle != null)
                      Text(subtitle!, style: poppins(11, color: Colors.black54)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, color: AppColors.primary, size: 24),
            ],
          ),
        ),
      );
}

class _SwitchRow extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchRow({required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(child: Text(title, style: poppins(15, w: FontWeight.w500))),
            Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: AppColors.primary,
              activeThumbColor: Colors.white,
              inactiveTrackColor: Colors.black54,
              inactiveThumbColor: Colors.white,
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            ),
          ],
        ),
      );
}

/// Layar "Profil Saya" (data diri). Kosong untuk akun baru.
class ProfileDetailScreen extends StatelessWidget {
  const ProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListenableBuilder(
        listenable: AppSession.instance,
        builder: (context, _) {
          final p = AppSession.instance.profile;
          return Column(
            children: [
              Container(
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
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Text('Profil Saya',
                        style: poppins(17, w: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Icon(Icons.account_circle_outlined,
                            size: 76, color: AppColors.primary),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 18),
                          child: Text('Instruktur',
                              style: poppins(16, w: FontWeight.w600, color: AppColors.primary)),
                        ),
                      ),
                      _Field(label: 'Nama Lengkap', value: p?.name),
                      _Field(label: 'Tentang Saya', value: p?.about),
                      _Field(label: 'Pendidikan Terakhir', value: p?.education),
                      _Field(label: 'Pengalaman Bekerja', value: p?.experience),
                      if (p == null) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const CreateProfileScreen()),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text('Lengkapi Profil',
                                style: poppins(15, w: FontWeight.w600, color: Colors.white)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String? value;
  const _Field({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final empty = value == null || value!.isEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: poppins(15, w: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.fieldBorder),
            ),
            child: Text(
              empty ? 'Belum diisi' : value!,
              style: poppins(13, color: empty ? Colors.black38 : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
