import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/monthly_report.dart';
import '../../domain/entities/report_delivery.dart';
import '../../domain/entities/report_month.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_local_datasource.dart';
import '../datasources/reports_remote_datasource.dart';
import '../models/report_activity_model.dart';
import '../models/report_delivery_model.dart';
import '../models/report_facility_model.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsLocalDataSource localDataSource;
  final ReportsRemoteDataSource remoteDataSource;

  const ReportsRepositoryImpl(this.localDataSource, this.remoteDataSource);

  @override
  Future<Either<Failure, List<ReportMonth>>> getMonths() =>
      _guard(localDataSource.getMonths);

  /// Each contracted facility with its month's activities, oldest first, and
  /// whether its report was sent.
  @override
  Future<Either<Failure, List<MonthlyReport>>> getMonthlyReports(
    ReportMonth month,
  ) => _guard(() async {
    // Future.wait (unlike a record's .wait) rethrows the first error as is,
    // so a FirebaseException still reaches _guard.
    final results = await Future.wait<Object>([
      remoteDataSource.getFacilities(),
      remoteDataSource.getActivities(month.id),
      remoteDataSource.getSentDates(month.id),
    ]);
    final facilities = results[0] as List<ReportFacilityModel>;
    final activities = results[1] as List<ReportActivityModel>;
    final sent = results[2] as Map<String, String>;
    return [
      for (final facility in facilities)
        MonthlyReport(
          facility: facility.toEntity(),
          month: month,
          activities: [
            for (final a
                in activities.where((a) => a.facility == facility.name).toList()
                  ..sort((a, b) => a.date.compareTo(b.date)))
              a.toEntity(),
          ],
          sentOn: sent[facility.id],
        ),
    ];
  });

  /// Records the delivery in Firebase; the email itself needs a mail
  /// service on the backend.
  @override
  Future<Either<Failure, MonthlyReport>> markSent(
    MonthlyReport report,
    ReportDelivery delivery,
    String sentOn,
  ) => _guard(() async {
    await remoteDataSource.recordDelivery(
      ReportDeliveryModel.idFor(report.facility.id, report.month.id),
      ReportDeliveryModel.document(report, delivery, sentOn),
    );
    return report.sent(sentOn);
  });

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Right(await run());
    } on FirebaseException catch (e) {
      return Left(switch (e.code) {
        'permission-denied' => const ForbiddenFailure(),
        'unavailable' => const NetworkFailure(),
        _ => UnknownFailure(message: e.message ?? e.code),
      });
    } on AppException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
