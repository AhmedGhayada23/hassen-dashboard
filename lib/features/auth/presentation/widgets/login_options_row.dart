import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// "Remember me" checkbox and the forgot-password link.
class LoginOptionsRow extends StatelessWidget {
  final bool rememberMe;
  final ValueChanged<bool> onRememberMeChanged;
  final VoidCallback onForgotPassword;

  const LoginOptionsRow({
    super.key,
    required this.rememberMe,
    required this.onRememberMeChanged,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
        width: 24,
        height: 24,
        child: Checkbox(
          value: rememberMe,
          activeColor: HaseenColors.navy,
          onChanged: (v) => onRememberMeChanged(v ?? false),
        ),
      ),
      const SizedBox(width: 8),
      const Text(
        'تذكرني على هذا الجهاز',
        style: TextStyle(fontSize: 13, color: HaseenColors.navy),
      ),
      const Spacer(),
      TextButton(
        onPressed: onForgotPassword,
        style: TextButton.styleFrom(
          foregroundColor: HaseenColors.teal,
          padding: EdgeInsets.zero,
        ),
        child: const Text(
          'نسيت كلمة المرور؟',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );
}
