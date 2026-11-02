import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/features/dashboard_reports/domain/entities/monthly_report.dart';
import 'package:hassen_dashboard/features/dashboard_reports/domain/entities/report_delivery.dart';
import 'package:hassen_dashboard/features/dashboard_reports/domain/failures/report_failures.dart';
import 'package:hassen_dashboard/features/dashboard_reports/presentation/cubits/dashboard_reports_cubit.dart';
import 'package:hassen_dashboard/features/dashboard_reports/presentation/cubits/dashboard_reports_state.dart';

import '../../helpers/reports_cubit_factory.dart';

void main() {
  late DashboardReportsCubit cubit;

  setUp(() => cubit = buildReportsCubit());
  tearDown(() => cubit.close());

  DashboardReportsLoaded loaded() => cubit.state as DashboardReportsLoaded;
  MonthlyReport shifa() => loaded().reports.last;

  test('opens on this month, one report per contracted client', () async {
    await cubit.load();

    expect(loaded().months.take(3), [november, october, september]);
    expect(loaded().month, november);
    expect(loaded().reports, hasLength(3));
    expect(loaded().sentCount, 0);
  });

  test('switching month shows that month\'s reports', () async {
    await cubit.load();

    await cubit.selectMonth(october);
    expect(shifa().total, 4);

    await cubit.selectMonth(september);
    expect(loaded().month, september);
    expect(loaded().sentCount, 1);
  });

  test('sending marks the report and confirms once', () async {
    await cubit.load();
    await cubit.selectMonth(october);
    const delivery = ReportDelivery(to: 'safety@shifa.ps');

    await cubit.send(shifa(), delivery);

    expect(shifa().status, MonthlyReportStatus.sent);
    expect(shifa().sentOn, '2026-11-02');
    expect(loaded().sentCount, 1);
    expect(loaded().lastSent, (shifa(), delivery));
  });

  test('a send that fails is reported, nothing marked', () async {
    await cubit.load();
    await cubit.selectMonth(october);

    await cubit.send(shifa(), const ReportDelivery(to: 'bad'));

    expect(loaded().actionFailure, const InvalidReportRecipientFailure());
    expect(loaded().sentCount, 0);
  });

  test('a sent report stays sent after switching months', () async {
    await cubit.load();
    await cubit.selectMonth(october);
    await cubit.send(shifa(), const ReportDelivery(to: 'safety@shifa.ps'));

    await cubit.selectMonth(september);
    await cubit.selectMonth(october);

    expect(shifa().sentOn, '2026-11-02');
  });
}
