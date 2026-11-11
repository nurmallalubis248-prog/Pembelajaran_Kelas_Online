import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/user_account.dart';
import '../../services/app_session.dart';
import '../../services/rating_service.dart';
import '../../widgets/nexa_video_player.dart';
import '../../widgets/sparkle_star_rating.dart';
import 'nexa_tokens.dart';

const Color _kBg = Color(0xFFF9F9F9);
const Color _kStar = Color(0xFFFFC800);

/// Naik tiap ada rating baru, supaya semua bintang di halaman ikut ter-update.
final ValueNotifier<int> _ratingTick = ValueNotifier<int>(0);

/// Halaman detail kursus (frame Figma "Excel"). Muncul setelah materi berhasil diupload.
class CourseDetailPage extends StatelessWidget {
  final String title;
  final String description;
  final String? coverPath;
  final ImageProvider? coverImage; // mis. AssetImage('assets/images/excel.png')
  final int price; // 0 = gratis
  final String authorName;
  final List<String>? learnPoints;
  final String? longDescription;

  /// Jumlah bintang terisi (0-5) pada tampilan statis (kursus contoh Figma).
  final int stars;

  /// true = kursus BARU: bintang bisa diketuk untuk menilai (ada penilaian
  /// rating). false = kursus contoh Figma: bintang statis persis desain.
  final bool ratable;

  /// Path video materi. Bila ada, sampul diganti pemutar video kustom.
  final String? videoPath;

  /// ID kursus (untuk rating). Bila null dipakai judul (cara lama).
  final String? courseId;

  const CourseDetailPage({
    super.key,
    this.courseId,
    required this.title,
    required this.description,
    this.coverPath,
    this.coverImage,
    required this.price,
    this.authorName = 'Ignatius Ryan',
    this.learnPoints,
    this.longDescription,
    this.stars = 5,
    this.ratable = false,
    this.videoPath,
  });

  /// Data kursus contoh dari Figma (Belajar Excel Dari Nol).
  factory CourseDetailPage.excel({ImageProvider? coverImage}) => CourseDetailPage(
        title: 'Belajar Excel Dari Nol',
        description:
            'Mempelajari dasar Microsoft Excel, mulai dari pengolahan data hingga penggunaan rumus sederhana.',
        longDescription:
            'Kuasai dasar-dasar pengolahan data digital melalui materi Belajar Excel Dari Nol. Kursus ini dirancang khusus untuk membimbing Anda memahami penggunaan perangkat lunak Microsoft Excel secara terstruktur, mulai dari pengenalan antarmuka hingga penerapan rumus-rumus esensial yang mudah dipahami.',
        learnPoints: const ['Excel Hingga Bisa', 'Belajar Excel'],
        coverImage: coverImage,
        price: 60000,
      );

  /// Detail untuk KURSUS YANG DIKLIK. Semua data diambil dari [c], jadi
  /// kursus baru tidak lagi membuka data kursus lama / template Excel.
  factory CourseDetailPage.forCourse(Course c) {
    if (c.id == 'seed-excel-1') {
      // Kursus contoh dari Figma: teks panjangnya memakai template Excel.
      final base = CourseDetailPage.excel(
          coverImage: const AssetImage('assets/images/sampul_belajar_excel.png'));
      return CourseDetailPage(
        courseId: c.key,
        title: base.title,
        description: base.description,
        longDescription: base.longDescription,
        learnPoints: base.learnPoints,
        coverImage: base.coverImage,
        price: c.price,
        authorName: c.instructor,
        stars: c.rating.round().clamp(0, 5),
        videoPath: c.videoPath,
      );
    }
    final thumb = c.thumbnail;
    final isAsset = thumb != null && thumb.startsWith('assets/');
    return CourseDetailPage(
      courseId: c.key,
      title: c.title,
      description: c.description ?? c.title,
      coverImage: isAsset ? AssetImage(thumb) : null,
      coverPath: isAsset ? null : thumb,
      price: c.price,
      authorName: c.instructor,
      stars: c.rating.round().clamp(0, 5),
      ratable: true,
      videoPath: c.videoPath,
    );
  }

  Widget? get _poster {
    if (coverImage == null && coverPath == null) return null;
    return Image(
      image: coverImage ?? FileImage(File(coverPath!)),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const ColoredBox(color: Colors.black),
    );
  }

  String get _priceText {
    if (price <= 0) return 'Gratis';
    final s = price.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return 'Rp. $b';
  }

  @override
  Widget build(BuildContext context) {
    final points = learnPoints ?? ['Memahami $title', 'Praktik langsung lewat materi'];
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          // Header marun melengkung + panah + judul
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 14, 20, 22),
            decoration: const BoxDecoration(
              color: kMaroon,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.maybePop(context),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: nexaText(14, weight: FontWeight.w500, color: Colors.white)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                if (videoPath != null)
                  NexaVideoPlayer(
                    sources: [NexaVideoSource.file('Asli', videoPath!)],
                    poster: _poster,
                  )
                else
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: 350 / 175,
                    child: Image(
                      image: coverImage ?? FileImage(File(coverPath!)),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF3E8E5A),
                          alignment: Alignment.center,
                          child: Text(title,
                              textAlign: TextAlign.center,
                              style: nexaText(18,
                                  weight: FontWeight.w700, color: Colors.white))),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(title,
                    style: nexaText(13, weight: FontWeight.w600, color: Colors.black)),
                const SizedBox(height: 2),
                Text(description, style: nexaText(12, color: Colors.black87)),
                const SizedBox(height: 6),
                if (ratable)
                  _RatingSection(courseId: courseId ?? title, compact: true)
                else
                  _Stars(count: stars, size: 20),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(_priceText,
                      style: nexaText(15, weight: FontWeight.w600, color: Colors.black)),
                ),
                const SizedBox(height: 2),
                Text.rich(TextSpan(
                  style: nexaText(10, color: Colors.black87),
                  children: [
                    const TextSpan(text: 'Dibuat oleh '),
                    TextSpan(text: authorName, style: nexaText(10, color: kMaroon)),
                  ],
                )),
                const SizedBox(height: 28),
                _heading('Yang akan Dipelajari'),
                const SizedBox(height: 10),
                for (final p in points)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Image.asset('assets/icons/icon-park-outline_correct.png',
                            width: 22, height: 22),
                        const SizedBox(width: 8),
                        Expanded(child: Text(p, style: nexaText(12, color: Colors.black))),
                      ],
                    ),
                  ),
                const SizedBox(height: 22),
                _heading('Kursus ini Mencakup'),
                const SizedBox(height: 10),
                for (final t in const [
                  'Video Pendukung',
                  'File Materi',
                  'Akses Seumur Hidup',
                  'Sertifikat Penyelesaian'
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(t, style: nexaText(12, color: Colors.black)),
                  ),
                const SizedBox(height: 16),
                _heading('Deskripsi'),
                const SizedBox(height: 8),
                Text(longDescription ?? description, style: nexaText(12, color: Colors.black)),
                const SizedBox(height: 40),
                _heading('Masukan'),
                const SizedBox(height: 12),
                if (ratable) ...[
                  _RatingSection(courseId: courseId ?? title),
                  const SizedBox(height: 18),
                ],
                const _RatingBar(percent: .80, stars: 5),
                const SizedBox(height: 6),
                const _RatingBar(percent: .60, stars: 4),
                const SizedBox(height: 14),
                Text('Kakashi Hatake', style: nexaText(12, weight: FontWeight.w500)),
                const SizedBox(height: 4),
                const _Stars(count: 5, size: 20),
                const SizedBox(height: 6),
                Text('Kursusnya Menarik.', style: nexaText(10, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heading(String t) =>
      Text(t, style: nexaText(13, weight: FontWeight.w600, color: Colors.black));
}

class _Stars extends StatelessWidget {
  final int count; // bintang terisi dari 5
  final double size;
  const _Stars({required this.count, this.size = 16});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 5; i++)
            Icon(Icons.star_rounded, size: size, color: i < count ? _kStar : Colors.black26),
        ],
      );
}

class _RatingBar extends StatelessWidget {
  final double percent;
  final int stars;
  const _RatingBar({required this.percent, required this.stars});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black54),
            ),
            alignment: Alignment.centerLeft,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: percent),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              builder: (context, v, child) =>
                  FractionallySizedBox(widthFactor: v, child: Container(color: kMaroon)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _Stars(count: stars, size: 16),
        const SizedBox(width: 4),
        Text('${(percent * 100).round()}%', style: nexaText(10, color: Colors.black87)),
      ],
    );
  }
}

/// Rata-rata rating + bintang yang bisa diketuk (dengan kilau).
class _RatingSection extends StatefulWidget {
  final String courseId;
  final bool compact; // satu baris: bintang + rata-rata
  const _RatingSection({required this.courseId, this.compact = false});

  @override
  State<_RatingSection> createState() => _RatingSectionState();
}

class _RatingSectionState extends State<_RatingSection> {
  RatingSummary? _summary;
  bool _busy = false;

  bool _selfUpdate = false;

  @override
  void initState() {
    super.initState();
    _ratingTick.addListener(_onTick);
    _load();
  }

  @override
  void dispose() {
    _ratingTick.removeListener(_onTick);
    super.dispose();
  }

  // Rating diubah di bagian lain halaman ini -> muat ulang angkanya.
  void _onTick() {
    if (!_selfUpdate) _load();
  }

  Future<void> _load() async {
    try {
      final r = await RatingService.instance.load(widget.courseId);
      if (r.count > 0) AppSession.instance.setRating(widget.courseId, r.average);
      if (mounted) setState(() => _summary = r);
    } catch (_) {
      // gagal memuat: tampilkan kosong, pengguna tetap bisa menilai
    }
  }

  Future<void> _rate(int stars) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _summary = RatingSummary(
          average: _summary?.average ?? 0,
          count: _summary?.count ?? 0,
          mine: stars);
    });
    try {
      final r = await RatingService.instance.submit(widget.courseId, stars);
      // sambungkan ke daftar kursus (tab Kursus & Beranda)
      AppSession.instance.setRating(widget.courseId, r.average);
      if (mounted) setState(() => _summary = r);
      _selfUpdate = true;
      _ratingTick.value++;
      _selfUpdate = false;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rating gagal dikirim. Coba lagi.')));
        _load();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _summary;
    final avg = r?.average ?? 0;
    final count = r?.count ?? 0;
    if (widget.compact) {
      return Row(
        children: [
          SparkleStarRating(value: r?.mine ?? 0, onChanged: _rate, size: 22),
          const SizedBox(width: 8),
          Text(
            count == 0
                ? 'Belum ada penilai'
                : '${avg.toStringAsFixed(1)} ($count)',
            style: nexaText(11, color: Colors.black54),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(avg.toStringAsFixed(1),
                style: nexaText(28, weight: FontWeight.w700, color: Colors.black)),
            const SizedBox(width: 8),
            Text('($count penilai)', style: nexaText(11, color: Colors.black54)),
          ],
        ),
        const SizedBox(height: 10),
        Text(
            (r?.mine ?? 0) > 0 ? 'Penilaianmu (ketuk untuk mengubah)' : 'Beri penilaian',
            style: nexaText(12, weight: FontWeight.w500, color: Colors.black)),
        const SizedBox(height: 4),
        SparkleStarRating(value: r?.mine ?? 0, onChanged: _rate),
      ],
    );
  }
}
