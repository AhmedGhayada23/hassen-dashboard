import 'package:get_it/get_it.dart';

import 'data/datasources/settings_local_datasource.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'domain/repositories/settings_repository.dart';
import 'domain/usecases/get_inspection_templates.dart';
import 'domain/usecases/get_operation_rules.dart';
import 'domain/usecases/get_system_roles.dart';
import 'presentation/cubits/dashboard_settings_cubit.dart';

/// DataSource → Repository → UseCases → Cubit.
void registerSettingsDependencies(GetIt sl) {
  sl
    ..registerLazySingleton(() => const SettingsLocalDataSource())
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => GetInspectionTemplates(sl()))
    ..registerLazySingleton(() => GetSystemRoles(sl()))
    ..registerLazySingleton(() => GetOperationRules(sl()))
    ..registerFactory(
      () => DashboardSettingsCubit(
        getTemplates: sl(),
        getRoles: sl(),
        getRules: sl(),
      ),
    );
}
