import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

/// A muted line standing in for an overview card's empty list.
class OverviewEmptyNote extends StatelessWidget {
  final String text;

  const OverviewEmptyNote(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 8.h),
    child: Text(
      text,
      style: TextStyle(fontSize: 12.5.sp, color: HaseenColors.muted),
    ),
  );
}
