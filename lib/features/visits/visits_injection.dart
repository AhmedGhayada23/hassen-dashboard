import 'package:get_it/get_it.dart';

import '../../shared/visit_scheduling/visit_scheduler.dart';
import 'data/datasources/visits_local_datasource.dart';
import 'data/datasources/visits_remote_datasource.dart';
import 'data/repositories/visits_repository_impl.dart';
import 'domain/repositories/visits_repository.dart';
import 'domain/usecases/get_visit_schedule.dart';
import 'domain/usecases/get_visit_scheduling_options.dart';
import 'domain/usecases/schedule_visit.dart';
import 'presentation/cubits/dashboard_visits_cubit.dart';
import 'presentation/scheduling/dialog_visit_scheduler.dart';

/// DataSources (week, types and templates + Firebase `users`, `visits`,
/// `clients`) → Repository → UseCases → Cubit. Firebase itself, and the open
/// corrective actions (`OpenActionsDataSource`), are registered in core.
void registerVisitsDependencies(GetIt sl) {
  sl
    ..registerLazySingleton(() => const VisitsLocalDataSource())
    ..registerLazySingleton<VisitsRemoteDataSource>(
      () => FirestoreVisitsDataSource(sl()),
    )
    ..registerLazySingleton<VisitsRepository>(
      () => VisitsRepositoryImpl(sl(), sl(), sl()),
    )
    ..registerLazySingleton(() => GetVisitSchedule(sl()))
    ..registerLazySingleton(() => GetVisitSchedulingOptions(sl()))
    ..registerLazySingleton(() => ScheduleVisit(sl()))
    ..registerFactory(() => DashboardVisitsCubit(sl(), sl(), sl()))
    // Booking from other pages (e.g. a client's), through the same form.
    ..registerLazySingleton<VisitScheduler>(
      () => DialogVisitScheduler(sl(), sl(), sl()),
    );
}
