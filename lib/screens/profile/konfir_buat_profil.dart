import 'package:flutter/material.dart';

const Color _maroon = Color(0xFF800F14);

class KonfirBuatProfil extends StatelessWidget {
  const KonfirBuatProfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back, color: Colors.grey),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 116,
                        height: 116,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _maroon, width: 7),
                        ),
                        child: const Icon(Icons.check,
                            size: 70, color: _maroon),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Konfirmasi Sukses',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _maroon,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Profil Anda sekarang sudah aktif dan dapat dilihat '
                        'oleh calon siswa. Anda bisa memperbaruinya kapan '
                        'saja melalui menu profil',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, height: 1.45),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // Ganti dengan halaman utama instruktur milikmu, mis.:
                    // Navigator.pushAndRemoveUntil(context,
                    //   MaterialPageRoute(builder: (_) => const Home()),
                    //   (route) => false);
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _maroon,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Masuk',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.chevron_right, size: 28),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
