import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../validation/login_validator.dart';
import 'login_text_field.dart';

/// Password input with the show/hide toggle.
class LoginPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscured;
  final VoidCallback onToggleVisibility;
  final VoidCallback onSubmitted;

  const LoginPasswordField({
    super.key,
    required this.controller,
    required this.obscured,
    required this.onToggleVisibility,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) => LoginTextField(
    label: 'كلمة المرور',
    hint: '••••••••',
    icon: Icons.lock_outline,
    controller: controller,
    obscureText: obscured,
    autofillHints: const [AutofillHints.password],
    onFieldSubmitted: (_) => onSubmitted(),
    validator: LoginValidator.password,
    suffixIcon: IconButton(
      tooltip: obscured ? 'إظهار كلمة المرور' : 'إخفاء كلمة المرور',
      icon: Icon(
        obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        size: 20,
        color: HaseenColors.muted,
      ),
      onPressed: onToggleVisibility,
    ),
  );
}
