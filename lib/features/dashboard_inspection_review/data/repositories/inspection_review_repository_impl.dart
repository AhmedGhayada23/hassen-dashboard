import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/inspection.dart';
import '../../domain/entities/inspection_decision.dart';
import '../../domain/repositories/inspection_review_repository.dart';
import '../datasources/inspection_review_local_datasource.dart';

class InspectionReviewRepositoryImpl implements InspectionReviewRepository {
  final InspectionReviewLocalDataSource localDataSource;

  const InspectionReviewRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<Inspection>>> getInspections() =>
      _guard(() async {
        final models = await localDataSource.getInspections();
        return [for (final m in models) m.toEntity()];
      });

  @override
  Future<Either<Failure, Inspection>> updateDecision(
    String id,
    InspectionDecision decision,
  ) => _guard(
    () async => (await localDataSource.updateDecision(id, decision)).toEntity(),
  );

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Right(await run());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on AppException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
