import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClientsLayoutConfig {
  ClientsLayoutConfig._();

  static double get detailsPanelWidth => 340.w;

  /// Gap between the table and the details panel.
  static double get panelGap => 16.w;

  /// Column weights shared by the header and every row so they stay aligned:
  /// العميل · القطاع · الفروع · المرحلة · ملاحظات مفتوحة · المطابقة.
  static const columnFlex = [4, 3, 1, 2, 2, 2];
}
