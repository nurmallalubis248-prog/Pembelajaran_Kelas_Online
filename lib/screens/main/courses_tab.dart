import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../services/app_session.dart';
import '../../widgets/course_tile.dart';
import '../../widgets/tap_scale.dart';
import '../../widgets/curved_header.dart';
import '../../widgets/empty_hint.dart';
import '../profile/course_detail_page.dart';
import '../profile/create_course_page.dart';

/// Tab Kursus ("Kursus Saya").
class CoursesTab extends StatelessWidget {
  const CoursesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSession.instance,
      builder: (context, _) {
        final user = AppSession.instance.userOrGuest;
        return Scaffold(
          backgroundColor: AppColors.white,
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CurvedHeader(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Kursus  Saya',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white)),
                          Text(
                            '${user.totalCourses} Kursus  -  '
                            '${user.totalStudents} peserta',
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Padding(
                      padding: EdgeInsets.only(left: 26),
                      child: Text('Semua Kursus',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary)),
                    ),
                    const SizedBox(height: 16),
                    if (user.courses.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: EmptyHint(
                          icon: Icons.menu_book_outlined,
                          text: 'Anda belum membuat kursus.\n'
                              'Ketuk "+ Buat Kursus" untuk memulai.',
                        ),
                      )
                    else
                      for (var i = 0; i < user.courses.length; i++)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 22, 18),
                          child: TapScale(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CourseDetailPage.forCourse(user.courses[i]),
                              ),
                            ),
                            child: CourseTile(
                                course: user.courses[i], colorIndex: i),
                          ),
                        ),
                    const SizedBox(height: 90), // ruang untuk tombol melayang
                  ],
                ),
              ),
              Positioned(
                right: 20,
                bottom: 16,
                child: TapScale(
                  child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateCoursePage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('+ Buat Kursus',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
