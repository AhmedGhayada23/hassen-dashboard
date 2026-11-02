import '../../domain/entities/report_month.dart';

/// The months reports can be viewed for, worked out from the clock: this
/// month and the [count] − 1 before it, newest first.
class ReportsLocalDataSource {
  static const defaultCount = 6;

  final DateTime Function() _clock;
  final int count;

  const ReportsLocalDataSource({
    DateTime Function() clock = DateTime.now,
    this.count = defaultCount,
  }) : _clock = clock;

  Future<List<ReportMonth>> getMonths() async {
    final now = _clock();
    return [
      for (var back = 0; back < count; back++)
        _month(DateTime(now.year, now.month - back)),
    ];
  }

  static ReportMonth _month(DateTime d) => ReportMonth(
    id: '${d.year}-${d.month.toString().padLeft(2, '0')}',
    label: '${_monthNames[d.month - 1]} ${d.year}',
  );

  static const _monthNames = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];
}
