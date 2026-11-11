import 'dart:math' as math;

import 'package:flutter/material.dart';

const Color _kStar = Color(0xFFFFC800);

/// Rating 1-5 bintang yang bisa diketuk. Saat bintang dipilih, bintang yang
/// terisi memantul berurutan dan memancarkan kilau (sparkle).
///
/// [value] = rating pengguna saat ini (0 = belum menilai).
/// [onChanged] dipanggil dengan bintang 1..5 yang diketuk.
class SparkleStarRating extends StatefulWidget {
  const SparkleStarRating({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 34,
    this.enabled = true,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final double size;
  final bool enabled;

  @override
  State<SparkleStarRating> createState() => _SparkleStarRatingState();
}

class _SparkleStarRatingState extends State<SparkleStarRating>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  int _burstIndex = -1; // bintang yang baru diketuk

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _tap(int i) {
    if (!widget.enabled) return;
    setState(() => _burstIndex = i);
    _c.forward(from: 0);
    widget.onChanged(i + 1);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 5; i++)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _tap(i),
                child: SizedBox(
                  width: s + 8,
                  height: s + 8,
                  child: CustomPaint(
                    foregroundPainter: i <= _burstIndex && _c.isAnimating
                        ? _SparklePainter(
                            progress: _c.value,
                            // bintang paling kanan yang diketuk memancar penuh,
                            // bintang sebelumnya menyusul dengan jeda kecil
                            delay: (_burstIndex - i) * .08,
                            strong: i == _burstIndex,
                          )
                        : null,
                    child: Center(child: _star(i)),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _star(int i) {
    final filled = i < widget.value;
    double scale = 1;
    if (_c.isAnimating && i <= _burstIndex) {
      // pantulan berurutan: bintang kiri duluan
      final local = ((_c.value - i * .06) / .5).clamp(0.0, 1.0);
      scale = 1 + .35 * math.sin(local * math.pi);
    }
    return Transform.scale(
      scale: scale,
      child: Icon(
        filled ? Icons.star_rounded : Icons.star_outline_rounded,
        size: widget.size,
        color: filled ? _kStar : Colors.black26,
        shadows: filled && _c.isAnimating && i <= _burstIndex
            ? [
                Shadow(
                    color: _kStar.withValues(alpha: .8),
                    blurRadius: 14 * (1 - _c.value))
              ]
            : null,
      ),
    );
  }
}

/// Kilau empat sudut yang melesat keluar dari pusat bintang lalu memudar.
class _SparklePainter extends CustomPainter {
  _SparklePainter({
    required this.progress,
    required this.delay,
    required this.strong,
  });

  final double progress;
  final double delay;
  final bool strong;

  @override
  void paint(Canvas canvas, Size size) {
    final t = ((progress - delay) / (1 - delay)).clamp(0.0, 1.0);
    if (t <= 0 || t >= 1) return;
    final center = size.center(Offset.zero);
    final count = strong ? 8 : 4;
    final fade = 1 - Curves.easeIn.transform(t);
    final dist = size.width * (.35 + .55 * Curves.easeOut.transform(t));
    final paint = Paint()..color = _kStar.withValues(alpha: fade);

    for (var k = 0; k < count; k++) {
      final a = (k / count) * 2 * math.pi + (strong ? 0.3 : 0.8);
      final p = center + Offset(math.cos(a), math.sin(a)) * dist;
      final r = (strong ? 4.2 : 3.0) * (1 - .5 * t);
      _diamond(canvas, p, r, paint);
    }
  }

  /// Bentuk kilau: belah ketupat tipis (4 sudut).
  void _diamond(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path()
      ..moveTo(c.dx, c.dy - r * 1.6)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r * 1.6, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r * 1.6)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r * 1.6, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r * 1.6)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.progress != progress;
}
