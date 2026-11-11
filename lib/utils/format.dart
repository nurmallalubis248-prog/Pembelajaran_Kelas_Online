/// 60000 -> '60.000'
String formatThousands(int value) {
  final s = value.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return value < 0 ? '-$buf' : buf.toString();
}

/// 60000 -> 'Rp. 60.000'
String formatRupiah(int value) => 'Rp. ${formatThousands(value)}';

/// Sapaan sesuai jam: Pagi / Siang / Sore / Malam.
String greetingForNow([DateTime? now]) {
  final h = (now ?? DateTime.now()).hour;
  if (h >= 4 && h < 11) return 'Selamat Pagi,';
  if (h >= 11 && h < 15) return 'Selamat Siang,';
  if (h >= 15 && h < 18) return 'Selamat Sore,';
  return 'Selamat Malam,';
}

const List<String> _shortMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

/// 1..12 -> 'Jan'..'Des'
String shortMonthName(int month) => _shortMonths[month - 1];
