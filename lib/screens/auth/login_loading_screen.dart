import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../constants/colors.dart';
import '../../widgets/please_wait_text.dart';

enum LoginMethod { email, google, facebook }

/// Layar loading login (3 varian teks sesuai desain).
/// Setelah [duration], pindah ke [nextRoute] (default: Home).
class LoginLoadingScreen extends StatefulWidget {
  final LoginMethod method;
  final Duration duration;
  final String nextRoute;

  const LoginLoadingScreen({
    super.key,
    this.method = LoginMethod.email,
    this.duration = const Duration(seconds: 2),
    this.nextRoute = AppRoutes.home,
  });

  @override
  State<LoginLoadingScreen> createState() => _LoginLoadingScreenState();
}

class _LoginLoadingScreenState extends State<LoginLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))
        ..repeat();

  String get _text {
    switch (widget.method) {
      case LoginMethod.google:
        return 'Sedang masuk menggunakan\nakun Google anda';
      case LoginMethod.facebook:
        return 'Sedang masuk menggunakan\nakun Facebook anda';
      case LoginMethod.email:
        return 'Sedang masuk, harap tunggu...';
    }
  }

  @override
  void initState() {
    super.initState();
    // GANTI dengan proses login nyata (API/Firebase) bila sudah ada.
    Future.delayed(widget.duration, () {
      if (!mounted) return;
      Navigator.of(context)
          .pushNamedAndRemoveUntil(widget.nextRoute, (route) => false);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RotationTransition(
              turns: _c,
              child: const CustomPaint(
                size: Size(80, 80),
                painter: _GradientRingPainter(),
              ),
            ),
            const SizedBox(height: 48),
            if (widget.method == LoginMethod.email)
              PleaseWaitText(
                  text: 'Sedang masuk, harap tunggu',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textDark))
            else
              Text(_text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textDark)),
          ],
        ),
      ),
    );
  }
}

class _GradientRingPainter extends CustomPainter {
  const _GradientRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 6.0;
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        // ekor memudar -> kepala pekat di ujung (searah jarum jam)
        colors: [AppColors.primary.withValues(alpha: 0.0), AppColors.primary],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);
    canvas.drawArc(rect.deflate(stroke / 2), -math.pi / 2, math.pi * 2 * 0.92,
        false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}