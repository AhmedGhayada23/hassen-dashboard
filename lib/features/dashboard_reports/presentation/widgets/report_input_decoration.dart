import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

/// Outlined field decoration shared by the month picker and the email form.
InputDecoration reportInputDecoration() {
  OutlineInputBorder border(Color color, {double width = 1.5}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: color, width: width),
      );
  return InputDecoration(
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
    enabledBorder: border(HaseenColors.fieldBorder),
    focusedBorder: border(HaseenColors.navy),
    errorBorder: border(HaseenColors.red, width: 1),
    focusedErrorBorder: border(HaseenColors.red),
  );
}
