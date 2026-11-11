import 'package:flutter/material.dart';

import 'konfir_buat_profil.dart';

const Color _maroon = Color(0xFF800F14);
const Color _border = Color(0xFFC77A7E);

class BuatProfil extends StatefulWidget {
  const BuatProfil({super.key});

  @override
  State<BuatProfil> createState() => _BuatProfilState();
}

class _BuatProfilState extends State<BuatProfil> {
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _tentang = TextEditingController();
  final _pendidikan = TextEditingController();
  final _pengalaman = TextEditingController();

  @override
  void dispose() {
    _nama.dispose();
    _tentang.dispose();
    _pendidikan.dispose();
    _pengalaman.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const KonfirBuatProfil()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          _Header(onBack: () => Navigator.of(context).maybePop()),
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Column(
                          children: [
                            Icon(Icons.account_circle_outlined,
                                size: 78, color: _maroon),
                            SizedBox(height: 10),
                            Text(
                              'Instruktur',
                              style: TextStyle(
                                color: _maroon,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      _Field(
                        label: 'Nama Lengkap',
                        controller: _nama,
                        textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Nama lengkap wajib diisi'
                            : null,
                      ),
                      _Field(
                        label: 'Tentang Saya',
                        controller: _tentang,
                        minLines: 4,
                        maxLines: 6,
                        keyboardType: TextInputType.multiline,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Tentang saya wajib diisi'
                            : null,
                      ),
                      _Field(
                        label: 'Pendidikan Terakhir',
                        controller: _pendidikan,
                        minLines: 2,
                        maxLines: 4,
                        keyboardType: TextInputType.multiline,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Pendidikan terakhir wajib diisi'
                            : null,
                      ),
                      _Field(
                        label: 'Pengalaman Bekerja',
                        controller: _pengalaman,
                        textInputAction: TextInputAction.done,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Pengalaman bekerja wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _simpan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _maroon,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Simpan dan Lanjutkan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _Header extends StatelessWidget {
  const _Header({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: _maroon,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        bottom: 22,
        left: 12,
        right: 12,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 4),
          const Text(
            'Buat Profil Pengajar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.validator,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final int minLines;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  OutlineInputBorder _outline([Color c = _border]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c, width: 1),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            validator: validator,
            minLines: minLines,
            maxLines: maxLines,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              enabledBorder: _outline(),
              focusedBorder: _outline(_maroon),
              errorBorder: _outline(Colors.red),
              focusedErrorBorder: _outline(Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
