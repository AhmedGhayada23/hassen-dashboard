/// Columns of the deals table, in display order, with their flex widths.
class DealsTableConfig {
  DealsTableConfig._();

  static const headers = [
    'الرقم',
    'العميل',
    'التاريخ',
    'الحالة',
    'مدة التعاقد',
    'الإجراءات',
  ];

  static const columnFlex = [2, 4, 2, 2, 4, 3];
}
