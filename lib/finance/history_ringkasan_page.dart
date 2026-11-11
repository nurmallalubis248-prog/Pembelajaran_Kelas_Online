import 'package:flutter/material.dart';
import 'finance_service.dart';
import 'finance_widgets.dart';

const _bulanPanjang = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
];

/// Format sesuai desain: "5 November, 2026"
String _fmtTanggalRingkasan(DateTime d) =>
    '${d.day} ${_bulanPanjang[d.month - 1]}, ${d.year}';

/// Halaman "History Ringkasan": rincian satu transaksi penarikan.
/// Dibuka dengan menekan salah satu item di halaman History (RiwayatPage).
class HistoryRingkasanPage extends StatelessWidget {
  final WithdrawalItem withdrawal;
  const HistoryRingkasanPage({super.key, required this.withdrawal});

  @override
  Widget build(BuildContext context) {
    final w = withdrawal;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.maybePop(context),
                    child: const Icon(Icons.arrow_back, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Text('History', style: nexaText(20, weight: FontWeight.w700)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54, width: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F9E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/icons/history_penarikan.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Penarikan: ${w.method} (${w.maskedAccount})',
                          textAlign: TextAlign.center,
                          style: nexaText(13, weight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(rp(w.amount),
                          style: nexaText(22, weight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD7F7DC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Selesai',
                            style: nexaText(11,
                                weight: FontWeight.w500,
                                color: const Color(0xFF3DBE5A))),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_fmtTanggalRingkasan(w.date),
                              style: nexaText(11, weight: FontWeight.w600)),
                          const SizedBox(width: 14),
                          Text(fmtTime(w.date),
                              style: nexaText(11, weight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const Divider(height: 1, color: Colors.black54),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Penarikan Berhasil',
                                  style:
                                      nexaText(12, weight: FontWeight.w700)),
                              const SizedBox(height: 10),
                              Text(
                                'Penarikan saldo dari aplikasi Bimble telah berhasil diproses dan dikirim ke rekening bank kamu. Dana sebesar ${rp(w.amount)} telah berhasil ditransfer ke rekening tujuan. Terima kasih telah menggunakan Bimble. Selamat menikmati hasil belajar dan cashback kamu!',
                                style: nexaText(11,
                                    weight: FontWeight.w600, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 1, color: Colors.black54),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text('ID: ${w.id}',
                            style: nexaText(11, weight: FontWeight.w700)),
                      ),
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