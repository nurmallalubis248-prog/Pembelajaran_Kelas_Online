import '../../services/test_data_reset.dart';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../data/upload_prefs.dart';
import '../../services/app_session.dart';
import '../auth_screen.dart';
import '../profile/info_pages.dart';
import '../profile/video_quality_dialog.dart';
import 'profile_detail_screen.dart';

/// Tab Profil (menu Akun). Nama & status profil mengikuti akun yang masuk.
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  KualitasVideo _quality = UploadPrefs.bawaan;
  bool _wifiOnly = false;
  bool _notifications = false;

  @override
  void initState() {
    super.initState();
    UploadPrefs.muat().then((k) {
      if (mounted) setState(() => _quality = k);
    });
  }

  Future<void> _pickQuality() async {
    await showVideoQualityDialog(context);
    final k = await UploadPrefs.muat();
    if (mounted) setState(() => _quality = k);
  }

  void _open(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  void _logout() {
    // Data uji coba (kursus baru, penarikan, rating, video) dihapus saat Log Out.
    TestDataReset.reset();
    AppSession.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const AuthScreen(initialIsSignUp: false),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSession.instance,
      builder: (context, _) {
        final user = AppSession.instance.userOrGuest;
        final complete = user.isProfileComplete;
        final top = MediaQuery.of(context).padding.top;

        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          body: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // Strip merah di atas (area status bar)
                Container(
                  width: double.infinity,
                  height: top + 14,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                ),
                const SizedBox(height: 22),
                // Avatar + nama + status -> buka "Profil Saya"
                InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const ProfileDetailScreen())),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 4),
                    child: Column(
                      children: [
                        const Icon(Icons.account_circle_outlined,
                            size: 78, color: AppColors.primary),
                        const SizedBox(height: 6),
                        Text(
                          user.displayName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: user.name.trim().isEmpty
                                ? AppColors.textGrey
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 1),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: complete
                                  ? const Color(0xFF8A8A8A)
                                  : AppColors.primary,
                            ),
                          ),
                          child: Text(
                            complete ? 'Profil Lengkap' : 'Profil Belum Lengkap',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: complete
                                  ? const Color(0xFF8A8A8A)
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text('Instruktur',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                _Tile(
                  title: 'Kualitas Upload video',
                  subtitle: _quality.resolusi,
                  trailing: const _Arrow(),
                  onTap: _pickQuality,
                ),
                _Tile(
                  title: 'Upload Melalui Wi-Fi saja',
                  trailing: _NexaSwitch(
                    value: _wifiOnly,
                    onChanged: (v) => setState(() => _wifiOnly = v),
                  ),
                ),
                _Tile(
                  title: 'Notifikasi',
                  trailing: _NexaSwitch(
                    value: _notifications,
                    onChanged: (v) => setState(() => _notifications = v),
                  ),
                ),
                const _Tile(title: 'versi Aplikasi', subtitle: '0.0.1'),
                _Tile(
                  title: 'Kebijakan Privasi',
                  trailing: const _Arrow(),
                  onTap: () => _open(const PrivacyPolicyPage()),
                ),
                _Tile(
                  title: 'Syarat dan Ketentuan',
                  trailing: const _Arrow(),
                  onTap: () => _open(const TermsPage()),
                ),
                _Tile(
                  title: 'Customer Service',
                  trailing: const _Arrow(),
                  onTap: () => _open(const CustomerServicePage()),
                ),
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: _logout,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.logout, size: 24, color: Colors.black),
                          SizedBox(width: 8),
                          Text('Log Out',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _Tile({required this.title, this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Colors.black)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: Color(0xFF6B6B6B))),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow();
  @override
  Widget build(BuildContext context) =>
      const Icon(Icons.arrow_forward, size: 22, color: AppColors.primary);
}

class _NexaSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _NexaSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      thumbColor: const WidgetStatePropertyAll(Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primary
            : const Color(0xFF4B4B4B),
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    );
  }
}
