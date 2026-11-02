import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/monthly_report.dart';
import '../../domain/entities/report_delivery.dart';
import '../../domain/entities/report_month.dart';
import '../../domain/usecases/get_monthly_reports.dart';
import '../../domain/usecases/get_report_months.dart';
import '../../domain/usecases/send_monthly_report.dart';
import 'dashboard_reports_state.dart';

/// Loads the monthly reports (newest month first), switches month, and sends
/// a report by email.
class DashboardReportsCubit extends Cubit<DashboardReportsState> {
  final GetReportMonths _getMonths;
  final GetMonthlyReports _getReports;
  final SendMonthlyReport _sendReport;

  DashboardReportsCubit({
    required GetReportMonths getMonths,
    required GetMonthlyReports getReports,
    required SendMonthlyReport sendReport,
  }) : _getMonths = getMonths,
       _getReports = getReports,
       _sendReport = sendReport,
       super(const DashboardReportsInitial());

  Future<void> load() async {
    emit(const DashboardReportsLoading());
    final months = await _getMonths(const NoParams());
    if (isClosed) return;
    await months.fold(
      (failure) async => emit(DashboardReportsFailure(failure)),
      (months) async => months.isEmpty
          ? emit(const DashboardReportsFailure(CacheFailure()))
          : _show(months, months.first),
    );
  }

  /// Ignored until the reports have loaded, and for the month shown.
  Future<void> selectMonth(ReportMonth month) async {
    final current = state;
    if (current is! DashboardReportsLoaded || month == current.month) return;
    await _show(current.months, month);
  }

  /// Ignored until the reports have loaded.
  Future<void> send(MonthlyReport report, ReportDelivery delivery) async {
    final current = state;
    if (current is! DashboardReportsLoaded) return;
    final result = await _sendReport(SendMonthlyReportParams(report, delivery));
    final latest = state;
    if (isClosed || latest is! DashboardReportsLoaded) return;
    emit(
      result.fold(
        (failure) => DashboardReportsLoaded(
          months: latest.months,
          month: latest.month,
          reports: latest.reports,
          actionFailure: failure,
        ),
        (sent) => DashboardReportsLoaded(
          months: latest.months,
          month: latest.month,
          reports: [
            for (final r in latest.reports)
              r.facility == sent.facility && r.month == sent.month ? sent : r,
          ],
          lastSent: (sent, delivery),
        ),
      ),
    );
  }

  Future<void> _show(List<ReportMonth> months, ReportMonth month) async {
    final reports = await _getReports(month);
    if (isClosed) return;
    emit(
      reports.fold(
        DashboardReportsFailure.new,
        (reports) => DashboardReportsLoaded(
          months: months,
          month: month,
          reports: reports,
        ),
      ),
    );
  }
}
