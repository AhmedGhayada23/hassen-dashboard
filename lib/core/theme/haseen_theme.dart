import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Material 3 theme for the HASEEN dashboard (Arial, navy/gold scheme).
class HaseenTheme {
  HaseenTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'Arial',
    scaffoldBackgroundColor: HaseenColors.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: HaseenColors.navy,
      primary: HaseenColors.navy,
      secondary: HaseenColors.gold,
    ),
  );
}
