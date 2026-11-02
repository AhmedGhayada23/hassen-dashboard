import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

/// Bold label above a "schedule a visit" input.
class ScheduleVisitFieldLabel extends StatelessWidget {
  final String text;

  const ScheduleVisitFieldLabel(this.text, {super.key});

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

/// Compact outlined decoration shared by the dialog's dropdowns and notes field.
InputDecoration scheduleVisitInputDecoration() => InputDecoration(
  isDense: true,
  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.r),
    borderSide: const BorderSide(color: HaseenColors.fieldBorder),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.r),
    borderSide: const BorderSide(color: HaseenColors.navy, width: 1.5),
  ),
);

/// The facility, shown read-only when the visit is booked from its own page.
class ScheduleVisitFixedFacility extends StatelessWidget {
  final String label;

  const ScheduleVisitFixedFacility({super.key, required this.label});

  @override
  Widget build(BuildContext context) => InputDecorator(
    decoration: scheduleVisitInputDecoration().copyWith(
      filled: true,
      fillColor: HaseenColors.tableHeader,
      suffixIcon: Icon(
        Icons.lock_outline,
        size: 18.sp,
        color: HaseenColors.muted,
      ),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 14.sp, color: HaseenColors.navy),
    ),
  );
}

/// A dropdown option with the dialog's 14px text.
DropdownMenuItem<T> scheduleVisitOption<T>(T value, String label) =>
    DropdownMenuItem(
      value: value,
      child: Text(label, style: TextStyle(fontSize: 14.sp)),
    );
