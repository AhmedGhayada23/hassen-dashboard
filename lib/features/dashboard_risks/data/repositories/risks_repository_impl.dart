import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/risk.dart';
import '../../domain/repositories/risks_repository.dart';
import '../datasources/risks_remote_datasource.dart';

class RisksRepositoryImpl implements RisksRepository {
  final RisksRemoteDataSource remoteDataSource;

  const RisksRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Risk>>> getRisks() async {
    try {
      final models = await remoteDataSource.getRisks();
      return Right([for (final m in models) m.toEntity()]);
    } on FirebaseException catch (e) {
      return Left(switch (e.code) {
        'permission-denied' => const ForbiddenFailure(),
        'unavailable' => const NetworkFailure(),
        _ => UnknownFailure(message: e.message ?? e.code),
      });
    }
  }
}
