import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Small rounded label with a tinted background.
class StatusBadge extends StatelessWidget {
  final String text;
  final Color background, foreground;

  const StatusBadge(this.text, this.background, this.foreground, {super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(5.r),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 11.5.sp,
        fontWeight: FontWeight.w700,
        color: foreground,
      ),
    ),
  );
}
