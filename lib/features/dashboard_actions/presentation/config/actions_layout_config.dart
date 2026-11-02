import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActionsLayoutConfig {
  ActionsLayoutConfig._();

  static double get columnGap => 12.w;
  static double get cardGap => 8.h;
  static double get columnPadding => 10.r;
  static double get columnMinHeight => 300.h;

  /// Original formula: ((available - 3 gaps) / 4).clamp(220, 400).
  ///
  /// The clamp bounds stay unscaled, like the KPI breakpoint: the available
  /// width already scales with the screen, so scaled bounds would never kick
  /// in and the board would never scroll horizontally on narrow windows.
  static double columnWidth(double availableWidth) =>
      ((availableWidth - columnGap * 3) / 4).clamp(220.0, 400.0);
}
