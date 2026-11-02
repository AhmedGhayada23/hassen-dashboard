import 'package:get_it/get_it.dart';

import 'data/datasources/overview_remote_datasource.dart';
import 'data/repositories/dashboard_repository_impl.dart';
import 'domain/repositories/dashboard_repository.dart';
import 'domain/usecases/get_dashboard_overview.dart';
import 'presentation/cubits/dashboard_overview_cubit.dart';

/// DataSources (Firebase `clients`, `visits`, `risks`, `corrective_actions`
/// + the reports awaiting review) → Repository → UseCase → Cubit. Firebase
/// itself, and the pending reviews (`PendingReviewsDataSource`), are
/// registered in core.
void registerOverviewDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<OverviewRemoteDataSource>(
      () => FirestoreOverviewDataSource(sl()),
    )
    ..registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(sl(), sl()),
    )
    ..registerLazySingleton(() => GetDashboardOverview(sl()))
    ..registerFactory(() => DashboardOverviewCubit(sl()));
}
