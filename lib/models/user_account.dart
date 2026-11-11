/// Model data milik satu akun NeXa.
///
/// Akun Ignatius (akun contoh di desain) punya data lengkap.
/// Akun baru (hasil Daftar) dibuat KOSONG: tanpa profil, kursus, penjualan
/// dan pendapatan.
class Course {
  /// ID unik kursus. Dipakai untuk membuka detail yang benar & menyimpan
  /// rating (JANGAN pakai judul: dua kursus bisa berjudul sama).
  /// Null hanya untuk data contoh lama -> dianggap [title].
  final String? id;
  final String title;
  final String instructor;
  final int price; // rupiah
  final double rating; // 0..5
  final int students;

  /// Deskripsi kursus (diisi saat upload; null untuk data contoh).
  final String? description;

  /// Path gambar sampul di assets (boleh null -> kotak berwarna).
  final String? thumbnail;

  /// Path file video materi di perangkat (null = kursus tanpa video).
  final String? videoPath;

  /// Kunci stabil untuk rating / routing.
  String get key => id ?? title;

  /// ID baru yang unik untuk kursus yang baru dibuat.
  static String newId() => 'c${DateTime.now().microsecondsSinceEpoch}';

  const Course({
    this.id,
    required this.title,
    required this.instructor,
    required this.price,
    required this.rating,
    required this.students,
    this.description,
    this.thumbnail,
    this.videoPath,
  });
}

class Sale {
  final String buyer;
  final String courseTitle;
  final String timeAgo; // contoh: '3 Bulan Lalu'

  const Sale({
    required this.buyer,
    required this.courseTitle,
    required this.timeAgo,
  });
}

class IncomeTransaction {
  final String title; // contoh: 'Penjualan: Excel'
  final String dateAndBuyer; // contoh: '1 Okt: Nurmala'
  final int amount; // rupiah

  const IncomeTransaction({
    required this.title,
    required this.dateAndBuyer,
    required this.amount,
  });
}

/// Satu batang di Kartu Statistik: bulan + pendapatannya (juta rupiah).
class MonthlyIncomePoint {
  final DateTime month; // selalu tanggal 1
  final double juta;

  const MonthlyIncomePoint(this.month, this.juta);
}

class UserAccount {
  // --- Identitas login ---
  final String email;
  final String password;
  final String? googleEmail; // akun Google yang tertaut (jika ada)
  final String? facebookName; // akun Facebook yang tertaut (jika ada)

  // --- Profil (kosong sampai pengguna mengisi "Buat Profil") ---
  String name;
  String about;
  String education;
  String experience;

  // --- Data aplikasi ---
  final List<Course> courses;
  final List<Sale> sales;
  final List<IncomeTransaction> transactions;
  int balance;

  /// Pendapatan per bulan dalam JUTA rupiah. Kunci 'yyyy-MM', contoh
  /// '2026-10': 3.0. Bulan tanpa data dianggap 0. Dipakai Kartu Statistik.
  final Map<String, double> monthlyIncomeByMonth;

  UserAccount({
    required this.email,
    required this.password,
    this.googleEmail,
    this.facebookName,
    this.name = '',
    this.about = '',
    this.education = '',
    this.experience = '',
    List<Course>? courses,
    List<Sale>? sales,
    List<IncomeTransaction>? transactions,
    this.balance = 0,
    Map<String, double>? monthlyIncomeByMonth,
  })  : courses = List<Course>.of(courses ?? const []),
        sales = List<Sale>.of(sales ?? const []),
        transactions = List<IncomeTransaction>.of(transactions ?? const []),
        monthlyIncomeByMonth = Map<String, double>.of(
            monthlyIncomeByMonth ?? const <String, double>{});

  /// Profil dianggap lengkap bila keempat kolom Buat Profil terisi.
  bool get isProfileComplete =>
      name.trim().isNotEmpty &&
      about.trim().isNotEmpty &&
      education.trim().isNotEmpty &&
      experience.trim().isNotEmpty;

  /// Nama untuk ditampilkan; akun baru yang belum isi profil -> 'Pengguna Baru'.
  String get displayName => name.trim().isEmpty ? 'Pengguna Baru' : name.trim();

  static String monthKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  static DateTime? _parseMonthKey(String k) {
    final p = k.split('-');
    if (p.length != 2) return null;
    final y = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    if (y == null || m == null || m < 1 || m > 12) return null;
    return DateTime(y, m);
  }

  /// Pendapatan satu bulan (juta rupiah).
  double incomeOf(DateTime month) => monthlyIncomeByMonth[monthKey(month)] ?? 0;

  /// Tambah pendapatan (rupiah) ke bulan [when] (default: sekarang).
  void addMonthlyIncome(int rupiah, [DateTime? when]) {
    final key = monthKey(when ?? DateTime.now());
    monthlyIncomeByMonth[key] = (monthlyIncomeByMonth[key] ?? 0) + rupiah / 1000000;
  }

  /// Deret batang untuk Kartu Statistik, dari yang TERLAMA ke bulan berjalan.
  /// Minimal [minMonths] batang (bulan kosong = 0). Masuk bulan baru -> deret
  /// otomatis bertambah satu batang; bulan-bulan lama tetap bisa digeser.
  List<MonthlyIncomePoint> incomeSeries({DateTime? now, int minMonths = 6}) {
    final today = now ?? DateTime.now();
    var last = DateTime(today.year, today.month);
    DateTime? earliest;
    for (final k in monthlyIncomeByMonth.keys) {
      final m = _parseMonthKey(k);
      if (m == null) continue;
      if (earliest == null || m.isBefore(earliest)) earliest = m;
      if (m.isAfter(last)) last = m;
    }
    var first = DateTime(last.year, last.month - (minMonths - 1));
    if (earliest != null && earliest.isBefore(first)) first = earliest;

    final points = <MonthlyIncomePoint>[];
    for (var m = first; !m.isAfter(last); m = DateTime(m.year, m.month + 1)) {
      points.add(MonthlyIncomePoint(m, incomeOf(m)));
    }
    return points;
  }

  int get totalCourses => courses.length;

  int get totalStudents => courses.fold(0, (sum, c) => sum + c.students);
}
