import 'package:flutter_screenutil/flutter_screenutil.dart';

class TeamLayoutConfig {
  TeamLayoutConfig._();

  static double get cardGap => 14.w;
  static double get cardRunGap => 14.h;

  /// Narrowest card before dropping a column. Deliberately unscaled: the
  /// available width already scales with the screen, so a scaled threshold
  /// would keep the column count fixed at every window size.
  static const minCardWidth = 274.0;
  static const maxColumns = 4;

  /// Original formula: floor(width / 274) clamped to 1–4 columns.
  static int columns(double availableWidth) =>
      (availableWidth / minCardWidth).floor().clamp(1, maxColumns);

  static double cardWidth(double availableWidth) {
    final cols = columns(availableWidth);
    return (availableWidth - cardGap * (cols - 1)) / cols;
  }
}
