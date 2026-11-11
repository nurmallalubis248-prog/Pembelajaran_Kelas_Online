import 'package:shared_preferences/shared_preferences.dart';

enum KualitasVideo {
  hemat('Penghemat Data', '360p'),
  baik('Baik', '480p'),
  lebihBaik('Lebih Baik', '720p'),
  terbaik('Terbaik', '1080p');

  const KualitasVideo(this.label, this.resolusi);
  final String label;
  final String resolusi;
}

/// Menyimpan pilihan kualitas upload video (tetap tersimpan setelah app ditutup).
class UploadPrefs {
  UploadPrefs._();

  static const _key = 'kualitas_upload_video';
  static const KualitasVideo bawaan = KualitasVideo.lebihBaik;

  static Future<KualitasVideo> muat() async {
    final p = await SharedPreferences.getInstance();
    final nama = p.getString(_key);
    return KualitasVideo.values.firstWhere(
      (e) => e.name == nama,
      orElse: () => bawaan,
    );
  }

  static Future<void> simpan(KualitasVideo k) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, k.name);
  }
}
