import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Grid spacing and breakpoints specific to the overview page.
class OverviewLayoutConfig {
  OverviewLayoutConfig._();

  /// Horizontal gap between cards sharing a row.
  static double get cardGap => 16.w;

  static double get kpiGap => 12.w;
  static double get kpiRunGap => 12.h;

  /// 6 KPI cards per row on wide content, otherwise 3.
  ///
  /// The breakpoint is deliberately unscaled: the content width already scales
  /// with the screen, so a `.w` breakpoint would never be crossed. In logical
  /// pixels it switches near a 1385px window, as the original did (~1396px).
  static int kpiColumns(double contentWidth) => contentWidth > 1100 ? 6 : 3;
}
