import 'package:flutter/material.dart';
import 'finance_widgets.dart';
import 'status_pages.dart';

class PinPage extends StatefulWidget {
  final int amount;
  final String method;
  final String account;

  const PinPage({
    super.key,
    required this.amount,
    required this.method,
    required this.account,
  });

  @override
  State<PinPage> createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  String _pin = '';
  bool _submitting = false;

  void _onKeyTap(String val) {
    if (_submitting || _pin.length >= 6) return;
    setState(() => _pin += val);
    if (_pin.length == 6) {
      _submitting = true;
      // beri jeda singkat agar digit ke-6 sempat tampil
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _submit();
      });
    }
  }

  void _onBackspace() {
    if (!_submitting && _pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ProsesPenarikanPage(
          amount: widget.amount,
          method: widget.method,
          accountNumber: widget.account,
          pin: _pin,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
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
                  Text('PIN Keamanan', style: nexaText(20, weight: FontWeight.w700)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
            const SizedBox(height: 24),
            Text(
              'Masukkan 6 digit PIN untuk\nmelanjutkan penarikan',
              textAlign: TextAlign.center,
              style: nexaText(14, weight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            // Ikon perisai + gembok sesuai Figma (digambar dengan Icon,
            // jadi tidak butuh file asset).
            Stack(
              alignment: Alignment.center,
              children: const [
                Icon(Icons.shield, size: 84, color: NexaColors.maroon),
                Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.lock, size: 30, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Kotak PIN: border maroon, angka tampil di dalam kotak
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) {
                final filled = i < _pin.length;
                return Container(
                  width: 40,
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: NexaColors.maroon, width: 1),
                  ),
                  alignment: Alignment.center,
                  child: filled
                      ? Text(_pin[i], style: nexaText(22, weight: FontWeight.w700))
                      : null,
                );
              }),
            ),
                    ],
                  ),
                ),
              ),
            ),
            // Keypad angka gelap sesuai Figma
            _buildKeypad(),
          ],
        ),
      ),
    );
  }

  static const _letters = {
    '2': 'ABC', '3': 'DEF', '4': 'GHI', '5': 'JKL',
    '6': 'MNO', '7': 'PQRS', '8': 'TUV', '9': 'WXYZ',
  };

  Widget _buildKeypad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'back'],
    ];

    return Container(
      color: const Color(0xFF1F1F1F),
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 20),
      child: SafeArea(
        top: false,
        child: Column(
          children: keys.map((row) {
            return Row(
              children: row.map((k) {
                Widget child;
                if (k.isEmpty) {
                  return const Expanded(child: SizedBox(height: 56));
                } else if (k == 'back') {
                  child = const Icon(Icons.backspace_outlined,
                      color: Colors.white, size: 26);
                  return Expanded(
                    child: InkWell(
                      onTap: _onBackspace,
                      child: SizedBox(height: 56, child: Center(child: child)),
                    ),
                  );
                }
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Material(
                      color: const Color(0xFF444444),
                      borderRadius: BorderRadius.circular(5),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(5),
                        onTap: () => _onKeyTap(k),
                        child: SizedBox(
                          height: 50,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(k,
                                  style: nexaText(22,
                                      weight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1.1)),
                              if (_letters.containsKey(k))
                                Text(_letters[k]!,
                                    style: nexaText(8,
                                        weight: FontWeight.w700,
                                        color: Colors.white,
                                        height: 1.0)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}
