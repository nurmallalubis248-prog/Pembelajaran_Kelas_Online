# Integrasi folder finance

Penyebab "halaman history akan segera tersedia": tombol di kode aplikasi
utama masih placeholder dan belum memanggil halaman di lib/finance.

## Langkah
1. Salin folder `finance/` ke `lib/` proyekmu (timpa yang lama).
2. Cari placeholder:  grep -rn "akan segera tersedia" lib/
3. Ganti isi onTap / onPressed tombolnya:

   import 'finance/finance.dart';

   Histori      ->  onTap: () => FinanceNav.openRiwayat(context)
   Lihat Semua  ->  onTap: () => FinanceNav.openPendapatan(context)
   Tarik Dana   ->  onTap: () => FinanceNav.openTarikDana(context)

4. Atau, kalau tab Keuangan belum punya halaman: pakai `KeuanganPage()`
   (sudah berisi saldo, Tarik Dana, Histori, dan Lihat Semua yang tersambung).
5. Setelah login panggil sekali:
   FinanceService.instance.loadForAccount(accountKey: email, displayName: nama);
6. Pastikan font Poppins terdaftar di pubspec.yaml.
