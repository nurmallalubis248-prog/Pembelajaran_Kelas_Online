
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../finance/finance_nav.dart';
import '../../finance/finance_service.dart';
import '../../models/user_account.dart';
import '../../services/app_session.dart';
import '../../utils/format.dart';
import '../../widgets/app_alert_dialog.dart';
import '../../widgets/empty_hint.dart';
import '../../widgets/tap_scale.dart';

class FinanceTab extends StatelessWidget {
  const FinanceTab({super.key});

  /// Margin kiri-kanan halaman. Kartu Statistik TIDAK memakai margin ini:
  /// batangnya mulai di x=22 pada frame Figma 390 dan bisa digeser sampai
  /// tepi layar.
  static const EdgeInsets _pagePadding = EdgeInsets.symmetric(horizontal: 24);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSession.instance,
      builder: (context, _) {
        final user = AppSession.instance.userOrGuest;

        return ListenableBuilder(
          listenable: FinanceService.instance,
          builder: (context, _) {
            return Scaffold(
              backgroundColor: AppColors.white,
              body: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 14, bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: _pagePadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 2),
                              child: Text(
                                'Pendapatan',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            _BalanceCard(
                              balance: FinanceService.instance.balance,
                              onWithdraw: () {
                                if (FinanceService.instance.balance <= 0) {
                                  showFillWarningDialog(
                                    context,
                                    text: 'Saldo Anda belum cukup untuk ditarik',
                                  );
                                  return;
                                }

                                FinanceNav.openTarikDana(context);
                              },
                            ),

                            const SizedBox(height: 14),

                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  FinanceNav.openRiwayat(context);
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(right: 2),
                                  child: Text(
                                    'History',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 4),

                            const Text(
                              '6 bulan terakhir',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Kartu Statistik: 6 batang terlihat, geser ke kiri
                      // untuk bulan-bulan sebelumnya.
                      _BarChart(points: user.incomeSeries()),

                      const SizedBox(height: 26),

                      Padding(
                        padding: _pagePadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Riwayat pendapatan',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    FinanceNav.openPendapatan(context);
                                  },
                                  child: const Text(
                                    'Lihat semua',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            if (user.transactions.isEmpty)
                              const EmptyHint(
                                icon: Icons.account_balance_wallet_outlined,
                                text: 'Belum ada pendapatan.\n'
                                    'Hasil penjualan kursus akan muncul di sini.',
                              )
                            else
                              for (final transaction in user.transactions.take(3))
                                _TransactionRow(tx: transaction),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final int balance;
  final VoidCallback onWithdraw;

  const _BalanceCard({
    required this.balance,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saldo Tersedia',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            formatRupiah(balance),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 30,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 14),

          TapScale(
            child: SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: onWithdraw,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Tarik Dana',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu Statistik "6 bulan terakhir" (frame Figma lebar 390).
///
/// Ukuran dari Figma: margin kiri 22, kanan 18, jarak antar batang 10,
/// lebar batang 50 (6 batang pas satu layar), sudut batang 10.
/// Tinggi batang: 2,5 juta = 43 px dan 3,1 juta = 86 px. Bila ada bulan yang
/// lebih tinggi dari 3,1 juta, skala dipadatkan supaya batang tertinggi tetap
/// 86 px (tata letak halaman tidak bergeser).
///
/// Batang terbaru ada di kanan dan langsung terlihat; geser ke kanan-ke-kiri
/// untuk melihat bulan sebelumnya. Masuk bulan baru -> batang baru muncul.
class _BarChart extends StatelessWidget {
  final List<MonthlyIncomePoint> points; // terlama -> terbaru

  const _BarChart({required this.points});

  static const double _padLeft = 22;
  static const double _padRight = 18;
  static const double _gap = 10;
  static const int _visible = 6;

  static const double _barMin = 43; // tinggi untuk _refLow
  static const double _barMax = 86; // tinggi untuk _refHigh / maksimum
  static const double _refLow = 2.5; // juta
  static const double _refHigh = 3.1; // juta
  static const double _stub = 6; // bulan 0 / sangat kecil

  static const double _labelH = 18; // teks 12 px, tinggi baris 1.5
  static const double _labelGap = 5;
  static const double _monthGap = 6;
  static const double _height =
      _labelH + _labelGap + _barMax + _monthGap + _labelH;

  double _barHeight(double juta, double scale) {
    if (juta <= 0) return _stub;
    final h = _barMin + (juta - _refLow) * scale;
    return math.max(_stub, math.min(_barMax, h));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final barW = (constraints.maxWidth -
                _padLeft -
                _padRight -
                _gap * (_visible - 1)) /
            _visible;

        final peak = points.fold<double>(
          _refHigh,
          (m, p) => math.max(m, p.juta),
        );
        final scale = (_barMax - _barMin) / (peak - _refLow);
        final last = points.length - 1;

        return SizedBox(
          height: _height,
          child: ListView.separated(
            // reverse: awal di bulan terbaru (kanan), geser untuk yang lama.
            reverse: true,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: _padLeft, right: _padRight),
            itemCount: points.length,
            separatorBuilder: (_, _) => const SizedBox(width: _gap),
            itemBuilder: (context, index) {
              final i = last - index; // index 0 = bulan terbaru
              final p = points[i];
              return _Bar(
                key: ValueKey(p.month.millisecondsSinceEpoch),
                width: barW,
                point: p,
                barHeight: _barHeight(p.juta, scale),
                isLatest: i == last,
              );
            },
          ),
        );
      },
    );
  }
}

class _Bar extends StatelessWidget {
  final double width;
  final MonthlyIncomePoint point;
  final double barHeight;
  final bool isLatest;

  const _Bar({
    super.key,
    required this.width,
    required this.point,
    required this.barHeight,
    required this.isLatest,
  });

  static const TextStyle _labelStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    height: 1.5,
    color: Colors.black,
  );

  @override
  Widget build(BuildContext context) {
    final value = point.juta <= 0
        ? '0'
        : point.juta.toStringAsFixed(1).replaceAll('.', ',');

    return SizedBox(
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(value, style: _labelStyle),
          const SizedBox(height: _BarChart._labelGap),
          // Batang tumbuh dari bawah saat tampil / saat angkanya berubah.
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: barHeight),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            builder: (context, h, _) => Container(
              height: h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isLatest
                    ? AppColors.primary
                    : const Color(0xFFCDA2A5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: _BarChart._monthGap),
          Text(shortMonthName(point.month.month), style: _labelStyle),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final IncomeTransaction tx;

  const _TransactionRow({
    required this.tx,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF2DBE60);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFA8E6BE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_upward_rounded,
              color: green,
              size: 26,
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),

                Text(
                  tx.dateAndBuyer,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '+Rp ${formatThousands(tx.amount)}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: green,
            ),
          ),
        ],
      ),
    );
  }
}
