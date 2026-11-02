import 'package:get_it/get_it.dart';

import 'data/datasources/corrective_actions_remote_datasource.dart';
import 'data/repositories/corrective_actions_repository_impl.dart';
import 'domain/repositories/corrective_actions_repository.dart';
import 'domain/usecases/get_corrective_actions.dart';
import 'domain/usecases/update_action_status.dart';
import 'presentation/cubits/dashboard_actions_cubit.dart';

/// DataSource (Firebase `corrective_actions`) → Repository → UseCases →
/// Cubit. Firebase itself is registered in core.
void registerActionsDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<CorrectiveActionsRemoteDataSource>(
      () => FirestoreCorrectiveActionsDataSource(sl()),
    )
    ..registerLazySingleton<CorrectiveActionsRepository>(
      () => CorrectiveActionsRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => GetCorrectiveActions(sl()))
    ..registerLazySingleton(() => UpdateActionStatus(sl()))
    ..registerFactory(
      () => DashboardActionsCubit(getActions: sl(), updateStatus: sl()),
    );
}
