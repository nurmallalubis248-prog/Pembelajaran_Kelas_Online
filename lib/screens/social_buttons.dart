import 'package:flutter/material.dart';

import 'header_maroon.dart';

/// Baris "Daftar dengan: (G) (f)".
///
/// Kalau gambar tidak ketemu, tombol menampilkan huruf cadangan (G / f) dan
/// path yang salah dicetak di Debug Console, jadi mudah dicari penyebabnya.
class BarisLoginSosial extends StatelessWidget {
  const BarisLoginSosial({
    super.key,
    this.googleAsset = 'assets/icons/google.png',
    this.facebookAsset = 'assets/icons/facebook.png',
    this.onGoogle,
    this.onFacebook,
  });

  final String googleAsset;
  final String facebookAsset;
  final VoidCallback? onGoogle;
  final VoidCallback? onFacebook;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TombolSosial(asset: googleAsset, cadangan: 'G', onTap: onGoogle),
        const SizedBox(width: 18),
        TombolSosial(asset: facebookAsset, cadangan: 'f', onTap: onFacebook),
      ],
    );
  }
}

class TombolSosial extends StatelessWidget {
  const TombolSosial({
    super.key,
    required this.asset,
    required this.cadangan,
    this.onTap,
    this.ukuran = 46,
  });

  final String asset;
  final String cadangan;
  final VoidCallback? onTap;
  final double ukuran;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: ukuran,
        height: ukuran,
        decoration: const BoxDecoration(color: kMaroon, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Image.asset(
            asset,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stack) {
              debugPrint('ASET TIDAK DITEMUKAN: $asset -> $error');
              return Text(
                cadangan,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
