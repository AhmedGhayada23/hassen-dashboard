import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

/// Page body shown when a dashboard page fails to load its data, with an
/// optional line explaining why.
class DashboardLoadError extends StatelessWidget {
  final VoidCallback onRetry;
  final String? details;

  const DashboardLoadError({super.key, required this.onRetry, this.details});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'تعذّر تحميل بيانات لوحة التحكم',
            style: TextStyle(fontSize: 14.sp, color: HaseenColors.muted),
          ),
          if (details case final details?) ...[
            SizedBox(height: 6.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 520.w),
              child: Text(
                details,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.sp, color: HaseenColors.red),
              ),
            ),
          ],
          SizedBox(height: 8.h),
          TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    ),
  );
}
