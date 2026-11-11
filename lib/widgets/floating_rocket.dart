import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Roket melayang halus naik-turun (TANPA rotasi) dengan cahaya lembut yang
/// berdenyut (pulse glow) di belakangnya.
///
/// Aset default: assets/icons/roket_status.png (roket putih, badan transparan,
/// jadi warna kartu / cahaya tembus seperti di desain Figma).
///
/// [size] = ukuran kotak gambar. Widget ini hanya memakan ruang [size] x [size];
/// cahaya boleh meluap keluar kotak (tidak mendorong layout).
///
///   const FloatingRocket(size: 107, glowColor: Colors.white)
class FloatingRocket extends StatefulWidget {
  const FloatingRocket({
    super.key,
    this.size = 96,
    this.asset = 'assets/icons/roket_status.png',
    this.glowColor = const Color(0xFF800E13),
    this.travel = 7, // jarak naik/turun (dp) dari titik tengah
  });

  final double size;
  final String asset;
  final Color glowColor;
  final double travel;

  @override
  State<FloatingRocket> createState() => _FloatingRocketState();
}

class _FloatingRocketState extends State<FloatingRocket>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = Curves.easeInOutSine.transform(_c.value); // 0..1
          final dy = (t - .5) * 2 * widget.travel; // -travel..+travel
          final glow = .5 + .5 * math.sin(_c.value * math.pi); // 0..1
          final d = widget.size * (1.25 + .35 * glow);
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Cahaya lembut di belakang (denyut: ukuran + opasitas).
              Positioned.fill(
                child: OverflowBox(
                  minWidth: 0,
                  minHeight: 0,
                  maxWidth: double.infinity,
                  maxHeight: double.infinity,
                  child: Container(
                    width: d,
                    height: d,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        widget.glowColor.withValues(alpha: .10 + .22 * glow),
                        widget.glowColor.withValues(alpha: 0),
                      ]),
                    ),
                  ),
                ),
              ),
              // Hanya translasi vertikal: tidak ada rotasi.
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(0, -dy),
                  child: Image.asset(
                    widget.asset,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, _, _) => Icon(Icons.rocket_launch,
                        size: widget.size * .9, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
