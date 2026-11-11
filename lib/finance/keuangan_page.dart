import 'package:flutter/material.dart';
import 'finance_nav.dart';
import 'finance_service.dart';
import 'finance_widgets.dart';

/// Halaman utama tab "Keuangan": saldo, tombol Tarik Dana, Histori,
/// dan ringkasan Pendapatan dengan "Lihat Semua".
/// Semua tombol sudah tersambung ke halaman asli (tidak ada placeholder).
///
/// Kalau tab Keuangan di aplikasimu sudah punya halaman sendiri, cukup
/// ganti onTap tombolnya dengan FinanceNav.* (lihat finance_nav.dart).
class KeuanganPage extends StatelessWidget {
  final bool showBottomNav;
  final ValueChanged<int>? onNavTap;
  const KeuanganPage({super.key, this.showBottomNav = false, this.onNavTap});

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
            final recent = service.incomes.reversed.take(3).toList();
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Text('Keuangan', style: nexaText(20, weight: FontWeight.w700)),
                const SizedBox(height: 16),
                SaldoCard(saldo: service.balance),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Tarik Dana',
                  onPressed: () => FinanceNav.openTarikDana(context),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => FinanceNav.openRiwayat(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: NexaColors.maroon),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Histori',
                        style: nexaText(15,
                            weight: FontWeight.w500, color: NexaColors.maroon)),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: Text('Pendapatan',
                          style: nexaText(15, weight: FontWeight.w700)),
                    ),
                    InkWell(
                      onTap: () => FinanceNav.openPendapatan(context),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text('Lihat Semua',
                            style: nexaText(13,
                                weight: FontWeight.w500,
                                color: NexaColors.maroon)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (recent.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Center(
                      child: Text('Belum ada pendapatan',
                          style: nexaText(14, color: Colors.black54)),
                    ),
                  ),
                for (final it in recent) _RecentIncome(item: it),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RecentIncome extends StatelessWidget {
  final IncomeItem item;
  const _RecentIncome({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: NexaColors.greenSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.arrow_upward, color: NexaColors.green, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: nexaText(14, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${fmtDateShort(item.date)}: ${item.buyer}', style: nexaText(13)),
              ],
            ),
          ),
          Text('+${rp(item.amount)}',
              style: nexaText(14, weight: FontWeight.w600, color: NexaColors.green)),
        ],
      ),
    );
  }
}
