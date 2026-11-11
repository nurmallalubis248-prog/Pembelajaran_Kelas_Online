import 'package:flutter/material.dart';
import '../constants/assets.dart';
import '../widgets/tap_scale.dart';

/// ====== WARNA, FONT, ASSET ======
class NexaColors {
  static const maroon = Color(0xFF8B0E12);
  static const green = Color(0xFF2ECC71);
  static const greenSoft = Color(0xFFB4EBC4);
  static const red = Color(0xFFFF3B30);
  static const danaBlue = Color(0xFF118EEA);
  static const border = Color(0xFF9E9E9E);
}

class NexaAssets {
  /// Ganti sesuai nama file logo DANA di folder assets kamu.
  static const dana = 'assets/images/dana.png';
}

const String kFont = 'Poppins'; // pastikan sudah didaftarkan di pubspec.yaml

TextStyle nexaText(double size,
        {FontWeight weight = FontWeight.w400, Color color = Colors.black, double? height}) =>
    TextStyle(fontFamily: kFont, fontSize: size, fontWeight: weight, color: color, height: height);

/// ====== FORMAT ======
String fmtNumber(int v) {
  final s = v.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return b.toString();
}

String rp(int v) => 'Rp ${fmtNumber(v)}';
String rpDot(int v) => 'Rp. ${fmtNumber(v)}';

const _bulan = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
];
const _bulanPendek = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
];

String fmtDateShort(DateTime d) => '${d.day} ${_bulanPendek[d.month - 1]}';
String fmtDateLong(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';
String fmtTime(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}.${d.minute.toString().padLeft(2, '0')}';

/// ====== WIDGET UMUM ======
class DanaLogo extends StatelessWidget {
  final double size;
  const DanaLogo({super.key, this.size = 60});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.asset(
        NexaAssets.dana,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          width: size,
          height: size,
          color: NexaColors.danaBlue,
          alignment: Alignment.center,
          child: Text('DANA', style: nexaText(size * 0.2, weight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    );
  }
}

class SaldoCard extends StatelessWidget {
  final int saldo;
  const SaldoCard({super.key, required this.saldo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 24, 26, 28),
      decoration: BoxDecoration(color: NexaColors.maroon, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Saldo Tersedia', style: nexaText(13, weight: FontWeight.w500, color: Colors.white)),
          const SizedBox(height: 8),
          Text(rpDot(saldo), style: nexaText(32, weight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const PrimaryButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TapScale(
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: NexaColors.maroon,
            disabledBackgroundColor: NexaColors.maroon.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: Text(label, style: nexaText(15, weight: FontWeight.w500, color: Colors.white)),
        ),
      ),
    );
  }
}

/// Navbar 4 tab: tab aktif MERAH, lainnya hitam.
/// Kalau sudah punya navbar sendiri, pakai itu dan hapus ini.
class NexaBottomNav extends StatelessWidget {
  final int currentIndex; // 0 Beranda, 1 Kursus, 2 Keuangan, 3 Profil
  final ValueChanged<int>? onTap;
  const NexaBottomNav({super.key, required this.currentIndex, this.onTap});

  static const _items = [
    (Icons.home_rounded, 'Beranda', AppAssets.navBeranda),
    (Icons.menu_book_rounded, 'Kursus', AppAssets.navKursus),
    (Icons.account_balance_wallet_outlined, 'Keuangan', AppAssets.navKeuangan),
    (Icons.account_circle, 'Profil', AppAssets.navProfil),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black87, width: 0.8)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(_items.length, (i) {
              final active = i == currentIndex;
              final color = active ? NexaColors.maroon : Colors.black;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap?.call(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        _items[i].$3,
                        width: 28,
                        height: 28,
                        color: AppAssets.navIconTint ? color : null,
                        errorBuilder: (_, _, _) =>
                            Icon(_items[i].$1, size: 28, color: color),
                      ),
                      const SizedBox(height: 2),
                      Text(_items[i].$2, style: nexaText(10, weight: FontWeight.w500, color: color)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
