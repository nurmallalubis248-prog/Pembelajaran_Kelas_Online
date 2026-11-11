import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
// HALAMAN BUAT KURSUS
// ---------------------------------------------------------------------------
class CreateCoursePage extends StatefulWidget {
  final CourseUploadService? service;
  const CreateCoursePage({super.key, this.service});

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

  Future<void> _pickCover() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.image);
    if (r != null && r.files.single.path != null) {
      setState(() => _cover = r.files.single);
    }
  }

  Future<void> _pickMaterial() async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['mp4', 'mov', 'mkv', 'pdf', 'ppt', 'pptx', 'doc', 'docx'],
    );
    if (r != null && r.files.single.path != null) {
      setState(() => _material = r.files.single);
    }
  }

  Future<void> _submit() async {
    final price = int.tryParse(_price.text.trim()) ?? 0;
    if (_title.text.trim().isEmpty ||
        _desc.text.trim().isEmpty ||
        _cover == null ||
        _material == null ||
        (_paid && price <= 0)) {
      _showResult(ok: false, title: 'Harap Lengkapi Data',
          message: 'Judul, deskripsi, gambar sampul, materi, dan harga (jika berbayar) wajib diisi.');
      return;
    }

    setState(() {
      _uploading = true;
      _progress = 0;
    });
    try {
      await (widget.service ?? LocalCourseUploadService()).upload(
        title: _title.text.trim(),
        description: _desc.text.trim(),
        isPaid: _paid,
        price: _paid ? price : 0,
        cover: _cover!,
        material: _material!,
        onProgress: (p) {
          if (mounted) setState(() => _progress = p.clamp(0, 1).toDouble());
        },
      );
      if (!mounted) return;
      _showResult(ok: true, title: 'Materi Berhasil Diupload',
          message: 'Materi kursus berhasil diupload dan dapat dilihat oleh peserta.');
      setState(() {
        _title.clear();
        _desc.clear();
        _price.clear();
        _cover = null;
        _material = null;
      });
    } catch (e) {
      if (mounted) {
        _showResult(ok: false, title: 'Terjadi Kesalahan',
            message: 'Upload gagal. Periksa koneksi lalu coba lagi.');
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _showResult({required bool ok, required String title, required String message}) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (_, a, secondaryAnimation, child) => FadeTransition(
        opacity: a,
        child: ScaleTransition(
          scale: Tween<double>(begin: .9, end: 1)
              .animate(CurvedAnimation(parent: a, curve: Curves.easeOutBack)),
          child: child,
        ),
      ),
      pageBuilder: (ctx, anim1, anim2) => Center(
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
                  Icon(ok ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                      size: 36, color: kMaroon),
                  const SizedBox(height: 8),
                  Text(title, textAlign: TextAlign.center,
                      style: nexaText(13, weight: FontWeight.w700, color: kMaroon)),
                  const SizedBox(height: 4),
                  Text(message, textAlign: TextAlign.center,
                      style: nexaText(10, color: Colors.black54)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: nexaText(11, color: Colors.black38),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: kFieldBorder)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: kMaroon)),
      );

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Text(t, style: nexaText(11, weight: FontWeight.w600)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kMaroon,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Text('Buat Kursus',
            style: nexaText(14, weight: FontWeight.w600, color: Colors.white)),
      ),
      body: AbsorbPointer(
        absorbing: _uploading,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            _label('Judul Kursus'),
            TextField(controller: _title, style: nexaText(12), decoration: _dec('Judul Kursus')),
            _label('Deskripsi Singkat'),
            TextField(
                controller: _desc,
                style: nexaText(12),
                maxLines: 3,
                decoration: _dec('Deskripsi Singkat')),
            _label('Gambar Sampul'),
            _UploadBox(
              label: 'Unggah Gambar',
              hint: 'JPG / PNG',
              onTap: _pickCover,
              preview: _cover == null
                  ? null
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(File(_cover!.path!), fit: BoxFit.cover,
                          width: double.infinity, height: double.infinity),
                    ),
            ),
            _label('Materi'),
            _UploadBox(
              label: _material == null ? 'Unggah Materi' : _material!.name,
              hint: _material == null
                  ? 'Video / PDF / PPT / DOC'
                  : '${(_material!.size / (1024 * 1024)).toStringAsFixed(1)} MB',
              onTap: _pickMaterial,
              icon: _material == null ? Icons.file_upload_outlined : Icons.insert_drive_file_outlined,
            ),
            _label('Harga Khusus'),
            Row(
              children: [
                _Seg(label: 'Berbayar', selected: _paid, onTap: () => setState(() => _paid = true)),
                const SizedBox(width: 8),
                _Seg(label: 'Gratis', selected: !_paid, onTap: () => setState(() => _paid = false)),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: _paid
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: TextField(
                        controller: _price,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: nexaText(12),
                        decoration: _dec('50000').copyWith(prefixText: 'Rp. '),
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: _uploading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kMaroon,
                  disabledBackgroundColor: kMaroon.withValues(alpha: 0.7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _uploading
                      ? Text('Mengupload ${(_progress * 100).toStringAsFixed(0)}%',
                          key: const ValueKey('up'),
                          style: nexaText(12, weight: FontWeight.w600, color: Colors.white))
                      : Text('Upload Materi',
                          key: const ValueKey('idle'),
                          style: nexaText(12, weight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ),
            if (_uploading)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(
                    value: _progress, color: kMaroon, backgroundColor: kFieldBorder),
              ),
          ],
        ),
      ),
    );
  }
}

class _UploadBox extends StatelessWidget {
  final String label, hint;
  final VoidCallback onTap;
  final Widget? preview;
  final IconData icon;
  const _UploadBox({
    required this.label,
    required this.hint,
    required this.onTap,
    this.preview,
    this.icon = Icons.file_upload_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 90,
        width: double.infinity,
        decoration: BoxDecoration(color: kMaroon, borderRadius: BorderRadius.circular(6)),
        child: preview ??
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: nexaText(11, weight: FontWeight.w600, color: Colors.white)),
                ),
                Text(hint, style: nexaText(9, color: Colors.white70)),
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? kMaroon : Colors.white,
          border: Border.all(color: kMaroon),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: nexaText(11,
                weight: FontWeight.w600, color: selected ? Colors.white : kMaroon)),
      ),
    );
  }
}
