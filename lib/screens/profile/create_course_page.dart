import 'dart:io';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/user_account.dart';
import '../../services/app_session.dart';
import 'course_detail_page.dart';
import '../../widgets/nexa_keyboard.dart';
import '../../widgets/please_wait_text.dart';
import '../../widgets/tap_scale.dart';
import 'nexa_tokens.dart';

// ---------------------------------------------------------------------------
// SERVICE UPLOAD (upload sungguhan ke server lewat multipart + progress)
// ---------------------------------------------------------------------------
abstract class CourseUploadService {
  Future<void> upload({
    required String title,
    required String description,
    required bool isPaid,
    required int price,
    required PlatformFile cover,
    required PlatformFile material,
    required void Function(double progress) onProgress,
  });
}

/// Default: menyalin file ASLI yang dipilih ke penyimpanan aplikasi (dengan progress),
/// jadi alur upload langsung jalan tanpa server. Untuk kirim ke server,
/// pakai HttpCourseUploadService (file http_course_upload_service.dart).
class LocalCourseUploadService implements CourseUploadService {
  @override
  Future<void> upload({
    required String title,
    required String description,
    required bool isPaid,
    required int price,
    required PlatformFile cover,
    required PlatformFile material,
    required void Function(double progress) onProgress,
  }) async {
    final dir = Directory(
        '${Directory.systemTemp.path}/nexa_courses/${DateTime.now().millisecondsSinceEpoch}');
    await dir.create(recursive: true);
    final total = (cover.size + material.size).clamp(1, 1 << 62);
    var done = 0;

    Future<void> copy(PlatformFile f, String name) async {
      final sink = File('${dir.path}/$name').openWrite();
      await for (final chunk in File(f.path!).openRead()) {
        sink.add(chunk);
        done += chunk.length;
        onProgress(done / total);
      }
      await sink.close();
    }

    await copy(cover, 'cover_${cover.name}');
    await copy(material, 'materi_${material.name}');
    await File('${dir.path}/info.txt').writeAsString(
        'judul: $title\ndeskripsi: $description\nberbayar: $isPaid\nharga: $price\n');
    onProgress(1);
  }
}

// ---------------------------------------------------------------------------
// HALAMAN BUAT KURSUS (disamakan dengan frame Figma "Buat Kursus")
// ---------------------------------------------------------------------------
class CreateCoursePage extends StatefulWidget {
  final CourseUploadService? service;
  final String authorName;
  const CreateCoursePage({
    super.key,
    this.service,
    this.authorName = 'Ignatius Ryan',
  });

  @override
  State<CreateCoursePage> createState() => _CreateCoursePageState();
}

class _CreateCoursePageState extends State<CreateCoursePage> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();

  PlatformFile? _cover;
  PlatformFile? _material;
  bool _paid = true;
  bool _uploading = false;
  double _progress = 0;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _price.dispose();
    super.dispose();
  }

  static bool _isVideoName(String name) {
    final n = name.toLowerCase();
    return n.endsWith('.mp4') || n.endsWith('.mov') || n.endsWith('.mkv');
  }

  /// Salin video ke penyimpanan aplikasi agar tidak hilang bersama cache picker.
  Future<String> _persistVideo(PlatformFile f) async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/nexa_videos');
    await dir.create(recursive: true);
    final safe = f.name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final dest =
        File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}_$safe');
    await File(f.path!).copy(dest.path);
    return dest.path;
  }

  int get _priceValue =>
      int.tryParse(_price.text.replaceAll('.', '').trim()) ?? 0;

  Future<void> _pickCover() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.image);
    if (r == null || r.files.single.path == null) return;
    final f = r.files.single;
    // Figma: "Rasio 16:9, minimal 1280x720 px"
    try {
      final img = await decodeImageFromList(await File(f.path!).readAsBytes());
      if (img.width < 1280 || img.height < 720) {
        _showResult(
            ok: false,
            title: 'Gambar Terlalu Kecil',
            message: 'Gunakan gambar minimal 1280x720 px (rasio 16:9).');
        return;
      }
    } catch (_) {}
    setState(() => _cover = f);
  }

  Future<void> _pickMaterial() async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf', 'mp4', 'mov', 'mkv'],
    );
    if (r != null && r.files.single.path != null) {
      setState(() => _material = r.files.single);
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_title.text.trim().isEmpty ||
        _desc.text.trim().isEmpty ||
        _cover == null ||
        _material == null ||
        (_paid && _priceValue <= 0)) {
      _showResult(
          ok: false,
          title: 'Harap Lengkapi Data',
          message:
              'Judul, deskripsi, gambar sampul, materi, dan harga (jika berbayar) wajib diisi.');
      return;
    }

    setState(() {
      _uploading = true;
      _progress = 0;
    });
    try {
      final title = _title.text.trim();
      final desc = _desc.text.trim();
      final cover = _cover!;
      final paid = _paid;
      final price = paid ? _priceValue : 0;

      final minLoading = Future.delayed(const Duration(milliseconds: 1400));
      await (widget.service ?? LocalCourseUploadService()).upload(
        title: title,
        description: desc,
        isPaid: paid,
        price: price,
        cover: cover,
        material: _material!,
        onProgress: (p) {
          if (mounted) setState(() => _progress = p.clamp(0, 1).toDouble());
        },
      );
      await minLoading; // supaya putaran loading sempat terlihat
      if (!mounted) return;

      // Materi berupa video -> simpan permanen supaya bisa diputar di detail kursus.
      String? videoPath;
      final mat = _material!;
      if (mat.path != null && _isVideoName(mat.name)) {
        try {
          videoPath = await _persistVideo(mat);
        } catch (e) {
          debugPrint('SIMPAN VIDEO GAGAL: $e');
          videoPath = mat.path; // cadangan: pakai file asli dari picker
        }
      }

      // Materi berhasil -> simpan kursus ke akun yang sedang login, supaya
      // otomatis muncul di Beranda ("Kursus Terbaru") dan tab Kursus.
      final session = AppSession.instance;
      final courseId = Course.newId();
      session.addCourse(Course(
        id: courseId,
        title: title,
        instructor: session.userOrGuest.displayName,
        price: price,
        rating: 0,
        students: 0,
        description: desc,
        thumbnail: cover.path,
        videoPath: videoPath,
      ));

      // Loading hilang, lalu hanya ikon sukses (bottom sheet, sesuai Figma)
      setState(() => _uploading = false);
      await _showSuccessSheet();
      if (!mounted) return;

      // Materi berhasil -> buka halaman detail kursus (frame "Excel")
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (_, _, _) => CourseDetailPage(
            courseId: courseId,
            title: title,
            description: desc,
            coverPath: cover.path!,
            videoPath: videoPath,
            price: price,
            ratable: true,
            authorName: widget.authorName,
          ),
          transitionsBuilder: (_, a, _, child) => FadeTransition(
            opacity: a,
            child: SlideTransition(
              position: Tween<Offset>(
                      begin: const Offset(0, .04), end: Offset.zero)
                  .animate(CurvedAnimation(parent: a, curve: Curves.easeOut)),
              child: child,
            ),
          ),
        ),
      );
    } catch (e, st) {
      debugPrint('UPLOAD ERROR: $e\n$st');
      if (mounted) {
        _showResult(
            ok: false,
            title: 'Terjadi Kesalahan',
            message: 'Upload gagal. Periksa koneksi lalu coba lagi.');
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  /// Sesuai prototipe Figma: panel putih naik dari bawah berisi ikon centang +
  /// teks saja (tanpa loading).
  Future<void> _showSuccessSheet() async {
    BuildContext? sheetCtx;
    Future.delayed(const Duration(milliseconds: 1500), () {
      final c = sheetCtx;
      if (c != null && c.mounted && (ModalRoute.of(c)?.isCurrent ?? false)) {
        Navigator.of(c).pop();
      }
    });
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      barrierColor: Colors.black26,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        sheetCtx = ctx;
        return SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.5,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _SuccessIcon(),
              const SizedBox(height: 18),
              Text('Materi Berhasil Diupload',
                  textAlign: TextAlign.center,
                  style: nexaText(18, weight: FontWeight.w700, color: kMaroon)),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                    'Materi berhasil diupload dan dapat dilihat oleh peserta',
                    textAlign: TextAlign.center,
                    style: nexaText(13, color: Colors.black87)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showResult({
    required bool ok,
    required String title,
    required String message,
    int? autoCloseMs,
  }) {
    if (autoCloseMs != null) {
      Future.delayed(Duration(milliseconds: autoCloseMs), () {
        if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      });
    }
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (_, a, _, child) => FadeTransition(
        opacity: a,
        child: ScaleTransition(
          scale: Tween<double>(begin: .9, end: 1)
              .animate(CurvedAnimation(parent: a, curve: Curves.easeOutBack)),
          child: child,
        ),
      ),
      pageBuilder: (ctx, _, _) => Center(
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: MediaQuery.of(ctx).size.width * 0.7,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ok
                      ? const _SuccessIcon()
                      : const Icon(Icons.warning_amber_rounded,
                          size: 36, color: kMaroon),
                  const SizedBox(height: 8),
                  Text(title,
                      textAlign: TextAlign.center,
                      style: nexaText(13, weight: FontWeight.w700, color: kMaroon)),
                  const SizedBox(height: 4),
                  Text(message,
                      textAlign: TextAlign.center,
                      style: nexaText(10, color: Colors.black54)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Border field = marun tipis, sudut 8 (sesuai Figma)
  InputDecoration _dec({String? hint}) => InputDecoration(
        hintText: hint,
        hintStyle: nexaText(12, color: Colors.black38),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: kMaroon, width: 1)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: kMaroon, width: 1.5)),
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: kMaroon, width: 1)),
      );

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6),
        child: Text(t, style: nexaText(13, weight: FontWeight.w600, color: Colors.black)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          SafeArea(
        child: AbsorbPointer(
          absorbing: _uploading,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              // Header: panah abu + judul marun tebal (bukan AppBar marun)
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.maybePop(context),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.arrow_back, color: Colors.black45, size: 26),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Buat Kursus',
                      style: nexaText(20, weight: FontWeight.w700, color: kMaroon)),
                ],
              ),
              _label('Judul  Kursus'),
              NexaKeyboardField(
                  controller: _title,
                  style: nexaText(12),
                  decoration: _dec()),
              _label('Deskripsi Singkat'),
              NexaKeyboardField(
                controller: _desc,
                style: nexaText(12),
                maxLines: 5,
                minLines: 5,
                textAlign: TextAlign.start, // kursor & teks mulai dari kiri
                textAlignVertical: TextAlignVertical.top,
                textCapitalization: TextCapitalization.sentences,
                decoration: _dec(),
              ),
              _label('Gambar Sampul'),
              _UploadBox(
                label: 'Unggah gambar',
                hint: 'Rasio 16:9, minimal 1280x720 px',
                onTap: _pickCover,
                preview: _cover == null
                    ? null
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(_cover!.path!),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity),
                      ),
              ),
              _label('Materi'),
              _UploadBox(
                label: _material == null ? 'Unggah materi' : _material!.name,
                hint: _material == null
                    ? 'JPG/PDF/MP4'
                    : '${(_material!.size / (1024 * 1024)).toStringAsFixed(1)} MB',
                onTap: _pickMaterial,
              ),
              _label('Harga Khusus'),
              Row(
                children: [
                  Expanded(
                      child: _Seg(
                          label: 'Berbayar',
                          selected: _paid,
                          onTap: () => setState(() => _paid = true))),
                  const SizedBox(width: 14),
                  Expanded(
                      child: _Seg(
                          label: 'Gratis',
                          selected: !_paid,
                          onTap: () => setState(() => _paid = false))),
                ],
              ),
              const SizedBox(height: 12),
              // Gratis -> "Rp.---" terkunci ; Berbayar -> "Rp. 50.000" bisa diketik
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _paid
                    ? NexaKeyboardField(
                        key: const ValueKey('paid'),
                        controller: _price,
                        numeric: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _RupiahFormatter(),
                        ],
                        style: nexaText(15, weight: FontWeight.w700, color: Colors.black),
                        decoration: _dec().copyWith(
                          prefixText: 'Rp. ',
                          prefixStyle:
                              nexaText(12, weight: FontWeight.w700, color: Colors.black),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                        ),
                      )
                    : TextField(
                        key: const ValueKey('free'),
                        enabled: false,
                        style: nexaText(13, weight: FontWeight.w700, color: Colors.black),
                        decoration: _dec().copyWith(
                          hintText: 'Rp.---',
                          hintStyle:
                              nexaText(13, weight: FontWeight.w700, color: Colors.black),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                        ),
                      ),
              ),
              const SizedBox(height: 28),
              TapScale(
                child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: _uploading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kMaroon,
                    disabledBackgroundColor: kMaroon.withValues(alpha: 0.7),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _uploading
                        ? Text('Mengupload ${(_progress * 100).toStringAsFixed(0)}%',
                            key: const ValueKey('up'),
                            style: nexaText(13, weight: FontWeight.w600, color: Colors.white))
                        : Text('Upload Materi',
                            key: const ValueKey('idle'),
                            style: nexaText(13, weight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
                ),
              ),
            ],
          ),
        ),
      ),
          // Loading seperti layar "Sedang masuk": putaran searah jarum jam
          if (_uploading)
            Positioned.fill(
              child: Container(
                color: Colors.white,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const GradientSpinner(),
                    const SizedBox(height: 48),
                    PleaseWaitText(
                        text: 'Sedang mengupload materi,\nharap tunggu',
                        style: nexaText(13, color: Colors.black87)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Format angka ke 50.000 saat diketik.
class _RupiahFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue now) {
    final digits = now.text.replaceAll('.', '');
    if (digits.isEmpty) return const TextEditingValue();
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
      buf.write(digits[i]);
    }
    final t = buf.toString();
    return TextEditingValue(text: t, selection: TextSelection.collapsed(offset: t.length));
  }
}

class _UploadBox extends StatelessWidget {
  final String label, hint;
  final VoidCallback onTap;
  final Widget? preview;
  const _UploadBox({
    required this.label,
    required this.hint,
    required this.onTap,
    this.preview,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: preview != null ? 120 : (hint.startsWith('Rasio') ? 110 : 110),
        width: double.infinity,
        decoration: BoxDecoration(color: kMaroon, borderRadius: BorderRadius.circular(8)),
        child: preview ??
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.file_upload_outlined, color: Colors.white, size: 30),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: nexaText(12, weight: FontWeight.w600, color: Colors.white)),
                ),
                const SizedBox(height: 2),
                Text(hint, style: nexaText(8, color: Colors.white)),
              ],
            ),
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Seg({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? kMaroon : Colors.white,
          border: Border.all(color: selected ? kMaroon : Colors.black54),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
            style: nexaText(13,
                weight: FontWeight.w700, color: selected ? Colors.white : Colors.black)),
      ),
    );
  }
}

/// Ikon sukses sesuai Figma: kotak marun bersudut membulat + centang
/// yang ujung kanannya keluar dari kotak.
class _SuccessIcon extends StatelessWidget {
  const _SuccessIcon();

  @override
  Widget build(BuildContext context) =>
      const SizedBox(width: 44, height: 44, child: CustomPaint(painter: _SuccessIconPainter()));
}

class _SuccessIconPainter extends CustomPainter {
  const _SuccessIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final paint = Paint()
      ..color = kMaroon
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Kotak: terbuka di sisi kanan atas supaya centang bisa "keluar"
    final l = w * 0.04, t = h * 0.14, r = w * 0.96, b = h * 0.96, rad = w * 0.14;
    final box = Path()
      ..moveTo(w * 0.62, t)
      ..lineTo(l + rad, t)
      ..arcToPoint(Offset(l, t + rad), radius: Radius.circular(rad), clockwise: false)
      ..lineTo(l, b - rad)
      ..arcToPoint(Offset(l + rad, b), radius: Radius.circular(rad), clockwise: false)
      ..lineTo(r - rad, b)
      ..arcToPoint(Offset(r, b - rad), radius: Radius.circular(rad), clockwise: false)
      ..lineTo(r, h * 0.52);
    canvas.drawPath(box, paint);

    // Centang
    final check = Path()
      ..moveTo(w * 0.30, h * 0.52)
      ..lineTo(w * 0.48, h * 0.70)
      ..lineTo(w * 0.96, h * 0.06);
    canvas.drawPath(check, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Loading cincin gradasi marun -- SAMA dengan layar loading Daftar/Masuk
/// (LoginLoadingScreen). Berputar searah jarum jam.
class GradientSpinner extends StatefulWidget {
  final double size;
  const GradientSpinner({super.key, this.size = 80});

  @override
  State<GradientSpinner> createState() => _GradientSpinnerState();
}

class _GradientSpinnerState extends State<GradientSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // turns 0 -> 1 = putaran positif = searah jarum jam
    return RotationTransition(
      turns: _c,
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: const _GradientRingPainter(),
      ),
    );
  }
}

class _GradientRingPainter extends CustomPainter {
  const _GradientRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 6.0;
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
       colors: [kMaroon.withValues(alpha: 0.0), kMaroon],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);
    canvas.drawArc(rect.deflate(stroke / 2), -math.pi / 2, math.pi * 2 * 0.92,
        false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
