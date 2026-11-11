import 'package:flutter/material.dart';
import 'finance_service.dart';
import 'finance_widgets.dart';
import 'history_ringkasan_page.dart';

class RiwayatPage extends StatelessWidget {
  final bool showBottomNav;
  final ValueChanged<int>? onNavTap;

  const RiwayatPage({
    super.key,
    this.showBottomNav = true,
    this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    final service = FinanceService.instance;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar:
          showBottomNav ? NexaBottomNav(currentIndex: 2, onTap: onNavTap) : null,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: service,
          builder: (context, _) {
            // Urutan sesuai desain: Dari tanggal terlama ke terbaru (Ascending)
            final list = List<WithdrawalItem>.from(service.withdrawals)
              ..sort((a, b) => a.date.compareTo(b.date));
            debugPrint('[RIWAYAT] akun=${service.accountName} '
                'jumlah=${list.length}');

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar
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

                // Card Saldo
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: NexaColors.maroon,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Saldo Tersedia',
                          style: nexaText(13, color: Colors.white70)),
                      const SizedBox(height: 8),
                      Text(rp(service.balance),
                          style: nexaText(28,
                              weight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('Riwayat transaksi',
                      style: nexaText(15, weight: FontWeight.w700)),
                ),

                Expanded(
                  child: list.isEmpty
                      ? Center(
                          child: Text('Belum ada riwayat penarikan',
                              style: nexaText(14, color: Colors.black54)),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: list.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 16),
                          itemBuilder: (_, i) {
                            final w = list[i];
                            return InkWell(
                              borderRadius: BorderRadius.circular(12),
                              // Klik riwayat -> halaman History Ringkasan
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      HistoryRingkasanPage(withdrawal: w),
                                ),
                              ),
                              child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: NexaColors.maroon,
                                  child: const Icon(Icons.person,
                                      color: Colors.white, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(w.recipient,
                                          style: nexaText(14,
                                              weight: FontWeight.w700)),
                                      const SizedBox(height: 2),
                                      Text(
                                          '${fmtTime(w.date)}\n${fmtDateLong(w.date)}',
                                          style: nexaText(12,
                                              color: Colors.black54)),
                                    ],
                                  ),
                                ),
                                Text(
                                  '-${rp(w.amount)}',
                                  style: nexaText(14,
                                      weight: FontWeight.w700,
                                      color: Colors.redAccent),
                                ),
                              ],
                            ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}