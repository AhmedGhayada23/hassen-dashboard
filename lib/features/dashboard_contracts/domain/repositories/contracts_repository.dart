import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/contract_plan.dart';
import '../entities/deal.dart';

abstract interface class ContractsRepository {
  /// One deal per client, oldest client first.
  Future<Either<Failure, List<Deal>>> getDeals();

  /// The contract lengths on offer, shortest first.
  Future<Either<Failure, List<ContractPlan>>> getContractPlans();

  /// Accepts [deal] from [startDate], with no length yet, and returns it.
  Future<Either<Failure, Deal>> acceptDeal(Deal deal, DateTime startDate);

  /// Rejects [deal], dropping any contract it had, and returns it.
  Future<Either<Failure, Deal>> rejectDeal(Deal deal);

  /// Sets [deal]'s contract to [plan] from [startDate] and returns it.
  Future<Either<Failure, Deal>> setContractPlan(
    Deal deal,
    ContractPlan plan,
    DateTime startDate,
  );
}
