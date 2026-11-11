import 'package:flutter/material.dart';

// PENTING: ganti nilai di bawah dengan warna/font PERSIS dari Figma atau dari
// konstanta yang sudah ada di proyekmu. Jika sudah punya file tema/warna,
// hapus file ini dan ubah import di 3 file lain ke file milikmu.
const Color kMaroon = Color(0xFF7B0D2E);
const Color kFieldBorder = Color(0xFFB9A8E8);
const Color kTextDark = Color(0xFF222222);
const String kFont = 'Poppins';

TextStyle nexaText(double size,
        {FontWeight weight = FontWeight.w400, Color color = kTextDark}) =>
    TextStyle(fontFamily: kFont, fontSize: size, fontWeight: weight, color: color);
