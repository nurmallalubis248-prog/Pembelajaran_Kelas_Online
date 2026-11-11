import 'package:flutter/foundation.dart';
import '../services/app_session.dart';

class IncomeItem {
  final String title;
  final String buyer;
  final int amount;
  final DateTime date;

  IncomeItem({
    required this.title,
    required this.buyer,
    required this.amount,
    required this.date,
  });
}

class WithdrawalItem {
  final String title;
  final String recipient;
  final int amount;
  final DateTime date;

  /// Metode tujuan (DANA, dll), nomor rekening/e-wallet, dan ID transaksi
  /// dipakai oleh halaman History Ringkasan.
  final String method;
  final String accountNumber;
  final String id;

  WithdrawalItem({
    required this.title,
    required this.recipient,
    required this.amount,
    required this.date,
    this.method = 'DANA',
    this.accountNumber = '0123456789',
    String? id,
  }) : id = id ?? _generateId(date);

  /// Nomor tujuan disamarkan: tersisa 3 digit terakhir, contoh *******789.
  String get maskedAccount {
    final n = accountNumber;
    final tail = n.length <= 3 ? n : n.substring(n.length - 3);
    return '*******$tail';
  }

  static String _generateId(DateTime d) {
    final ts = d.microsecondsSinceEpoch.toRadixString(16);
    final salt = (DateTime.now().microsecondsSinceEpoch * 7919)
        .toRadixString(16);
    return (ts + salt).padRight(24, '0').substring(0, 24);
  }
}

/// Data keuangan satu akun.
class _AccountData {
  final List<IncomeItem> incomes;
  final List<WithdrawalItem> withdrawals;
  _AccountData({
    List<IncomeItem>? incomes,
    List<WithdrawalItem>? withdrawals,
  })  : incomes = incomes ?? [],
        withdrawals = withdrawals ?? [];
}

class FinanceService extends ChangeNotifier {
  static final FinanceService instance = FinanceService._();
  FinanceService._();

  static const int adminFee = 2500;

  /// Akun contoh dari desain Figma. Hanya akun dengan email ini yang
  /// diisi riwayat contoh. Akun lain (akun baru) mulai KOSONG.
  static const String _demoAccount = 'Ignatius Ryan';

  /// Akun aktif selalu mengikuti AppSession (login / daftar / log out),
  /// jadi tidak perlu lagi memanggil loadForAccount.
  String get _accountKey =>
      AppSession.instance.userOrGuest.email.trim().toLowerCase();

  String get accountName => AppSession.instance.userOrGuest.displayName;

  final Map<String, _AccountData> _accounts = {};

  _AccountData get _data =>
      _accounts.putIfAbsent(_accountKey, () => _createFor(_accountKey));

  _AccountData _createFor(String key) {
    if (key != AppSession.demoEmail) return _AccountData(); // akun baru: kosong
    return _AccountData(
      incomes: _demoIncomes(),
      withdrawals: _demoWithdrawals(),
    );
  }

  /// Hapus semua riwayat pendapatan & penarikan (data uji coba).
  void resetAll() {
    _accounts.clear();
    notifyListeners();
  }

  /// Dipertahankan agar kode lama tetap jalan. Tidak perlu dipanggil lagi.
  void loadForAccount([String? accountName]) => notifyListeners();

  /// SATU sumber saldo: saldo akun di AppSession. Dipakai Keuangan, Tarik Dana,
  /// dan layar lain, jadi semuanya selalu sama.
  int get balance => AppSession.instance.userOrGuest.balance;

  List<IncomeItem> get incomes => List.unmodifiable(_data.incomes);
  List<WithdrawalItem> get withdrawals => List.unmodifiable(_data.withdrawals);

  bool processWithdrawal({
    required int amount,
    required String method,
    required String accountNumber,
    required String pin,
  }) {
    final d = _data;
    if (amount <= 0 || amount + adminFee > balance) {
      debugPrint('[TARIK] ditolak: nominal=$amount saldo=$balance');
      return false;
    }

    // Potong saldo akun (Keuangan & layar lain ikut berubah otomatis).
    if (!AppSession.instance.deductBalance(amount + adminFee)) {
      debugPrint('[TARIK] gagal memotong saldo (akun belum login?)');
      return false;
    }
    d.withdrawals.add(
      WithdrawalItem(
        title: 'Penarikan $method',
        recipient: accountName,
        amount: amount,
        date: DateTime.now(),
        method: method,
        accountNumber: accountNumber,
      ),
    );

    debugPrint('[TARIK] tersimpan. akun=$_accountKey '
        'jumlahRiwayat=${d.withdrawals.length} saldo=$balance');
    notifyListeners();
    return true;
  }

  /// Catat penjualan kursus ke akun aktif. SATU pintu untuk semua layar:
  /// saldo, Riwayat pendapatan, daftar "Lihat semua", dan Kartu Statistik
  /// (batang bulan berjalan) ikut ter-update.
  bool recordSale({
    required String courseTitle,
    required String buyer,
    required int amount,
    DateTime? when,
  }) {
    final d = when ?? DateTime.now();
    final ok = AppSession.instance.recordSale(
      courseTitle: courseTitle,
      buyer: buyer,
      amount: amount,
      when: d,
    );
    if (!ok) return false;
    _data.incomes.add(
      IncomeItem(
        title: 'Penjualan: $courseTitle',
        buyer: buyer,
        amount: amount,
        date: d,
      ),
    );
    notifyListeners();
    return true;
  }

  // ====== Data contoh (hanya untuk akun contoh Figma) ======
  List<IncomeItem> _demoIncomes() => [
    IncomeItem(
      title: 'Penjualan: Excel',
      buyer: 'Sania',
      amount: 60000,
      date: DateTime(2026, 10, 13),
    ),
    IncomeItem(
      title: 'Penjualan: Excel',
      buyer: 'Nurmala',
      amount: 60000,
      date: DateTime(2026, 10, 19),
    ),
    IncomeItem(
      title: 'Penjualan: Excel',
      buyer: 'Nurmala',
      amount: 60000,
      date: DateTime(2026, 10, 20),
    ),
    IncomeItem(
      title: 'Penjualan: Excel',
      buyer: 'Syfa',
      amount: 60000,
      date: DateTime(2026, 11, 1),
    ),
    IncomeItem(
      title: 'Penjualan: Excel',
      buyer: 'Syfa',
      amount: 60000,
      date: DateTime(2026, 11, 11),
    ),
    IncomeItem(
      title: 'Penjualan: Excel',
      buyer: 'Nurlela',
      amount: 60000,
      date: DateTime(2026, 11, 13),
    ),
    IncomeItem(
      title: 'Penjualan: Excel',
      buyer: 'Sania',
      amount: 60000,
      date: DateTime(2026, 11, 23),
    ),
    IncomeItem(
      title: 'Penjualan: Excel',
      buyer: 'Elfira',
      amount: 60000,
      date: DateTime(2026, 11, 29),
    ),
    IncomeItem(
      title: 'Penjualan: Excel',
      buyer: 'Elfira',
      amount: 60000,
      date: DateTime(2026, 12, 13),
    ),
    IncomeItem(
      title: 'Penjualan: Excel',
      buyer: 'Syfa',
      amount: 60000,
      date: DateTime(2026, 12, 20),
    ),
  ];

  List<WithdrawalItem> _demoWithdrawals() => [
    WithdrawalItem(
      title: 'Penarikan DANA',
      recipient: _demoAccount,
      amount: 80000,
      date: DateTime(2026, 9, 5, 12, 0),
      accountNumber: '0123456789',
      id: '676bc0ae84db444bea903345',
    ),
    WithdrawalItem(
      title: 'Penarikan DANA',
      recipient: _demoAccount,
      amount: 80000,
      date: DateTime(2026, 10, 7, 7, 40),
      accountNumber: '0123456789',
      id: '6a324021ba74de6ff427853f',
    ),
    WithdrawalItem(
      title: 'Penarikan DANA',
      recipient: _demoAccount,
      amount: 200000,
      date: DateTime(2026, 10, 19, 19, 50),
      accountNumber: '0123456789',
      id: '6731a10116967cff400fd593',
    ),
    WithdrawalItem(
      title: 'Penarikan DANA',
      recipient: _demoAccount,
      amount: 30000,
      date: DateTime(2026, 11, 5, 8, 0),
      accountNumber: '0123456789',
      id: '66d85712a52872311e96a801',
    ),
    WithdrawalItem(
      title: 'Penarikan DANA',
      recipient: _demoAccount,
      amount: 30000,
      date: DateTime(2026, 11, 9, 12, 50),
      accountNumber: '0123456789',
      id: '2826kc0ie74db889ced903395',
    ),
    WithdrawalItem(
      title: 'Penarikan DANA',
      recipient: _demoAccount,
      amount: 200000,
      date: DateTime(2026, 12, 3, 12, 0),
      accountNumber: '0123456789',
      id: '56hikc0ae89db444bea889775',
    ),
  ];
}