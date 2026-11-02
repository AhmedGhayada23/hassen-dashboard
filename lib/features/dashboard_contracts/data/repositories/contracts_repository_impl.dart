import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/contract_plan.dart';
import '../../domain/entities/deal.dart';
import '../../domain/entities/deal_status.dart';
import '../../domain/repositories/contracts_repository.dart';
import '../datasources/contracts_local_datasource.dart';
import '../datasources/contracts_remote_datasource.dart';
import '../models/deal_model.dart';

class ContractsRepositoryImpl implements ContractsRepository {
  final ContractsLocalDataSource localDataSource;
  final ContractsRemoteDataSource remoteDataSource;

  const ContractsRepositoryImpl(this.localDataSource, this.remoteDataSource);

  @override
  Future<Either<Failure, List<Deal>>> getDeals() => _guard(
    () async => [
      for (final m in await remoteDataSource.getDeals()) m.toEntity(),
    ],
  );

  @override
  Future<Either<Failure, List<ContractPlan>>> getContractPlans() => _guard(
    () async => [
      for (final m in await localDataSource.getContractPlans()) m.toEntity(),
    ],
  );

  @override
  Future<Either<Failure, Deal>> acceptDeal(Deal deal, DateTime startDate) =>
      _guard(() async {
        await remoteDataSource.updateDeal(
          deal.id,
          DealModel.acceptance(startDate),
        );
        return _with(deal, DealStatus.accepted, startDate: startDate);
      });

  @override
  Future<Either<Failure, Deal>> rejectDeal(Deal deal) => _guard(() async {
    await remoteDataSource.updateDeal(deal.id, DealModel.rejection());
    return _with(deal, DealStatus.rejected);
  });

  @override
  Future<Either<Failure, Deal>> setContractPlan(
    Deal deal,
    ContractPlan plan,
    DateTime startDate,
  ) => _guard(() async {
    await remoteDataSource.updateDeal(
      deal.id,
      DealModel.contract(plan, startDate),
    );
    return _with(deal, deal.status, planId: plan.id, startDate: startDate);
  });

  static Deal _with(
    Deal deal,
    DealStatus status, {
    String? planId,
    DateTime? startDate,
  }) => Deal(
    id: deal.id,
    number: deal.number,
    client: deal.client,
    date: deal.date,
    status: status,
    planId: planId,
    startDate: startDate,
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
    } on AppException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
