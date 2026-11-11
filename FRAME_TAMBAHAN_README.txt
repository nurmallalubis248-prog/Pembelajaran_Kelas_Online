NE XA — FRAME TAMBAHAN

File tambahan: lib/screens/additional_frames.dart

File ini menambahkan layar untuk beranda, kelas, buat kursus, buat profil, profil saya, keuangan, riwayat, alur penarikan, PIN, status penarikan, akun, kebijakan privasi, syarat dan ketentuan, customer service, dan kualitas.

PENTING: File splash_screen.dart, auth_screen.dart, main.dart, widget yang sudah ada, warna, dan aset existing tidak diubah.

CARA MEMBUKA FRAME TAMBAHAN:
1. Buka folder proyek di VS Code.
2. Dari file Dart yang ingin dipakai sebagai titik masuk, import:
   import 'screens/additional_frames.dart';
   (Jika file berada di folder screens, gunakan import 'additional_frames.dart';)
3. Untuk membuka menu pratinjau frame, panggil:
   Navigator.of(context).push(nexaRoute(const NexaFrameGalleryScreen()));
4. Jalankan flutter pub get lalu flutter run.

CATATAN: Ini adalah implementasi UI/demo. Login, penyimpanan profil/kursus, pemilihan foto, transaksi bank, dan validasi PIN nyata belum terhubung ke backend. Data transaksi pada layar merupakan data contoh. Karena instruksi meminta layar lama tidak diubah, layar tambahan tidak dipasang otomatis ke tombol submit autentikasi.
