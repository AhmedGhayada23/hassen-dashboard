import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/report_month.dart';
import '../repositories/reports_repository.dart';

class GetReportMonths extends UseCase<List<ReportMonth>, NoParams> {
  final ReportsRepository repository;

  GetReportMonths(this.repository);

  @override
  Future<Either<Failure, List<ReportMonth>>> call(NoParams params) =>
      repository.getMonths();
}
