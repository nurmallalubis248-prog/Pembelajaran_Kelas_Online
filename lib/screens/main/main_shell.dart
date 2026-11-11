import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/colors.dart';
import '../../widgets/nexa_bottom_nav.dart';
import 'courses_tab.dart';
import 'finance_tab.dart';
import 'home_tab.dart';
import 'profile_tab.dart';

/// Kerangka utama setelah login: 4 tab + navbar bawah.
/// Isi tiap tab otomatis mengikuti akun yang sedang masuk (AppSession).
class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;

  // Tab Keuangan berlatar putih -> ikon status bar gelap; lainnya terang.
  bool get _lightStatusIcons => _index != 2;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        // Tombol back di tab selain Beranda -> kembali ke Beranda dulu.
        if (!didPop) setState(() => _index = 0);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              _lightStatusIcons ? Brightness.light : Brightness.dark,
          statusBarBrightness:
              _lightStatusIcons ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: AppColors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: AppColors.white,
          body: IndexedStack(
            index: _index,
            children: const [
              HomeTab(),
              CoursesTab(),
              FinanceTab(),
              ProfileTab(),
            ],
          ),
          bottomNavigationBar: NexaBottomNav(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
          ),
        ),
      ),
    );
  }
}
