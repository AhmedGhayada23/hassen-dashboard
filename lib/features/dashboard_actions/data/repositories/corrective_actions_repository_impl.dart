import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/action_status.dart';
import '../../domain/entities/corrective_action.dart';
import '../../domain/repositories/corrective_actions_repository.dart';
import '../datasources/corrective_actions_remote_datasource.dart';

class CorrectiveActionsRepositoryImpl implements CorrectiveActionsRepository {
  final CorrectiveActionsRemoteDataSource remoteDataSource;

  const CorrectiveActionsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<CorrectiveAction>>> getActions() =>
      _guard(() async {
        final models = await remoteDataSource.getActions();
        return [for (final m in models) m.toEntity()];
      });

  @override
  Future<Either<Failure, CorrectiveAction>> updateStatus(
    String id,
    ActionStatus status,
  ) => _guard(
    () async => (await remoteDataSource.updateStatus(id, status)).toEntity(),
  );

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Right(await run());
    } on FirebaseException catch (e) {
      return Left(switch (e.code) {
        'permission-denied' => const ForbiddenFailure(),
        'unavailable' => const NetworkFailure(),
        _ => UnknownFailure(message: e.message ?? e.code),
      });
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on AppException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
