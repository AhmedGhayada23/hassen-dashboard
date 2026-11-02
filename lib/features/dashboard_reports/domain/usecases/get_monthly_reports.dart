import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/monthly_report.dart';
import '../entities/report_month.dart';
import '../repositories/reports_repository.dart';

class GetMonthlyReports extends UseCase<List<MonthlyReport>, ReportMonth> {
  final ReportsRepository repository;

  GetMonthlyReports(this.repository);

  @override
  Future<Either<Failure, List<MonthlyReport>>> call(ReportMonth month) =>
      repository.getMonthlyReports(month);
}
