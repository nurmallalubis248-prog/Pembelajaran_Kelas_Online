import 'package:flutter/material.dart';

/// Efek tekan: widget mengecil sedikit saat disentuh lalu memantul kembali.
///
/// Memakai [Listener] (event sentuhan mentah) sehingga TIDAK bersaing dengan
/// tombol di dalamnya. Jadi aman membungkus ElevatedButton / InkWell yang
/// sudah punya onPressed sendiri:
///
///   TapScale(child: ElevatedButton(onPressed: ..., child: ...))
///
/// [onTap] opsional: isi bila child belum punya aksi sendiri (mis. kartu).
class TapScale extends StatefulWidget {
  const TapScale({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.95,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v && mounted) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final inner = widget.onTap == null
        ? widget.child
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            child: widget.child,
          );
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down ? widget.pressedScale : 1,
        duration: Duration(milliseconds: _down ? 90 : 220),
        curve: _down ? Curves.easeOut : Curves.easeOutBack,
        child: inner,
      ),
    );
  }
}
