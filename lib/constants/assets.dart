class AppAssets {
  // Images
  static const String logo = 'assets/images/logo.png';

  // Icons
  static const String googleIcon = 'assets/icons/google.png';
  static const String facebookIcon = 'assets/icons/facebook.png';

  // Ikon navbar bawah. Kalau file ikonmu ada di folder lain (mis.
  // assets/images/), cukup ubah path di empat baris ini.
  static const String navBeranda = 'assets/icons/beranda.png';
  static const String navKursus = 'assets/icons/kursus.png';
  static const String navKeuangan = 'assets/icons/keuangan.png';
  static const String navProfil = 'assets/icons/profil.png';

  /// true  = ikon diwarnai otomatis (merah saat aktif, hitam saat tidak).
  ///         Cocok untuk ikon satu warna dengan latar transparan.
  /// false = ikon ditampilkan apa adanya (pakai warna asli file PNG).
  static const bool navIconTint = true;
}
