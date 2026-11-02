import 'package:hassen_dashboard/features/dashboard_contracts/data/datasources/contracts_local_datasource.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/data/repositories/contracts_repository_impl.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/domain/repositories/contracts_repository.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/domain/usecases/decide_deal.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/domain/usecases/get_contract_plans.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/domain/usecases/get_deals.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/domain/usecases/set_contract_plan.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/presentation/cubits/dashboard_contracts_cubit.dart';

import 'fake_contracts_remote_datasource.dart';

/// The day contracts accepted in tests start on.
final contractsToday = DateTime(2026, 11, 2, 10, 30);

/// A repository over [remote] (by default a fresh fake `clients` collection).
ContractsRepository buildContractsRepository([
  FakeContractsRemoteDataSource? remote,
]) => ContractsRepositoryImpl(
  const ContractsLocalDataSource(),
  remote ?? FakeContractsRemoteDataSource(),
);

/// A cubit over [repository] whose clock reads [contractsToday].
DashboardContractsCubit buildContractsCubit([ContractsRepository? repository]) {
  final repo = repository ?? buildContractsRepository();
  return DashboardContractsCubit(
    getDeals: GetDeals(repo),
    getPlans: GetContractPlans(repo),
    acceptDeal: AcceptDeal(repo, clock: () => contractsToday),
    rejectDeal: RejectDeal(repo),
    setPlan: SetContractPlan(repo, clock: () => contractsToday),
  );
}
