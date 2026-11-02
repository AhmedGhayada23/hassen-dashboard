import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

/// Text styles shared by several dashboard surfaces.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get pageTitle => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
    color: HaseenColors.navy,
  );

  static TextStyle get cardTitle => TextStyle(
    fontSize: 15.sp,
    fontWeight: FontWeight.w700,
    color: HaseenColors.navy,
  );

  static TextStyle get tableHeader => TextStyle(
    fontSize: 13.sp,
    fontWeight: FontWeight.w600,
    color: HaseenColors.muted,
  );
}
