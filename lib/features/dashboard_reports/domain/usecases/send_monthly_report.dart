import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/monthly_report.dart';
import '../entities/report_delivery.dart';
import '../failures/report_failures.dart';
import '../repositories/reports_repository.dart';

/// Emails a report — for now, records it as sent today; the actual email
/// needs a mail service on the backend.
class SendMonthlyReport
    extends UseCase<MonthlyReport, SendMonthlyReportParams> {
  final ReportsRepository repository;
  final DateTime Function() _clock;

  SendMonthlyReport(this.repository, {DateTime Function() clock = DateTime.now})
    : _clock = clock;

  @override
  Future<Either<Failure, MonthlyReport>> call(
    SendMonthlyReportParams params,
  ) async {
    if (!params.delivery.isValid) {
      return const Left(InvalidReportRecipientFailure());
    }
    final today = _clock();
    return repository.markSent(
      params.report,
      params.delivery,
      '${today.year}-${today.month.toString().padLeft(2, '0')}-'
      '${today.day.toString().padLeft(2, '0')}',
    );
  }
}

class SendMonthlyReportParams extends Equatable {
  final MonthlyReport report;
  final ReportDelivery delivery;

  const SendMonthlyReportParams(this.report, this.delivery);

  @override
  List<Object> get props => [report, delivery];
}
