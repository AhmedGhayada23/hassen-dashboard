import 'package:get_it/get_it.dart';

import 'data/datasources/contracts_local_datasource.dart';
import 'data/datasources/contracts_remote_datasource.dart';
import 'data/repositories/contracts_repository_impl.dart';
import 'domain/repositories/contracts_repository.dart';
import 'domain/usecases/decide_deal.dart';
import 'domain/usecases/get_contract_plans.dart';
import 'domain/usecases/get_deals.dart';
import 'domain/usecases/set_contract_plan.dart';
import 'presentation/cubits/dashboard_contracts_cubit.dart';

/// DataSources (contract lengths + Firebase `clients`) → Repository →
/// UseCases → Cubit. Firebase itself is registered in core.
void registerContractsDependencies(GetIt sl) {
  sl
    ..registerLazySingleton(() => const ContractsLocalDataSource())
    ..registerLazySingleton<ContractsRemoteDataSource>(
      () => FirestoreContractsDataSource(sl()),
    )
    ..registerLazySingleton<ContractsRepository>(
      () => ContractsRepositoryImpl(sl(), sl()),
    )
    ..registerLazySingleton(() => GetDeals(sl()))
    ..registerLazySingleton(() => GetContractPlans(sl()))
    ..registerLazySingleton(() => AcceptDeal(sl()))
    ..registerLazySingleton(() => RejectDeal(sl()))
    ..registerLazySingleton(() => SetContractPlan(sl()))
    ..registerFactory(
      () => DashboardContractsCubit(
        getDeals: sl(),
        getPlans: sl(),
        acceptDeal: sl(),
        rejectDeal: sl(),
        setPlan: sl(),
      ),
    );
}
