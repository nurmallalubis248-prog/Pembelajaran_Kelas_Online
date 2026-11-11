import 'package:flutter/material.dart';
import '../../state/app_session.dart';
import 'create_profile_screen.dart';

const Color _maroon = Color(0xFF800F14);

/// Profil Saya: isi data mengikuti akun yang login (AppSession).
/// Akun Ignasius -> terisi. Akun baru -> "Belum diisi" + tombol Lengkapi Profil.
class ProfilSaya extends StatelessWidget {
  const ProfilSaya({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSession.instance,
      builder: (context, _) {
        final p = AppSession.instance.profile;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: _maroon,
            foregroundColor: Colors.white,
            title: const Text(
              'Profil Saya',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _maroon, width: 3),
                          color: const Color(0xFFF1D8D9),
                        ),
                        child: const Icon(Icons.person, size: 54, color: _maroon),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Instruktur',
                        style: TextStyle(
                          color: _maroon,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _SectionItem(label: 'Nama Lengkap', value: p?.name),
                _SectionItem(label: 'Tentang Saya', value: p?.about),
                _SectionItem(label: 'Pendidikan Terakhir', value: p?.education),
                _SectionItem(label: 'Pengalaman Bekerja', value: p?.experience),
                if (p == null) ...[
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CreateProfileScreen()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _maroon,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Lengkapi Profil',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionItem extends StatelessWidget {
  const _SectionItem({required this.label, required this.value});
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final empty = value == null || value!.isEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Text(
              empty ? 'Belum diisi' : value!,
              style: TextStyle(
                fontSize: 14,
                color: empty ? Colors.black38 : Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}