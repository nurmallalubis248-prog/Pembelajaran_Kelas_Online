import 'package:flutter/material.dart';
import '../widgets/nexa_keyboard.dart';
import 'finance_service.dart';
import 'finance_widgets.dart';
import 'pin_page.dart';

class TarikDanaPage extends StatefulWidget {
  static const String routeName = '/tarik-dana';
  const TarikDanaPage({super.key});

  @override
  State<TarikDanaPage> createState() => _TarikDanaPageState();
}

class _TarikDanaPageState extends State<TarikDanaPage> {
  final _amountCtrl = TextEditingController();
  final String _selectedMethod = 'DANA';
  final String _accountNumber = '0123456789';

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _proceed() {
    final raw = _amountCtrl.text.replaceAll('.', '').replaceAll(',', '').trim();
    final amt = int.tryParse(raw) ?? 0;

    if (amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nominal penarikan yang valid.')),
      );
      return;
    }

    if (amt + FinanceService.adminFee > FinanceService.instance.balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saldo tidak mencukupi.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PinPage(
          amount: amt,
          method: _selectedMethod,
          account: _accountNumber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = FinanceService.instance;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: service,
          builder: (context, _) {
            return Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Text('Tarik Dana', style: nexaText(20, weight: FontWeight.w700)),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Saldo
                        Container(
                          width: double.infinity,
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
                                      weight: FontWeight.w700,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        Text('Input Nominal Penarikan',
                            style: nexaText(14, weight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        NexaKeyboardField(
                          controller: _amountCtrl,
                          numeric: true,
                          decoration: InputDecoration(
                            hintText: 'Rp 0',
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Colors.black26),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Text('Pilih Metode Transfer',
                            style: nexaText(14, weight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text('DANA',
                                      style: nexaText(11,
                                          weight: FontWeight.w800,
                                          color: Colors.white)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Dana',
                                        style: nexaText(14,
                                            weight: FontWeight.w700)),
                                    Text(_accountNumber, style: nexaText(13)),
                                  ],
                                ),
                              ),
                              Text('Ubah',
                                  style: nexaText(13,
                                      color: NexaColors.maroon,
                                      weight: FontWeight.w600)),
                              const SizedBox(width: 8),
                              const Icon(Icons.radio_button_checked,
                                  color: Colors.black38),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NexaColors.maroon,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _proceed,
                      child: Text('Konfirmasi Penarikan',
                          style: nexaText(15,
                              weight: FontWeight.w600, color: Colors.white)),
                    ),
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