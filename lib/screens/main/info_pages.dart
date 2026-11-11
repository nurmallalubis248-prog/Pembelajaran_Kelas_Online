import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'nexa_tokens.dart';

PreferredSizeWidget _nexaAppBar(String title) => AppBar(
      backgroundColor: kMaroon,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      title: Text(title, style: nexaText(14, weight: FontWeight.w600, color: Colors.white)),
    );

/// Item list yang muncul bertahap (fade + slide).
class _Reveal extends StatelessWidget {
  final int index;
  final Widget child;
  const _Reveal({required this.index, required this.child});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + index * 90),
      curve: Curves.easeOut,
      builder: (_, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 16 * (1 - v)), child: c),
      ),
      child: child,
    );
  }
}

class _TextSection {
  final String title, body;
  const _TextSection(this.title, this.body);
}

class _InfoScaffold extends StatelessWidget {
  final String title, intro;
  final List<_TextSection> sections;
  const _InfoScaffold({required this.title, required this.intro, required this.sections});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _nexaAppBar(title),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Reveal(index: 0, child: Text(intro, style: nexaText(11, color: Colors.black54))),
          const SizedBox(height: 14),
          for (var i = 0; i < sections.length; i++)
            _Reveal(
              index: i + 1,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${i + 1}. ${sections[i].title}',
                        style: nexaText(12, weight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(sections[i].body, style: nexaText(11, color: Colors.black87)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// GANTI isi teks di bawah dengan teks persis dari frame Figma.
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});
  @override
  Widget build(BuildContext context) => const _InfoScaffold(
        title: 'Kebijakan Privasi',
        intro: 'Kebijakan Privasi',
        sections: [
          _TextSection('Informasi Pengguna',
              'Aplikasi mengumpulkan informasi seperti nama, alamat email, dan data akun untuk mendukung proses pembelajaran.'),
          _TextSection('Penggunaan Data',
              'Data pengguna digunakan untuk memberikan layanan, mengelola progres belajar, dan meningkatkan kualitas pembelajaran.'),
          _TextSection('Keamanan Data',
              'Kami berupaya menjaga keamanan data pengguna dan tidak membagikannya kepada pihak ketiga tanpa izin.'),
          _TextSection('Kontak',
              'Jika ada pertanyaan mengenai privasi, pengguna dapat menghubungi layanan customer service aplikasi.'),
        ],
      );
}

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});
  @override
  Widget build(BuildContext context) => const _InfoScaffold(
        title: 'Syarat dan Ketentuan',
        intro: 'Syarat dan Ketentuan',
        sections: [
          _TextSection('Pengguna dan Akun',
              'Pengguna wajib memberikan informasi yang benar dan menjaga kerahasiaan akun masing-masing.'),
          _TextSection('Penggunaan Materi',
              'Materi pembelajaran hanya boleh digunakan untuk keperluan belajar dan tidak boleh disebarluaskan tanpa izin.'),
          _TextSection('Hak dan Kewajiban',
              'Pengguna berhak mengakses materi sesuai paket yang dipilih dan wajib mematuhi aturan aplikasi.'),
          _TextSection('Larangan',
              'Pengguna dilarang menyalahgunakan aplikasi, membagikan akun, atau mengunggah konten yang melanggar aturan.'),
          _TextSection('Perubahan Ketentuan',
              'Aplikasi dapat memperbarui syarat dan ketentuan sewaktu-waktu dan pengguna akan diberi tahu.'),
          _TextSection('Batasan Tanggung Jawab',
              'Aplikasi tidak bertanggung jawab atas kerugian akibat penyalahgunaan akun oleh pengguna.'),
        ],
      );
}

class CustomerServicePage extends StatelessWidget {
  const CustomerServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _nexaAppBar('Customer Servis'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Reveal(index: 0, child: Text('Bantuan', style: nexaText(14, weight: FontWeight.w700, color: kMaroon))),
          const SizedBox(height: 12),
          // GANTI nomor dan email dengan data dari Figma.
          _Reveal(index: 1, child: _ContactCard(label: 'Call Center', value: '0123456789')),
          const SizedBox(height: 10),
          _Reveal(index: 2, child: _ContactCard(label: 'Email', value: 'nexa@gmail.com')),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final String label, value;
  const _ContactCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: kMaroon, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: nexaText(12, weight: FontWeight.w600, color: Colors.white)),
                Text(value, style: nexaText(10, color: Colors.white70)),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(6),
            // Tanpa paket tambahan: salin ke clipboard.
            // Kalau mau langsung buka telepon/email, pakai url_launcher (tel:/mailto:).
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: value));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$label disalin', style: nexaText(12, color: Colors.white))),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('Hubungi', style: nexaText(10, weight: FontWeight.w600, color: kMaroon)),
            ),
          ),
        ],
      ),
    );
  }
}
