import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'finance_service.dart';
import 'finance_widgets.dart';
import '../screens/main/main_shell.dart';
import '../widgets/floating_rocket.dart';
import '../widgets/please_wait_text.dart';

// ---------------------------------------------------------------------------
// Ukuran diukur langsung dari frame Figma "Status Penarikan" (390 x 844, 1:1 dp)
//   Kartu roket  : x 30, y 92, 330 x 193, radius 30, garis 1px #9D4040
//   Roket        : 103 x 103, 32 dp dari atas kartu, di tengah
//   Label        : "Status Penarikan" 13 semibold putih, cap-top y 247
//   Kotak status : x 21 .. 370 (350 lebar), y 323 .. 474 (152 tinggi),
//                  radius 20, garis 1px #888888, teks 13 mulai x 41
//   "harap tunggu...": 20 semibold #5B5B5B, di tengah, atas huruf y 634
// ---------------------------------------------------------------------------
const double _kDesignTop = 92; // posisi atas kartu dari tepi layar (termasuk status bar)
const double _kCardMargin = 30;
const double _kBoxMargin = 21;
const Color _kCardBorder = Color(0xFF9D4040);
const Color _kBoxBorder = Color(0xFF888888);
const Color _kWaitGrey = Color(0xFF5B5B5B);

/// Kartu marun berisi roket melayang + "Status Penarikan" (dipakai 2 halaman).
class _StatusHeader extends StatelessWidget {
  const _StatusHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: _kCardMargin),
      width: double.infinity,
      height: 193,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _kCardBorder, width: 1),
      ),
      child: Stack(
        children: [
          // Gambar roket sudah punya ~2% ruang kosong tiap sisi, jadi 107
          // supaya bentuk roketnya tepat 103 dp seperti di Figma.
          const Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Center(child: FloatingRocket(size: 107, glowColor: Colors.white)),
          ),
          Positioned(
            top: 149,
            left: 0,
            right: 0,
            child: Text(
              'Status Penarikan',
              textAlign: TextAlign.center,
              style: nexaText(13, weight: FontWeight.w600, color: Colors.white, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kotak putih bergaris abu (radius 20) tempat teks "Status Proses".
class _StatusBox extends StatelessWidget {
  final Widget child;
  const _StatusBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: _kBoxMargin),
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 152),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBoxBorder, width: 1),
      ),
      child: child,
    );
  }
}

double _topInset(BuildContext context) {
  final safeTop = MediaQuery.of(context).padding.top;
  return safeTop + 20 > _kDesignTop ? safeTop + 20 : _kDesignTop;
}

/// Halaman 1: permintaan diterima, "harap tunggu...".
/// Memproses penarikan lalu pindah otomatis ke halaman selesai.
class ProsesPenarikanPage extends StatefulWidget {
  final int amount;
  final String method;
  final String accountNumber;
  final String pin;
  const ProsesPenarikanPage({
    super.key,
    required this.amount,
    required this.method,
    required this.accountNumber,
    required this.pin,
  });

  @override
  State<ProsesPenarikanPage> createState() => _ProsesPenarikanPageState();
}

class _ProsesPenarikanPageState extends State<ProsesPenarikanPage> {
  @override
  void initState() {
    super.initState();
    // JANGAN ubah saldo / pindah halaman langsung di initState (layar masih
    // dibangun) -> bisa membuat Navigator error dan tombol berikutnya mati.
    // Tunggu frame pertama selesai dulu.
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    // Tampilkan "harap tunggu..." sebentar, sesuai desain.
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    // Ambil dulu data nama & saldo awal untuk ringkasan.
    final service = FinanceService.instance;
    final name = service.accountName;
    final success = service.processWithdrawal(
      amount: widget.amount,
      method: widget.method,
      accountNumber: widget.accountNumber,
      pin: widget.pin,
    );
    if (!mounted) return;
    if (!success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Penarikan gagal. Periksa saldo dan data Anda.')),
      );
      return;
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => PenarikanSelesaiPage(amount: widget.amount, name: name),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // jangan bisa kembali saat proses
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(top: _topInset(context), bottom: 20),
          child: Column(
            children: [
              const _StatusHeader(),
              const SizedBox(height: 38), // kartu berakhir y 285 -> kotak mulai y 323
              _StatusBox(
                child: Text.rich(TextSpan(children: [
                  TextSpan(
                      text: 'Status Proses:\n',
                      style: nexaText(13, weight: FontWeight.w700, height: 1.5)),
                  TextSpan(
                      text:
                          'Permintaan penarikan Anda telah diterima oleh tim bimbel dan sedang diuji/diverifikasi. Jika ada kendala, dana akan dikembalikan otomatis ke Saldo Utama Anda.',
                      style: nexaText(13, height: 1.5)),
                ])),
              ),
              const SizedBox(height: 152), // kotak berakhir y 475 -> teks mulai y 627
              // Indikator loading = teks tersendiri "harap tunggu..." (titik
              // bergerak), tanpa spinner, sesuai Figma.
              PleaseWaitText(
                text: 'harap tunggu',
                style: nexaText(20, weight: FontWeight.w600, color: _kWaitGrey, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Halaman 2: penarikan berhasil (kepala kartu & kotak sama dengan halaman 1).
class PenarikanSelesaiPage extends StatelessWidget {
  final int amount;
  final String name;
  const PenarikanSelesaiPage({super.key, required this.amount, required this.name});

  @override
  Widget build(BuildContext context) {
    const fee = FinanceService.adminFee;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.only(top: _topInset(context), bottom: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - _topInset(context) - 20),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const _StatusHeader(),
                    const SizedBox(height: 28),
                    _StatusBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Saldo Utama', style: nexaText(13, weight: FontWeight.w600)),
                          Text(name, style: nexaText(13, weight: FontWeight.w600)),
                          const SizedBox(height: 16),
                          Text('Nominal Penarikan:', style: nexaText(13, weight: FontWeight.w600)),
                          Text(rp(amount), style: nexaText(13, weight: FontWeight.w600)),
                          const SizedBox(height: 10),
                          Text('Biaya Admin:', style: nexaText(13, weight: FontWeight.w600)),
                          Text(rp(fee), style: nexaText(13, weight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Row(children: [
                            Text(rp(amount), style: nexaText(13, weight: FontWeight.w600)),
                            const SizedBox(width: 22),
                            const Icon(Icons.arrow_right_alt, size: 22),
                            const SizedBox(width: 22),
                            Text(rp(amount + fee), style: nexaText(13, weight: FontWeight.w600)),
                          ]),
                          const SizedBox(height: 10),
                          Text.rich(TextSpan(children: [
                            TextSpan(
                                text: 'Status Proses:\n',
                                style: nexaText(13, weight: FontWeight.w700, height: 1.5)),
                            TextSpan(
                                text:
                                    'Penarikan dana berhasil diproses dan dikirim ke rekening tujuan. Silakan cek saldo rekening atau e-wallet Anda secara berkala. Jika dana belum masuk, hubungi layanan pelanggan.',
                                style: nexaText(13, weight: FontWeight.w600, height: 1.5)),
                          ])),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: _kBoxMargin, vertical: 16),
                      child: PrimaryButton(
                        label: 'Selesai',
                        onPressed: () {
                          // Selesai -> tutup seluruh alur penarikan (Tarik Dana,
                          // PIN, Status) dan kembali ke tab Keuangan (index 2).
                          // Saldo di situ sudah terpotong.
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const MainShell(initialIndex: 2)),
                            (route) => false,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}