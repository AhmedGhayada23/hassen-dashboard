import 'package:get_it/get_it.dart';

import 'data/datasources/auth_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/get_signed_in_admin.dart';
import 'domain/usecases/sign_in.dart';
import 'presentation/cubits/login_cubit.dart';

/// Firebase (registered in core) → DataSource → Repository → UseCases → Cubit.
void registerAuthDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => FirebaseAuthDataSource(sl(), sl()),
    )
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()))
    ..registerLazySingleton(() => SignIn(sl()))
    ..registerLazySingleton(() => GetSignedInAdmin(sl()))
    ..registerFactory(() => LoginCubit(sl()));
}
