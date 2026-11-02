import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

/// White, outlined, 12px-rounded surface.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Clip clipBehavior;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.clipBehavior = Clip.none,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    clipBehavior: clipBehavior,
    decoration: BoxDecoration(
      color: Colors.white,
      border: const Border.fromBorderSide(BorderSide(color: HaseenColors.line)),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: child,
  );
}
