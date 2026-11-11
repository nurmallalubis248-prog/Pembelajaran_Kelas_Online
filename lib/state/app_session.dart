import 'package:flutter/foundation.dart';

/// Data diri (sesuai layar "Profil Saya").
class UserProfile {
  final String name, about, education, experience;
  const UserProfile({
    required this.name,
    required this.about,
    required this.education,
    required this.experience,
  });
}

class CourseItem {
  final String title, instructor, cover;
  final int price, rating;
  const CourseItem({
    required this.title,
    required this.instructor,
    required this.price,
    this.rating = 5,
    this.cover = 'assets/images/sampul_persegi_excel.png',
  });
}

class SaleItem {
  final String buyer, course, when;
  const SaleItem(this.buyer, this.course, this.when);
}

class IncomeItem {
  final String title, buyer, date;
  final int amount;
  const IncomeItem(this.title, this.buyer, this.date, this.amount);
}

/// Sesi pengguna yang sedang login. Semua tab (Beranda, Kursus, Keuangan,
/// Profil) membaca data dari sini, jadi:
///  - akun Ignasius (Google / Facebook / email igna@gmail.com) -> data terisi
///  - akun baru (daftar baru / email lain) -> semua kosong
///
/// Ini masih data contoh di memori. Saat backend/Firebase siap, cukup ganti
/// isi [_loadIgnasius] dan [_clear] dengan data dari server.
class AppSession extends ChangeNotifier {
  AppSession._();
  static final AppSession instance = AppSession._();

  /// Email akun Ignasius yang sudah terdaftar (email + password).
  static const ignasiusEmail = 'igna@gmail.com';

  String? email;
  UserProfile? profile;
  List<CourseItem> courses = [];
  List<SaleItem> sales = [];
  List<IncomeItem> incomes = [];
  int balance = 0;
  int students = 0;
  List<String> chartLabels = ['Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt'];
  List<double> chartValues = [0, 0, 0, 0, 0, 0];

  // Pengaturan di tab Profil
  bool wifiOnly = false;
  bool notifications = false;

  bool get hasProfile => profile != null;

  // ---- Aksi login / daftar ------------------------------------------------

  /// Login email + password. Email Ignasius -> data terisi, selain itu kosong.
  void signInEmail(String mail) {
    final m = mail.trim().toLowerCase();
    if (m == ignasiusEmail) {
      _loadIgnasius(m);
    } else {
      _clear(m);
    }
  }

  /// Login lewat Google / Facebook (akun Ignasius pada pop-up pilih akun).
  void signInSocial() => _loadIgnasius(ignasiusEmail);

  /// Daftar akun baru -> semua data kosong sampai diisi.
  void startSignUp(String mail) => _clear(mail.trim().toLowerCase());

  /// Dipanggil dari layar Buat Profil Pengajar.
  void saveProfile({
    required String name,
    required String about,
    required String education,
    required String experience,
  }) {
    profile = UserProfile(
      name: name.trim(),
      about: about.trim(),
      education: education.trim(),
      experience: experience.trim(),
    );
    notifyListeners();
  }

  void setWifiOnly(bool v) {
    wifiOnly = v;
    notifyListeners();
  }

  void setNotifications(bool v) {
    notifications = v;
    notifyListeners();
  }

  void logout() => _clear(null);

  // ---- Isi data -----------------------------------------------------------

  void _clear(String? mail) {
    email = mail;
    profile = null;
    courses = [];
    sales = [];
    incomes = [];
    balance = 0;
    students = 0;
    chartValues = [0, 0, 0, 0, 0, 0];
    wifiOnly = false;
    notifications = false;
    notifyListeners();
  }

  void _loadIgnasius(String mail) {
    email = mail;
    profile = const UserProfile(
      name: 'Ignasius Ryan',
      about:
          'Saya adalah seorang profesional yang berdedikasi dan selalu bersemangat untuk belajar hal baru. Memiliki minat besar dalam pengembangan diri, kolaborasi tim, dan memberikan kontribusi terbaik di bidang yang saya tekuni.',
      education:
          'S1 Pendidikan Matematika Universitas Indonesia\nS2 Bisnis Digital Universitas Negeri Jakarta',
      experience: '3 Tahun di Tanjung Corporate',
    );
    courses = const [
      CourseItem(
        title: 'Belajar Excel dari Nol episode 1',
        instructor: 'Ignasius Ryan',
        price: 60000,
      ),
    ];
    sales = const [
      SaleItem('Bella Ambarita', 'Belajar Excel Dari Nol Episode 1', '3 Bulan Lalu'),
      SaleItem('Cinta aulia', 'Belajar Microsoft Word Dari Nol', '2 Minggu Lalu'),
    ];
    incomes = const [
      IncomeItem('Penjualan: Excel', 'Nurmala', '1 Okt', 60000),
      IncomeItem('Penjualan: Excel', 'Sania', '3 Okt', 60000),
      IncomeItem('Penjualan: Excel', 'Syfa', '10 Okt', 60000),
    ];
    balance = 620000;
    students = 75;
    chartValues = [2.5, 2.8, 2.6, 3.1, 2.5, 3.0];
    wifiOnly = false;
    notifications = false;
    notifyListeners();
  }
}
