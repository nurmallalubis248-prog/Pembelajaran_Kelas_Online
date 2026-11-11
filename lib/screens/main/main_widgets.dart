import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../state/app_session.dart';

String _group(int v) {
  final s = v.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return b.toString();
}

String rupiah(int v) => 'Rp. ${_group(v)}';
String rupiahPlus(int v) => '+Rp${_group(v)}';

TextStyle poppins(double size,
        {FontWeight w = FontWeight.w400, Color color = Colors.black, double? height}) =>
    TextStyle(fontFamily: 'Poppins', fontSize: size, fontWeight: w, color: color, height: height);

/// Muncul pelan + naik sedikit (animasi ala web). [delayMs] untuk berurutan.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int delayMs;
  const FadeSlideIn({super.key, required this.child, this.delayMs = 0});

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
  late final Animation<double> _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
  late final Animation<Offset> _slide =
      Tween<Offset>(begin: const Offset(0, .12), end: Offset.zero)
          .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child),
      );
}

/// Header merah dengan sudut bawah melengkung (Beranda, Kursus, History).
class CurvedHeader extends StatelessWidget {
  final double height;
  final Widget child;
  const CurvedHeader({super.key, required this.height, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        height: height,
        padding: EdgeInsets.fromLTRB(26, MediaQuery.of(context).padding.top + 18, 26, 0),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(90),
            bottomRight: Radius.circular(90),
          ),
        ),
        child: child,
      );
}

class StarRow extends StatelessWidget {
  final int count;
  const StarRow({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          5,
          (i) => Icon(Icons.star_rounded,
              size: 22, color: i < count ? const Color(0xFFFFD60A) : Colors.black12),
        ),
      );
}

class CourseTile extends StatelessWidget {
  final CourseItem course;
  const CourseTile({super.key, required this.course});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(course.cover, width: 72, height: 72, fit: BoxFit.cover),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.title, style: poppins(14.5, w: FontWeight.w500)),
                  Text(course.instructor,
                      style: poppins(12.5, color: Colors.black45)),
                  StarRow(count: course.rating),
                  Text(rupiah(course.price), style: poppins(15, w: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      );
}

class EmptyNote extends StatelessWidget {
  final IconData icon;
  final String text;
  const EmptyNote({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE9D3D5)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: AppColors.fieldBorder),
            const SizedBox(height: 8),
            Text(text,
                textAlign: TextAlign.center,
                style: poppins(12, color: Colors.black54, height: 1.5)),
          ],
        ),
      );
}
