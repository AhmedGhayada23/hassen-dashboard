import 'package:hassen_dashboard/features/dashboard_reports/data/datasources/reports_local_datasource.dart';
import 'package:hassen_dashboard/features/dashboard_reports/data/repositories/reports_repository_impl.dart';
import 'package:hassen_dashboard/features/dashboard_reports/domain/entities/report_month.dart';
import 'package:hassen_dashboard/features/dashboard_reports/domain/repositories/reports_repository.dart';
import 'package:hassen_dashboard/features/dashboard_reports/domain/usecases/get_monthly_reports.dart';
import 'package:hassen_dashboard/features/dashboard_reports/domain/usecases/get_report_months.dart';
import 'package:hassen_dashboard/features/dashboard_reports/domain/usecases/send_monthly_report.dart';
import 'package:hassen_dashboard/features/dashboard_reports/presentation/cubits/dashboard_reports_cubit.dart';

import 'fake_reports_remote_datasource.dart';

const november = ReportMonth(id: '2026-11', label: 'نوفمبر 2026');
const october = ReportMonth(id: '2026-10', label: 'أكتوبر 2026');
const september = ReportMonth(id: '2026-09', label: 'سبتمبر 2026');

/// Today in tests: months run back from November 2026.
final reportsToday = DateTime(2026, 11, 2, 9);

/// A repository over [remote] (a fresh fake Firebase by default) whose
/// clock reads [reportsToday].
ReportsRepository buildReportsRepository([
  FakeReportsRemoteDataSource? remote,
]) => ReportsRepositoryImpl(
  ReportsLocalDataSource(clock: () => reportsToday),
  remote ?? FakeReportsRemoteDataSource(),
);

/// A cubit over [repository] whose clock reads [reportsToday].
DashboardReportsCubit buildReportsCubit([ReportsRepository? repository]) {
  final repo = repository ?? buildReportsRepository();
  return DashboardReportsCubit(
    getMonths: GetReportMonths(repo),
    getReports: GetMonthlyReports(repo),
    sendReport: SendMonthlyReport(repo, clock: () => reportsToday),
  );
}
