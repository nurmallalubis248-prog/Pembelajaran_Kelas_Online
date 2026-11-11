import 'package:flutter/material.dart';

/// Teks indikator loading tersendiri: "Harap tunggu..." dengan titik-titik
/// yang bergerak. Dipakai di layar loading (login, upload, penarikan dana).
class PleaseWaitText extends StatefulWidget {
  const PleaseWaitText({
    super.key,
    this.text = 'Harap tunggu',
    this.style,
  });

  final String text;
  final TextStyle? style;

  @override
  State<PleaseWaitText> createState() => _PleaseWaitTextState();
}

class _PleaseWaitTextState extends State<PleaseWaitText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ??
        const TextStyle(
            fontFamily: 'Poppins', fontSize: 15, color: Color(0xFF6B6B6B));
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final dots = (_c.value * 4).floor() % 4; // 0..3 titik
        // Titik yang belum muncul tetap memakan ruang (transparan) agar
        // teks tidak bergeser-geser.
        return Text.rich(
          TextSpan(style: style, children: [
            TextSpan(text: widget.text),
            TextSpan(text: '.' * dots),
            TextSpan(
                text: '.' * (3 - dots),
                style: const TextStyle(color: Colors.transparent)),
          ]),
          textAlign: TextAlign.center,
        );
      },
    );
  }
}
