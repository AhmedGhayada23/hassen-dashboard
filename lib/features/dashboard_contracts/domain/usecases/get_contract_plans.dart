import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/contract_plan.dart';
import '../repositories/contracts_repository.dart';

class GetContractPlans extends UseCase<List<ContractPlan>, NoParams> {
  final ContractsRepository repository;

  GetContractPlans(this.repository);

  @override
  Future<Either<Failure, List<ContractPlan>>> call(NoParams params) =>
      repository.getContractPlans();
}
