import 'package:get_it/get_it.dart';

import 'data/datasources/team_remote_datasource.dart';
import 'data/repositories/team_repository_impl.dart';
import 'domain/repositories/team_repository.dart';
import 'domain/usecases/add_employee.dart';
import 'domain/usecases/get_employee_roles.dart';
import 'domain/usecases/get_team_members.dart';
import 'presentation/cubits/dashboard_team_cubit.dart';

/// Firebase (registered in core) → DataSource (`users`, `roles`) →
/// Repository → UseCases → Cubit.
void registerTeamDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<TeamRemoteDataSource>(
      () => FirebaseTeamDataSource(sl()),
    )
    ..registerLazySingleton<TeamRepository>(() => TeamRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetTeamMembers(sl()))
    ..registerLazySingleton(() => GetEmployeeRoles(sl()))
    ..registerLazySingleton(() => AddEmployee(sl()))
    ..registerFactory(() => DashboardTeamCubit(sl(), sl(), sl()));
}
