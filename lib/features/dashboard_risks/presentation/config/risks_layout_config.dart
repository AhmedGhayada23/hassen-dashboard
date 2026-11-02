import 'package:flutter_screenutil/flutter_screenutil.dart';

class RisksLayoutConfig {
  RisksLayoutConfig._();

  static double get matrixCardWidth => 300.w;

  /// Gap between the table and the matrix card.
  static double get panelGap => 16.w;

  /// Column weights shared by the header and every row:
  /// الدرجة · الخطر · المنشأة · المسؤول · الحالة.
  static const columnFlex = [1, 4, 3, 3, 2];
}
