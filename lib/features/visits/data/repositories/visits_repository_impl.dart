import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/visit.dart';
import '../../domain/entities/visit_schedule.dart';
import '../../domain/entities/visit_scheduling_options.dart';
import '../../domain/repositories/visits_repository.dart';
import '../datasources/open_actions_datasource.dart';
import '../datasources/visits_local_datasource.dart';
import '../datasources/visits_remote_datasource.dart';
import '../models/visit_model.dart';
import '../models/visit_schedule_model.dart';

class VisitsRepositoryImpl implements VisitsRepository {
  final VisitsLocalDataSource localDataSource;
  final VisitsRemoteDataSource remoteDataSource;
  final OpenActionsDataSource openActionsDataSource;

  const VisitsRepositoryImpl(
    this.localDataSource,
    this.remoteDataSource,
    this.openActionsDataSource,
  );

  /// The week with the Firebase inspectors (rows) and its visits.
  @override
  Future<Either<Failure, VisitSchedule>> getSchedule({int weekOffset = 0}) =>
      _guard(() async => (await _schedule(weekOffset)).toEntity());

  /// The Firebase clients as facilities, with the visit types and what a
  /// visit's tasks are drawn from.
  @override
  Future<Either<Failure, VisitSchedulingOptions>> getSchedulingOptions() =>
      _guard(() async {
        final types = await localDataSource.getVisitTypes();
        final templates = await localDataSource.getInspectionTemplates();
        return types.withFacilities(
          await remoteDataSource.getFacilities(),
          taskCatalog: templates.withOpenActions(
            await openActionsDataSource.getOpenActions(),
          ),
        );
      });

  @override
  Future<Either<Failure, VisitSchedule>> addVisit(
    Visit visit, {
    int weekOffset = 0,
  }) => _guard(() async {
    await remoteDataSource.addVisit(VisitModel.fromEntity(visit));
    return (await _schedule(weekOffset)).toEntity();
  });

  /// Throws [ParseException] when the week is malformed.
  Future<VisitScheduleModel> _schedule(int weekOffset) async {
    final week = await localDataSource.getWeek(offset: weekOffset);
    final inspectors = await remoteDataSource.getInspectors();
    final (String, String) range;
    try {
      range = VisitScheduleModel.dateRangeOf(week);
    } catch (_) {
      throw ParseException();
    }
    final visits = await remoteDataSource.getVisits(
      from: range.$1,
      to: range.$2,
    );
    try {
      return VisitScheduleModel.fromParts(
        weekJson: week,
        inspectors: inspectors,
        visits: visits,
      );
    } catch (_) {
      throw ParseException();
    }
  }

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
