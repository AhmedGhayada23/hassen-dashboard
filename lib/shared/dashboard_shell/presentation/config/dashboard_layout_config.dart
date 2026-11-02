import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Page spacing shared by every dashboard page.
class DashboardLayoutConfig {
  DashboardLayoutConfig._();

  static EdgeInsets get contentPadding =>
      EdgeInsets.fromLTRB(28.w, 24.h, 28.w, 48.h);

  /// Vertical gap between page sections.
  static double get sectionGap => 20.h;
}
