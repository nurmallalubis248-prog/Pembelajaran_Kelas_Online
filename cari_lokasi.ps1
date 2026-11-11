# Jalankan dari folder proyek:  powershell -ExecutionPolicy Bypass -File .\cari_lokasi.ps1
# Menampilkan file dan nomor baris yang perlu diganti.
Get-ChildItem -Path .\lib -Recurse -Filter *.dart |
  Select-String -Pattern 'segera tersedia','Kualitas Upload','Kebijakan Privasi','Syarat dan Ketentuan','Customer Service','Buat Kursus' |
  ForEach-Object { "{0}:{1}  {2}" -f $_.Path.Replace((Get-Location).Path + '\',''), $_.LineNumber, $_.Line.Trim() }
