import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../state/app_session.dart';
import '../additional_frames.dart';
import 'main_widgets.dart';

class CourseTab extends StatelessWidget {
  const CourseTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSession.instance,
      builder: (context, _) {
        final s = AppSession.instance;
        return Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CurvedHeader(
                  height: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kursus Saya',
                          style: poppins(21, w: FontWeight.w600, color: Colors.white)),
                      Text('${s.courses.length} Kursus  -  ${s.students} peserta',
                          style: poppins(11, color: Colors.white)),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 26, 24, 90),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Semua Kursus',
                            style: poppins(20, w: FontWeight.w600, color: AppColors.primary)),
                        const SizedBox(height: 18),
                        if (s.courses.isEmpty)
                          const FadeSlideIn(
                            child: EmptyNote(
                              icon: Icons.menu_book_outlined,
                              text: 'Kamu belum punya kursus.\nTekan "+ Buat Kursus" untuk memulai.',
                            ),
                          )
                        else
                          for (var i = 0; i < s.courses.length; i++)
                            FadeSlideIn(
                              delayMs: i * 90,
                              child: CourseTile(course: s.courses[i]),
                            ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 20,
              bottom: 18,
              child: FadeSlideIn(
                delayMs: 250,
                child: Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => nexaPush(context, const NexaCreateCourseScreen()),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Text('+ Buat Kursus',
                          style: poppins(15, w: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
