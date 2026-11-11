
import 'package:flutter/material.dart';

import 'finance_service.dart';
import 'finance_widgets.dart';

/// Halaman Pendapatan mengikuti frame Figma asli:
/// header, daftar pendapatan, dan navbar bawah.
class PendapatanPage extends StatelessWidget {
  final bool showBottomNav;
  final ValueChanged<int>? onNavTap;

  const PendapatanPage({
    super.key,
    this.showBottomNav = true,
    this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    final service = FinanceService.instance;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: showBottomNav
          ? NexaBottomNav(currentIndex: 2, onTap: onNavTap)
          : null,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: service,
          builder: (context, _) {
            final items = List<IncomeItem>.from(service.incomes)
              ..sort((a, b) => a.date.compareTo(b.date));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header sesuai frame Figma asli.
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 16, 18),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.maybePop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Pendapatan',
                        style: nexaText(
                          20,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Daftar pendapatan sesuai frame asli.
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Text(
                            'Belum ada pendapatan',
                            style: nexaText(
                              14,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            24,
                            10,
                            24,
                            16,
                          ),
                          itemCount: items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 22),
                          itemBuilder: (context, index) {
                            final item = items[index];

                            return Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: NexaColors.greenSoft,
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_upward_rounded,
                                    color: NexaColors.green,
                                    size: 23,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: nexaText(
                                          14,
                                          weight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${fmtDateShort(item.date)}: ${item.buyer}',
                                        style: nexaText(14),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '+${rp(item.amount)}',
                                  style: nexaText(
                                    14,
                                    weight: FontWeight.w700,
                                    color: NexaColors.green,
                                  ),
                                ),
                              ],
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
