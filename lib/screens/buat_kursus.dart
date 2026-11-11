import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../data/kursus_repository.dart';
import 'header_maroon.dart';

const int _maksGambar = 5 * 1024 * 1024; // 5 MB
const int _maksMateri = 200 * 1024 * 1024; // 200 MB
const List<String> _ekstensiMateri = ['jpg', 'jpeg', 'png', 'pdf', 'mp4'];

class BuatKursus extends StatefulWidget {
  const BuatKursus({super.key});

  @override
  State<BuatKursus> createState() => _BuatKursusState();
}

class _BuatKursusState extends State<BuatKursus> {
  final _judul = TextEditingController();
  final _deskripsi = TextEditingController();
  final _harga = TextEditingController();

  File? _gambar;
  File? _materi;
  String? _materiNama;
  bool _berbayar = true;
  bool _mengunggah = false;

  @override
  void dispose() {
    _judul.dispose();
    _deskripsi.dispose();
    _harga.dispose();
    super.dispose();
  }

  void _snack(String teks) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(teks)));
  }

  // ---------- pilih file ----------

  Future<void> _pilihGambar() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      final file = File(picked.path);

      if (await file.length() > _maksGambar) {
        _snack('Ukuran gambar maksimal 5 MB');
        return;
      }

      final codec = await ui.instantiateImageCodec(await file.readAsBytes());
      final frame = await codec.getNextFrame();
      final w = frame.image.width;
      final h = frame.image.height;
      frame.image.dispose();
      codec.dispose();

      if (w < 1280 || h < 720) {
        _snack('Gambar minimal 1280x720 px (gambar ini ${w}x$h)');
        return;
      }
      if ((w / h - 16 / 9).abs() > 0.05) {
        _snack('Rasio gambar harus 16:9');
        return;
      }
      setState(() => _gambar = file);
    } catch (e) {
      _snack('Gagal memilih gambar: $e');
    }
  }

  Future<void> _pilihMateri() async {
    try {
      final r = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _ekstensiMateri,
        allowMultiple: false,
      );
      final f = r?.files.single;
      if (f == null || f.path == null) return;

      if (f.size > _maksMateri) {
        _snack('Ukuran materi maksimal 200 MB');
        return;
      }
      setState(() {
        _materi = File(f.path!);
        _materiNama = f.name;
      });
    } catch (e) {
      _snack('Gagal memilih materi: $e');
    }
  }

  // ---------- upload ----------

  Future<void> _upload() async {
    FocusScope.of(context).unfocus();

    if (_materi == null) {
      await _dialogInfo(
        ikon: Icons.warning_amber_rounded,
        judul: 'Harap Isi Materi\nTerlebih Dahulu!',
      );
      return;
    }
    if (_judul.text.trim().isEmpty) {
      _snack('Judul kursus wajib diisi');
      return;
    }
    if (_deskripsi.text.trim().isEmpty) {
      _snack('Deskripsi singkat wajib diisi');
      return;
    }
    if (_gambar == null) {
      _snack('Gambar sampul wajib diunggah');
      return;
    }

    var harga = 0;
    if (_berbayar) {
      harga = int.tryParse(_harga.text.replaceAll('.', '')) ?? 0;
      if (harga <= 0) {
        _snack('Masukkan harga kursus');
        return;
      }
    }

    setState(() => _mengunggah = true);
    try {
      await KursusRepository.instance.tambah(
        judul: _judul.text.trim(),
        deskripsi: _deskripsi.text.trim(),
        gambar: _gambar!,
        materi: _materi!,
        materiNama: _materiNama ?? 'materi',
        harga: harga,
      );
      if (!mounted) return;
      await _dialogInfo(
        ikon: Icons.check_box_outlined,
        judul: 'Materi Berhasil Diupload',
        isi: 'Materi berhasil di upload dan dapat dilihat oleh peserta',
      );
      if (!mounted) return;
      setState(() {
        _judul.clear();
        _deskripsi.clear();
        _harga.clear();
        _gambar = null;
        _materi = null;
        _materiNama = null;
      });
    } catch (e) {
      _snack('Upload gagal: $e');
    } finally {
      if (mounted) setState(() => _mengunggah = false);
    }
  }

  Future<void> _dialogInfo({
    required IconData ikon,
    required String judul,
    String? isi,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(ikon, size: 52, color: kMaroon),
              const SizedBox(height: 12),
              Text(
                judul,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: kMaroon,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (isi != null) ...[
                const SizedBox(height: 10),
                Text(
                  isi,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: kMaroon,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.grey),
                  ),
                  const Text(
                    'Buat Kursus',
                    style: TextStyle(
                      color: kMaroon,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('Judul Kursus'),
                      _Input(controller: _judul),
                      const SizedBox(height: 14),
                      const _Label('Deskripsi Singkat'),
                      _Input(
                        controller: _deskripsi,
                        minLines: 5,
                        maxLines: 7,
                        keyboardType: TextInputType.multiline,
                      ),
                      const SizedBox(height: 14),
                      const _Label('Gambar Sampul'),
                      _KotakUnggah(
                        judul: 'Unggah gambar',
                        keterangan: 'Rasio 16:9, minimal 1280x720 px',
                        terpilih: _gambar != null,
                        onTap: _pilihGambar,
                        pratinjau: _gambar == null
                            ? null
                            : Image.file(_gambar!,
                                fit: BoxFit.cover, width: double.infinity),
                      ),
                      const SizedBox(height: 14),
                      const _Label('Materi'),
                      _KotakUnggah(
                        judul: _materiNama ?? 'Unggah materi',
                        keterangan: _materi == null
                            ? 'JPG/PDF/MP4'
                            : 'Ketuk untuk mengganti',
                        terpilih: _materi != null,
                        onTap: _pilihMateri,
                      ),
                      const SizedBox(height: 14),
                      const _Label('Harga Khusus'),
                      Row(
                        children: [
                          Expanded(
                            child: _PilihanHarga(
                              teks: 'Berbayar',
                              aktif: _berbayar,
                              onTap: () => setState(() => _berbayar = true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _PilihanHarga(
                              teks: 'Gratis',
                              aktif: !_berbayar,
                              onTap: () => setState(() => _berbayar = false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_berbayar)
                        _Input(
                          controller: _harga,
                          hint: '---',
                          prefix: 'Rp. ',
                          keyboardType: TextInputType.number,
                          formatters: [_RibuanFormatter()],
                          tebal: true,
                        ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _mengunggah ? null : _upload,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kMaroon,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFFB07A7D),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _mengunggah
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Upload Materi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.teks);
  final String teks;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          teks,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      );
}

class _Input extends StatelessWidget {
  const _Input({
    required this.controller,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
    this.formatters,
    this.hint,
    this.prefix,
    this.tebal = false,
  });

  final TextEditingController controller;
  final int minLines;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final String? hint;
  final String? prefix;
  final bool tebal;

  OutlineInputBorder get _border => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kMaroon, width: 1),
      );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      style: TextStyle(
        fontSize: 15,
        fontWeight: tebal ? FontWeight.w600 : FontWeight.w400,
      ),
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        prefixText: prefix,
        prefixStyle: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        enabledBorder: _border,
        focusedBorder: _border.copyWith(
          borderSide: const BorderSide(color: kMaroon, width: 1.6),
        ),
      ),
    );
  }
}

class _KotakUnggah extends StatelessWidget {
  const _KotakUnggah({
    required this.judul,
    required this.keterangan,
    required this.terpilih,
    required this.onTap,
    this.pratinjau,
  });

  final String judul;
  final String keterangan;
  final bool terpilih;
  final VoidCallback onTap;
  final Widget? pratinjau;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kMaroon,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          height: 112,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ?pratinjau,
              Container(
                color: pratinjau != null
                    ? const Color(0x99000000)
                    : Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      terpilih ? Icons.check_circle_outline : Icons.upload,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      judul,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      keterangan,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PilihanHarga extends StatelessWidget {
  const _PilihanHarga({
    required this.teks,
    required this.aktif,
    required this.onTap,
  });

  final String teks;
  final bool aktif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: aktif ? kMaroon : Colors.white,
          foregroundColor: aktif ? Colors.white : Colors.black,
          side: BorderSide(color: aktif ? kMaroon : Colors.black, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          teks,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// 50000 -> 50.000
class _RibuanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
      buf.write(digits[i]);
    }
    final t = buf.toString();
    return TextEditingValue(
      text: t,
      selection: TextSelection.collapsed(offset: t.length),
    );
  }
}