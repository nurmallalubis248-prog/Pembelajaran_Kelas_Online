import 'package:flutter/foundation.dart';
import '../models/user_account.dart';
import '../utils/format.dart';
import '../widgets/account_chooser_dialog.dart';

/// Penyimpanan sesi + daftar akun (di memori).
///
/// LOGIKA:
///  * Akun contoh "Ignatius Ryan" sudah terdaftar dengan 3 cara masuk:
///    Gmail + kata sandi, akun Google, dan akun Facebook. Ketiganya
///    membuka AKUN YANG SAMA -> Beranda/Kursus/Keuangan/Profil sudah terisi.
///  * Akun yang baru Daftar dibuat KOSONG (profil, kursus, keuangan kosong)
///    sampai pengguna mengisi sendiri.
///
/// CATATAN: ganti dengan Firebase/API + penyimpanan permanen (mis.
/// shared_preferences). Saat ini akun baru hilang bila aplikasi ditutup.
class AppSession extends ChangeNotifier {
  AppSession._() {
    _register(_buildIgnatius());
  }
  static final AppSession instance = AppSession._();

  // Data login akun contoh (sesuai desain "Login-Sign In 2").
  static const demoEmail = 'igna@gmail.com';
  static const demoPassword = 'Budi01Gaming';
  static const demoFacebookName = 'Ignatius Gaming';

  final Map<String, UserAccount> _accounts = {};
  UserAccount? _current;

  UserAccount? get user => _current;

  // Cadangan kosong agar layar tidak error sesaat setelah Log Out.
  static final UserAccount _guest = UserAccount(email: '', password: '');
  UserAccount get userOrGuest => _current ?? _guest;
  bool get isLoggedIn => _current != null;

  String _key(String email) => email.trim().toLowerCase();
  void _register(UserAccount a) => _accounts[_key(a.email)] = a;

  bool isEmailRegistered(String email) => _accounts.containsKey(_key(email));

  /// Masuk dengan Gmail + kata sandi. Mengembalikan null bila salah.
  UserAccount? signInWithEmail(String email, String password) {
    final a = _accounts[_key(email)];
    if (a == null || a.password != password) return null;
    _current = a;
    notifyListeners();
    return a;
  }

  /// Masuk lewat Google / Facebook. [label] = teks akun yang dipilih di
  /// pop-up (email Google atau nama Facebook).
  UserAccount? signInWithSocial(SocialProvider provider, String label) {
    UserAccount? found;
    for (final a in _accounts.values) {
      final match = provider == SocialProvider.google
          ? a.googleEmail?.toLowerCase() == label.trim().toLowerCase()
          : a.facebookName == label;
      if (match) {
        found = a;
        break;
      }
    }
    if (found == null) return null;
    _current = found;
    notifyListeners();
    return found;
  }

  /// Daftar akun baru. Akun baru KOSONG: tanpa nama, kursus, penjualan,
  /// pendapatan, saldo, dan statistik. Data contoh Ignatius hanya untuk akun
  /// contoh (demoEmail).
  UserAccount register(String email, String password) {
    final a = UserAccount(email: email.trim(), password: password);
    _register(a);
    _current = a;
    notifyListeners();
    return a;
  }

  /// Simpan hasil halaman "Buat Profil".
  void saveProfile({
    required String name,
    required String about,
    required String education,
    required String experience,
  }) {
    final a = _current;
    if (a == null) return;
    a.name = name.trim();
    a.about = about.trim();
    a.education = education.trim();
    a.experience = experience.trim();
    notifyListeners();
  }

  /// Kurangi saldo akun aktif (dipakai saat penarikan dana).
  /// Semua layar yang membaca saldo dari AppSession ikut ter-update.
  bool deductBalance(int amount) {
    final a = _current;
    if (a == null || amount <= 0 || amount > a.balance) return false;
    a.balance -= amount;
    notifyListeners();
    return true;
  }

  /// Catat penjualan baru di akun aktif: saldo naik, masuk Riwayat pendapatan,
  /// dan batang bulan [when] di Kartu Statistik ikut naik (bulan baru ->
  /// batang baru). Kartu Statistik mendengarkan AppSession, jadi otomatis tampil.
  bool recordSale({
    required String courseTitle,
    required String buyer,
    required int amount,
    DateTime? when,
  }) {
    final a = _current;
    if (a == null || amount <= 0) return false;
    final d = when ?? DateTime.now();
    a.balance += amount;
    a.transactions.insert(
      0,
      IncomeTransaction(
        title: 'Penjualan: $courseTitle',
        dateAndBuyer: '${d.day} ${shortMonthName(d.month)}: $buyer',
        amount: amount,
      ),
    );
    a.addMonthlyIncome(amount, d);
    notifyListeners();
    return true;
  }

  /// Tambah kursus baru ke akun aktif (paling atas). Beranda dan tab Kursus
  /// otomatis menampilkannya karena keduanya mendengarkan AppSession.
  void addCourse(Course course) {
    final a = _current;
    if (a == null) return;
    a.courses.insert(0, course);
    notifyListeners();
  }

  /// Kembalikan kursus, penjualan, pendapatan, saldo & statistik SEMUA akun
  /// ke data awal (sesuai desain). Profil (nama, tentang, dst.) tidak diubah.
  /// Dipakai saat Log Out supaya data uji coba (kursus baru / penarikan)
  /// tidak terbawa.
  void resetTestData() {
    _ratings.clear();
    for (final a in _accounts.values) {
      // akun contoh -> data awal desain; akun lain -> kosong
      final s = _key(a.email) == _key(demoEmail)
          ? _buildIgnatius()
          : UserAccount(email: a.email, password: a.password);
      a.courses
        ..clear()
        ..addAll(s.courses);
      a.sales
        ..clear()
        ..addAll(s.sales);
      a.transactions
        ..clear()
        ..addAll(s.transactions);
      a.balance = s.balance;
      a.monthlyIncomeByMonth
        ..clear()
        ..addAll(s.monthlyIncomeByMonth);
    }
    notifyListeners();
  }

  // Rata-rata rating kursus (kunci = Course.key). Diisi dari halaman detail
  // saat pengguna menilai, supaya daftar kursus langsung ikut berubah.
  final Map<String, double> _ratings = {};

  double ratingFor(Course c) => _ratings[c.key] ?? c.rating;

  void setRating(String courseKey, double average) {
    if (_ratings[courseKey] == average) return;
    _ratings[courseKey] = average;
    notifyListeners();
  }

  void signOut() {
    _current = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Data contoh Ignatius (diambil dari desain home, kelas, finance, profil)
  // ---------------------------------------------------------------------
  UserAccount _buildIgnatius() {
    return UserAccount(
      email: demoEmail,
      password: demoPassword,
      googleEmail: demoEmail,
      facebookName: demoFacebookName,
      name: 'Ignatius Ryan',
      about: 'Saya adalah seorang profesional yang berdedikasi dan selalu '
          'bersemangat untuk belajar hal baru. Memiliki minat besar dalam '
          'pengembangan diri, kolaborasi tim, dan memberikan kontribusi '
          'terbaik di bidang yang saya tekuni.',
      education: 'S1 Pendidikan Matematika Universitas Indonesia\n'
          'S2 Bisnis Digital Universitas Negeri Jakarta',
      experience: '3 Tahun di Tanjung Corporate',
      courses: const [
        Course(
          id: 'seed-excel-1',
          title: 'Belajar Excel dari Nol episode 1',
          instructor: 'Ignatius Ryan',
          price: 60000,
          rating: 5,
          students: 75,
          thumbnail: 'assets/images/sampul_persegi_excel.png',
        ),
      ],
      sales: const [
        Sale(
          buyer: 'Bella Ambarita',
          courseTitle: 'Belajar Excel Dari Nol Episode 1',
          timeAgo: '3 Bulan Lalu',
        ),
        Sale(
          buyer: 'Cinta aulia',
          courseTitle: 'Belajar Excel Dari Nol Episode 1',
          timeAgo: '2 Minggu Lalu',
        ),
      ],
      transactions: const [
        IncomeTransaction(
            title: 'Penjualan: Excel',
            dateAndBuyer: '1 Okt: Nurmala',
            amount: 60000),
        IncomeTransaction(
            title: 'Penjualan: Excel',
            dateAndBuyer: '3 Okt: Sania',
            amount: 60000),
        IncomeTransaction(
            title: 'Penjualan: Excel',
            dateAndBuyer: '10 Okt: Syfa',
            amount: 60000),
      ],
      balance: 620000,
      // Angka batang Figma (juta rupiah): Mei..Okt 2026.
      monthlyIncomeByMonth: const {
        '2026-05': 2.5,
        '2026-06': 2.8,
        '2026-07': 2.6,
        '2026-08': 3.1,
        '2026-09': 2.5,
        '2026-10': 3.0,
      },
    );
  }
}