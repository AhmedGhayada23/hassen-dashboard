import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Fixed column sizes of the weekly grid (it scrolls horizontally when narrower).
class VisitsLayoutConfig {
  VisitsLayoutConfig._();

  static double get inspectorColumnWidth => 140.w;
  static double get dayColumnWidth => 150.w;
  static double get dayCellMinHeight => 76.h;
}
