import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Full-width navy "دخول" button; disabled with a spinner while loading.
class LoginSubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const LoginSubmitButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: isLoading ? null : onPressed,
    style: FilledButton.styleFrom(
      backgroundColor: HaseenColors.navy,
      disabledBackgroundColor: HaseenColors.navy.withValues(alpha: .7),
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    child: isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : const Text(
            'دخول',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
  );
}
