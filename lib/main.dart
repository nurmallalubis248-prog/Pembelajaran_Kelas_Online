import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants/colors.dart';
import 'routes/app_routes.dart';
import 'screens/main/main_shell.dart';
import 'screens/auth/account_confirmed_screen.dart';
import 'screens/profile/create_profile_screen.dart';
import 'screens/profile/profile_confirmed_screen.dart';
import 'screens/splash_screen.dart';
import 'finance/pendapatan_page.dart';
import 'widgets/nexa_keyboard.dart';
import 'services/test_data_reset.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Bersihkan sisa data uji coba dari sesi sebelumnya (kursus, rating, video).
  await TestDataReset.clearPersisted();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeXa - Marketplace Pembelajaran',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        primaryColor: AppColors.primaryMaroon,
        scaffoldBackgroundColor: AppColors.primaryMaroon,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryMaroon,
          primary: AppColors.primaryMaroon,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      // Keyboard kustom NeXa: dipasang sekali di atas Navigator
      builder: (context, child) =>
          NexaKeyboardHost(child: child ?? const SizedBox.shrink()),
      // Kembali ke tampilan awal (SplashScreen)
      home: const SplashScreen(),
      routes: {
        AppRoutes.accountConfirmed: (_) => const AccountConfirmedScreen(),
        AppRoutes.createProfile: (_) => const CreateProfileScreen(),
        AppRoutes.profileConfirmed: (_) => const ProfileConfirmedScreen(),
        AppRoutes.home: (_) => const MainShell(),
        // Rute untuk berpindah ke halaman keuangan
        '/finance': (_) => const PendapatanPage(),
      },
    );
  }
}