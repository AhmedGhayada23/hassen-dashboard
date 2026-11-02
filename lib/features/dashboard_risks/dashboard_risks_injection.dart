import 'package:get_it/get_it.dart';

import 'data/datasources/risks_remote_datasource.dart';
import 'data/repositories/risks_repository_impl.dart';
import 'domain/repositories/risks_repository.dart';
import 'domain/usecases/get_risks.dart';
import 'presentation/cubits/dashboard_risks_cubit.dart';

/// DataSource (Firebase `risks`) → Repository → UseCase → Cubit. Firebase
/// itself is registered in core.
void registerRisksDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<RisksRemoteDataSource>(
      () => FirestoreRisksDataSource(sl()),
    )
    ..registerLazySingleton<RisksRepository>(() => RisksRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetRisks(sl()))
    ..registerFactory(() => DashboardRisksCubit(sl()));
}
