import 'package:flutter/material.dart';
import '../constants/assets.dart';
import '../constants/colors.dart';

/// Navbar bawah: Beranda, Kursus, Keuangan, Profil.
/// Menu yang sedang dibuka berwarna MERAH (maroon), yang lain hitam.
class NexaBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NexaBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = <_NavItemData>[
    _NavItemData('Beranda', Icons.home_rounded, AppAssets.navBeranda),
    _NavItemData('Kursus', Icons.book_outlined, AppAssets.navKursus),
    _NavItemData(
        'Keuangan', Icons.account_balance_wallet_outlined, AppAssets.navKeuangan),
    _NavItemData('Profil', Icons.account_circle_rounded, AppAssets.navProfil),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: Color(0xFF9E9E9E), width: 0.6)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: _NavItem(
                    data: _items[i],
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final IconData icon; // cadangan kalau file PNG tidak ditemukan
  final String asset;
  const _NavItemData(this.label, this.icon, this.asset);
}

class _NavItem extends StatelessWidget {
  final _NavItemData data;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem(
      {required this.data, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : Colors.black;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            data.asset,
            width: 30,
            height: 30,
            color: AppAssets.navIconTint ? color : null,
            errorBuilder: (_, _, _) => Icon(data.icon, size: 30, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 9.5,
              fontWeight: selected ? FontWeight.w500 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
