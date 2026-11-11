import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Kursus {
  Kursus({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.gambarPath,
    required this.materiPath,
    required this.materiNama,
    required this.harga,
    required this.dibuat,
  });

  final String id;
  final String judul;
  final String deskripsi;
  final String gambarPath;
  final String materiPath;
  final String materiNama;

  /// 0 = gratis.
  final int harga;
  final DateTime dibuat;

  bool get gratis => harga == 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'judul': judul,
        'deskripsi': deskripsi,
        'gambarPath': gambarPath,
        'materiPath': materiPath,
        'materiNama': materiNama,
        'harga': harga,
        'dibuat': dibuat.toIso8601String(),
      };

  factory Kursus.fromJson(Map<String, dynamic> j) => Kursus(
        id: j['id'] as String,
        judul: j['judul'] as String,
        deskripsi: j['deskripsi'] as String,
        gambarPath: j['gambarPath'] as String,
        materiPath: j['materiPath'] as String,
        materiNama: j['materiNama'] as String,
        harga: j['harga'] as int,
        dibuat: DateTime.parse(j['dibuat'] as String),
      );
}

/// Menyimpan kursus. File gambar & materi DISALIN ke folder dokumen aplikasi,
/// jadi file asli tetap ada walau file di galeri/cache dihapus.
class KursusRepository {
  KursusRepository._();
  static final KursusRepository instance = KursusRepository._();

  static const _key = 'kursus_v1';

  Future<List<Kursus>> semua() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Kursus.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Kursus> tambah({
    required String judul,
    required String deskripsi,
    required File gambar,
    required File materi,
    required String materiNama,
    required int harga,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final base = await getApplicationDocumentsDirectory();
    final sep = Platform.pathSeparator;
    final dir = Directory('${base.path}${sep}kursus$sep$id');
    await dir.create(recursive: true);

    try {
      final g = await gambar.copy('${dir.path}${sep}sampul${_ext(gambar.path)}');
      final m = await materi.copy('${dir.path}${sep}materi${_ext(materi.path)}');

      final kursus = Kursus(
        id: id,
        judul: judul,
        deskripsi: deskripsi,
        gambarPath: g.path,
        materiPath: m.path,
        materiNama: materiNama,
        harga: harga,
        dibuat: DateTime.now(),
      );

      final semuaKursus = await semua();
      semuaKursus.insert(0, kursus);
      final p = await SharedPreferences.getInstance();
      await p.setString(
        _key,
        jsonEncode(semuaKursus.map((e) => e.toJson()).toList()),
      );
      return kursus;
    } catch (_) {
      if (await dir.exists()) await dir.delete(recursive: true);
      rethrow;
    }
  }

  String _ext(String path) {
    final i = path.lastIndexOf('.');
    if (i < 0 || path.length - i > 6) return '';
    return path.substring(i).toLowerCase();
  }
}
