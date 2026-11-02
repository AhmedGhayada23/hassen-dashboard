import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

/// Bold label above an "add employee" input.
class AddEmployeeFieldLabel extends StatelessWidget {
  final String text;

  const AddEmployeeFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 6.h),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        color: HaseenColors.navy,
      ),
    ),
  );
}

/// Compact outlined decoration of the dialog's text fields, red on error.
InputDecoration addEmployeeInputDecoration({String? hint}) {
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: color, width: width),
      );
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: HaseenColors.fieldHint),
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
    enabledBorder: border(HaseenColors.fieldBorder),
    focusedBorder: border(HaseenColors.navy, 1.5),
    errorBorder: border(HaseenColors.red),
    focusedErrorBorder: border(HaseenColors.red, 1.5),
  );
}
