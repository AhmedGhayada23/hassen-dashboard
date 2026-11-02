import 'package:flutter/material.dart';

import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';

/// Navy brand panel shown beside the form on wide windows.
class LoginBrandPanel extends StatelessWidget {
  const LoginBrandPanel({super.key});

  @override
  Widget build(BuildContext context) => Container(
    color: HaseenColors.navy,
    padding: const EdgeInsets.all(56),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              AssetPaths.haseenLogo,
              width: 44,
              height: 44,
              errorBuilder: (_, _, _) => const SizedBox(width: 44, height: 44),
            ),
            const SizedBox(width: 12),
            const Text(
              'لوحة التحكم',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const Spacer(),
        const Text(
          'إدارة أذكى للسلامة.\nورؤية أوضح لكل منشأة.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            height: 1.35,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'الزيارات، ونتائج التفتيش، والمخاطر، والإجراءات التصحيحية لجميع العملاء في مكان واحد.',
          style: TextStyle(
            color: HaseenColors.sideGroupTitle,
            fontSize: 15,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          width: 48,
          height: 4,
          decoration: BoxDecoration(
            color: HaseenColors.gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const Spacer(),
        const Text(
          '© 2026 الحصين HASEEN',
          style: TextStyle(color: HaseenColors.sideGroupTitle, fontSize: 12),
        ),
      ],
    ),
  );
}
