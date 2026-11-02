import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsLayoutConfig {
  SettingsLayoutConfig._();

  static double get cardGap => 16.w;

  /// Narrowest card before dropping a column. Deliberately unscaled: the
  /// available width already scales with the screen, so a scaled threshold
  /// would keep the column count fixed at every window size.
  static const minCardWidth = 376.0;
  static const maxColumns = 3;

  /// Original formula: floor(width / 376) clamped to 1–3 columns, where
  /// width is the page minus its side padding.
  static int columns(double availableWidth) =>
      (availableWidth / minCardWidth).floor().clamp(1, maxColumns);

  static double cardWidth(double availableWidth) {
    final cols = columns(availableWidth);
    return (availableWidth - cardGap * (cols - 1)) / cols;
  }
}
