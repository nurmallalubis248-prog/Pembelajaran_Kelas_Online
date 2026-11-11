import 'package:flutter/material.dart';
import '../../constants/colors.dart';

// Warna utama memakai AppColors milik proyekmu, jadi tidak berubah.
const Color kMaroon = AppColors.primary;
const Color kFieldBorder = Color(0xFFB9A8E8); // ganti jika di Figma beda
const Color kTextDark = Color(0xFF222222);
const String kFont = 'Poppins';

TextStyle nexaText(double size,
        {FontWeight weight = FontWeight.w400, Color color = kTextDark}) =>
    TextStyle(fontFamily: kFont, fontSize: size, fontWeight: weight, color: color);
