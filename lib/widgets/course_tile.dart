import 'dart:io';

import 'package:flutter/material.dart';
import '../models/user_account.dart';
import '../services/app_session.dart';
import '../utils/format.dart';

/// Satu baris kursus: gambar, judul, instruktur, bintang, harga.
class CourseTile extends StatelessWidget {
  final Course course;
  final int colorIndex;

  const CourseTile({super.key, required this.course, this.colorIndex = 0});

  static const _thumbColors = [
    Color(0xFF4E8B63), // hijau (Excel)
    Color(0xFF2F5D9E), // biru (Word)
    Color(0xFF8B5E3C),
    Color(0xFF6B4E9B),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Thumb(course: course, color: _thumbColors[colorIndex % _thumbColors.length]),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
              Text(
                course.instructor,
                style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 12, color: Colors.grey),
              ),
              _LiveStars(course: course),
              Text(
                course.price == 0 ? 'Gratis' : formatRupiah(course.price),
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Bintang di daftar kursus. Ikut berubah begitu pengguna menilai di halaman
/// detail (nilai rata-rata disimpan di AppSession), jadi selalu sama dengan
/// halaman detail. Kursus contoh Figma tetap memakai rating bawaannya.
class _LiveStars extends StatelessWidget {
  final Course course;
  const _LiveStars({required this.course});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: AppSession.instance,
        builder: (context, _) => _Stars(
          rating: course.id == 'seed-excel-1'
              ? course.rating
              : AppSession.instance.ratingFor(course),
        ),
      );
}

class _Stars extends StatelessWidget {
  final double rating;
  const _Stars({required this.rating});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFC107);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        IconData icon;
        if (rating >= i + 1) {
          icon = Icons.star_rounded;
        } else if (rating >= i + 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_outline_rounded;
        }
        return Icon(icon, size: 20, color: gold);
      }),
    );
  }
}

/// Gambar sampul kursus (dari assets). Jika file tidak ditemukan,
/// tampil kotak berwarna berisi judul supaya aplikasi tidak error.
class _Thumb extends StatelessWidget {
  final Course course;
  final Color color;
  const _Thumb({required this.course, required this.color});

  Widget _fallback() => Container(
        width: 70,
        height: 70,
        padding: const EdgeInsets.all(5),
        alignment: Alignment.centerLeft,
        color: color,
        child: Text(
          course.title.toUpperCase(),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 9,
            height: 1.25,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final path = course.thumbnail;
    if (path == null) return _fallback();
    // 'assets/...' = gambar bawaan aplikasi; selain itu = file sampul yang
    // dipilih pengguna saat upload kursus.
    final isAsset = path.startsWith('assets/');
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: isAsset
          ? Image.asset(
              path,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _fallback(),
            )
          : Image.file(
              File(path),
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _fallback(),
            ),
    );
  }
}
