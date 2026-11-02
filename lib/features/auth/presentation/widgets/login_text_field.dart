import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Bold label plus the outlined white field used by both login inputs.
class LoginTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextDirection? textDirection;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onFieldSubmitted;

  const LoginTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.textDirection,
    this.autofillHints,
    this.obscureText = false,
    this.suffixIcon,
    this.onFieldSubmitted,
  });

  static OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: HaseenColors.navy,
          ),
        ),
      ),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textDirection: textDirection,
        autofillHints: autofillHints,
        obscureText: obscureText,
        onFieldSubmitted: onFieldSubmitted,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: HaseenColors.fieldHint),
          prefixIcon: Icon(icon, size: 20, color: HaseenColors.muted),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: _border(HaseenColors.fieldBorder),
          enabledBorder: _border(HaseenColors.fieldBorder),
          focusedBorder: _border(HaseenColors.navy, 1.5),
          errorBorder: _border(HaseenColors.red),
          focusedErrorBorder: _border(HaseenColors.red, 1.5),
          errorStyle: const TextStyle(color: HaseenColors.red, fontSize: 12),
        ),
      ),
    ],
  );
}
