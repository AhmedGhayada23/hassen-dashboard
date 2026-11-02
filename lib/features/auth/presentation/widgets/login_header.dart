import 'package:flutter/material.dart';

import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';

/// Logo, product name, title and the staff-only subtitle above the form.
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Image.asset(
            AssetPaths.haseenLogo,
            width: 40,
            height: 40,
            errorBuilder: (_, _, _) => const SizedBox(width: 40, height: 40),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الحصين',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: HaseenColors.navy,
                ),
              ),
              Text(
                'HASEEN',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w700,
                  color: HaseenColors.gold,
                ),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 36),
      const Text(
        'تسجيل الدخول',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: HaseenColors.navy,
        ),
      ),
      const SizedBox(height: 6),
      const Text(
        'لوحة التحكم مخصصة لموظفي شركة الحصين.',
        style: TextStyle(fontSize: 14, color: HaseenColors.muted),
      ),
    ],
  );
}
