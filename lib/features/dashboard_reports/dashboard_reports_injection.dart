import 'package:get_it/get_it.dart';

import 'data/datasources/reports_local_datasource.dart';
import 'data/datasources/reports_remote_datasource.dart';
import 'data/repositories/reports_repository_impl.dart';
import 'domain/repositories/reports_repository.dart';
import 'domain/usecases/get_monthly_reports.dart';
import 'domain/usecases/get_report_months.dart';
import 'domain/usecases/send_monthly_report.dart';
import 'presentation/cubits/dashboard_reports_cubit.dart';

/// DataSources (months from the clock + Firebase `clients`, `visits`,
/// `risks`, `corrective_actions`, `report_deliveries`) → Repository →
/// UseCases → Cubit. Firebase itself is registered in core.
void registerReportsDependencies(GetIt sl) {
  sl
    ..registerLazySingleton(() => const ReportsLocalDataSource())
    ..registerLazySingleton<ReportsRemoteDataSource>(
      () => FirestoreReportsDataSource(sl()),
    )
    ..registerLazySingleton<ReportsRepository>(
      () => ReportsRepositoryImpl(sl(), sl()),
    )
    ..registerLazySingleton(() => GetReportMonths(sl()))
    ..registerLazySingleton(() => GetMonthlyReports(sl()))
    ..registerLazySingleton(() => SendMonthlyReport(sl()))
    ..registerFactory(
      () => DashboardReportsCubit(
        getMonths: sl(),
        getReports: sl(),
        sendReport: sl(),
      ),
    );
}
