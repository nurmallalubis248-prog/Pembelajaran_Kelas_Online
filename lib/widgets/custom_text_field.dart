import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'nexa_keyboard.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  // true = sandi tersamarkan (mata tertutup); false = sandi terlihat (mata terbuka)
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final label = widget.label;
    final hintText = widget.hintText;
    final controller = widget.controller;
    final isPassword = widget.isPassword;
    final validator = widget.validator;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 6),
        // Input Box
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: NexaKeyboardField(
            controller: controller,
            obscureText: isPassword && _hidden,
                  // awal tampil huruf kapital seperti Figma; ketuk panah untuk huruf kecil
            autoShift: !isPassword,
            validator: validator,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
              border: InputBorder.none,
              // ikon mata: ketuk untuk menampilkan / menyembunyikan sandi
              suffixIcon: isPassword
                  ? GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _hidden = !_hidden),
                      child: Icon(
                        _hidden
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: const Color(0xFF6B7280),
                      ),
                    )
                  : null,
              suffixIconConstraints:
                  const BoxConstraints(minWidth: 44, minHeight: 40),
            ),
          ),
        ),
      ],
    );
  }
}