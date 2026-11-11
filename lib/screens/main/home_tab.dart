import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/user_account.dart';
import '../../services/app_session.dart';
import '../../utils/format.dart';
import '../../widgets/course_tile.dart';
import '../../widgets/tap_scale.dart';
import '../../widgets/curved_header.dart';
import '../../widgets/empty_hint.dart';
import '../profile/course_detail_page.dart';

/// Tab Beranda. Akun Ignatius -> data terisi; akun baru -> kosong.
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSession.instance,
      builder: (context, _) {
        final user = AppSession.instance.userOrGuest;
        return Scaffold(
          backgroundColor: AppColors.white,
          body: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(user: user),
                const SizedBox(height: 22),
                const _SectionTitle('Penjualan Terbaru'),
                const SizedBox(height: 12),
                if (user.sales.isEmpty)
                  const EmptyHint(
                    icon: Icons.receipt_long_outlined,
                    text: 'Belum ada penjualan.\n'
                        'Penjualan kursus Anda akan muncul di sini.',
                  )
                else
                  for (final s in user.sales.take(2)) _SaleCard(sale: s),
                const SizedBox(height: 18),
                const _SectionTitle('Kursus Terbaru'),
                const SizedBox(height: 14),
                if (user.courses.isEmpty)
                  const EmptyHint(
                    icon: Icons.menu_book_outlined,
                    text: 'Belum ada kursus.\n'
                        'Buat kursus pertama Anda di menu Kursus.',
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: TapScale(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CourseDetailPage.forCourse(user.courses.first),
                        ),
                      ),
                      child: CourseTile(course: user.courses.first),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final UserAccount user;
  const _Header({required this.user});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).padding.top + 132 + 21,
      child: Stack(
        children: [
          CurvedHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greetingForNow(),
                  style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 13, color: Colors.white),
                ),
                Text(
                  user.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatCard(value: '${user.totalCourses}', label: 'Kursus'),
                const SizedBox(width: 12),
                _StatCard(value: '${user.totalStudents}', label: 'Peserta'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 118,
      height: 53,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 17,
                  height: 1.1,
                  fontWeight: FontWeight.w500,
                  color: Colors.black)),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  height: 1.2,
                  color: Colors.black)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 26),
        child: Text(text,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black)),
      );
}

class _SaleCard extends StatelessWidget {
  final Sale sale;
  const _SaleCard({required this.sale});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(22, 0, 22, 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary, width: 0.8),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sale.buyer,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black)),
                Text(sale.courseTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Color(0xFF8A8A8A))),
                Text(sale.timeAgo,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Color(0xFF8A8A8A))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
