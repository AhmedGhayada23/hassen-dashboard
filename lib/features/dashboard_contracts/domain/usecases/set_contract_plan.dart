import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/contract_plan.dart';
import '../entities/deal.dart';
import '../failures/deal_failures.dart';
import '../repositories/contracts_repository.dart';
import 'decide_deal.dart';

/// Sets how long an accepted deal's contract runs, from its start date — or
/// from today for a client marked contracted without one.
class SetContractPlan extends UseCase<Deal, SetContractPlanParams> {
  final ContractsRepository repository;
  final DateTime Function() _clock;

  SetContractPlan(this.repository, {DateTime Function() clock = DateTime.now})
    : _clock = clock;

  @override
  Future<Either<Failure, Deal>> call(SetContractPlanParams params) async {
    final deal = params.deal;
    if (!deal.isAccepted) return const Left(DealNotAcceptedFailure());
    return repository.setContractPlan(
      deal,
      params.plan,
      deal.startDate ?? today(_clock),
    );
  }
}

class SetContractPlanParams extends Equatable {
  final Deal deal;
  final ContractPlan plan;

  const SetContractPlanParams(this.deal, this.plan);

  @override
  List<Object> get props => [deal, plan];
}
