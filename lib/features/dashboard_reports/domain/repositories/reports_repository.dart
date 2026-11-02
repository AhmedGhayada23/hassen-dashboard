import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/monthly_report.dart';
import '../entities/report_delivery.dart';
import '../entities/report_month.dart';

abstract interface class ReportsRepository {
  /// The months reports can be viewed for, newest first.
  Future<Either<Failure, List<ReportMonth>>> getMonths();

  /// One report per contracted facility for [month], in facility order.
  Future<Either<Failure, List<MonthlyReport>>> getMonthlyReports(
    ReportMonth month,
  );

  /// Records [report] as sent to [delivery] on [sentOn] (`yyyy-MM-dd`) and
  /// returns it.
  Future<Either<Failure, MonthlyReport>> markSent(
    MonthlyReport report,
    ReportDelivery delivery,
    String sentOn,
  );
}
