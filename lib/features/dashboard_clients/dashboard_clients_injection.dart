import 'package:get_it/get_it.dart';

import 'data/datasources/clients_remote_datasource.dart';
import 'data/repositories/clients_repository_impl.dart';
import 'domain/repositories/clients_repository.dart';
import 'domain/usecases/add_client.dart';
import 'domain/usecases/get_client_registration_options.dart';
import 'domain/usecases/get_clients.dart';
import 'presentation/cubits/dashboard_clients_cubit.dart';

/// Firebase (registered in core) → DataSource (`clients`, `sectors`,
/// `users`) → Repository → UseCases → Cubit.
void registerClientsDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<ClientsRemoteDataSource>(
      () => FirestoreClientsDataSource(sl()),
    )
    ..registerLazySingleton<ClientsRepository>(
      () => ClientsRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => GetClients(sl()))
    ..registerLazySingleton(() => GetClientRegistrationOptions(sl()))
    ..registerLazySingleton(() => AddClient(sl()))
    ..registerFactory(() => DashboardClientsCubit(sl(), sl(), sl()));
}
