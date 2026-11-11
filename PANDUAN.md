# NeXa - Buat Kursus + Toggle Kualitas Video

## Langkah 1 - Salin file
Ekstrak zip ini DI FOLDER PROYEK (D:\pembelajaran_kelas_online - Copy).
Struktur zip sudah lib/screens/main/..., jadi file langsung masuk ke tempatnya.
(Kalau folder tab Anda bukan lib/screens/main, pindahkan keempat file ke folder itu.)

Tidak perlu paket baru. file_picker sudah ada di proyek Anda.

## Langkah 2 - Sambungkan tombol "+ Buat Kursus"
Di file tab kursus (courses_tab.dart / course_tab.dart), cari tombol "+ Buat Kursus".
Ganti isi onPressed/onTap (yang sekarang menampilkan "Halaman Buat Kursus segera tersedia") dengan:

    Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateCoursePage()));

Tambah di atas file:  import 'create_course_page.dart';

## Langkah 3 - Sambungkan toggle kualitas video
Di file tab profil (profile_tab.dart / account_tab.dart), cari "Kualitas Upload".
Hapus showModalBottomSheet(...) di onTap-nya, ganti dengan:

    showVideoQualityDialog(context);

Tambah di atas file:  import 'video_quality_dialog.dart';

## Langkah 4 - Menu lain (opsional)
    Kebijakan Privasi    -> Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()));
    Syarat dan Ketentuan -> Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsPage()));
    Customer Service     -> Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerServicePage()));
    import 'info_pages.dart';

## Langkah 5 - HOT RESTART (huruf R besar), bukan hot reload.

## Catatan
- Upload default: file ASLI dipilih dari HP (gambar sampul + materi), lalu disalin ke
  penyimpanan aplikasi dengan progress nyata. Berjalan tanpa server.
- Untuk kirim ke server: flutter pub add http, pindahkan optional/http_course_upload_service.dart
  ke lib/screens/main/, lalu pakai:
    CreateCoursePage(service: HttpCourseUploadService(Uri.parse('https://SERVER/api/courses')))
- Warna/font: edit nexa_tokens.dart sesuai Figma. Teks kebijakan dan label kualitas masih placeholder.
- Tidak tahu lokasi barisnya? Jalankan cari_lokasi.ps1.
