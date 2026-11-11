# NeXa – Navbar bawah + data per akun (paket lengkap)

## 1. Pasang kode
1. Backup folder `lib/` proyek Anda.
2. Salin isi `lib/` zip ini ke `lib/` proyek NeXa (timpa file yang sama).
   File yang tidak ada di zip (splash_screen, custom_text_field, nexa_logo,
   social_button, additional_frames) tetap milik proyek Anda.

## 2. Folder assets (sejajar dengan lib/ dan pubspec.yaml)
```
assets/images/sampul_persegi_excel.png
assets/icons/            (isi minimal 1 file, atau hapus barisnya di pubspec)
assets/fonts/Poppins-Regular.ttf
assets/fonts/Poppins-Medium.ttf
assets/fonts/Poppins-SemiBold.ttf
assets/fonts/Poppins-Bold.ttf
```
Font: unduh di fonts.google.com/specimen/Poppins.
Jika gambar ada di folder lain, ubah `thumbnail:` di `lib/services/app_session.dart`.

## 3. pubspec.yaml (bagian flutter:)
```yaml
flutter:
  uses-material-design: true

  assets:
    - assets/images/
    - assets/icons/

  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Regular.ttf
        - asset: assets/fonts/Poppins-Medium.ttf
          weight: 500
        - asset: assets/fonts/Poppins-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Poppins-Bold.ttf
          weight: 700
```
Lalu `flutter pub get`, Stop total, Run ulang (bukan hot reload).

## 4. Logika akun
| Cara masuk | Hasil |
|---|---|
| Gmail `igna@gmail.com` + sandi `Budi01Gaming` | Akun Ignatius Ryan (data lengkap) |
| Tombol G (Google) | Akun Ignatius Ryan |
| Tombol f (Facebook, "Ignatius Gaming") | Akun Ignatius Ryan |
| Daftar dengan Gmail + sandi lain | Akun BARU: Beranda, Kursus, Keuangan, Profil kosong |

Alur akun baru: Daftar -> Konfirmasi -> Buat Profil -> Konfirmasi -> Beranda.
Data contoh Ignatius (1 kursus, 75 peserta, saldo, riwayat) ada di
`lib/services/app_session.dart`, fungsi `_buildIgnatius()`.

## 5. Navbar bawah
Beranda, Kursus, Keuangan, Profil. Menu yang dibuka merah, lainnya hitam.

## Catatan
- Akun baru hanya di memori (hilang saat app ditutup). Permanen: Firebase/shared_preferences.
- Tombol "segera tersedia": Buat Kursus, Tarik Dana, History, Lihat semua,
  Kebijakan Privasi, Syarat dan Ketentuan, Customer Service.
- Kode belum dijalankan di emulator; kirim error/screenshot bila ada yang beda.
