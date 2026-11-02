import 'package:get_it/get_it.dart';

import 'data/datasources/inspection_review_local_datasource.dart';
import 'data/repositories/inspection_review_repository_impl.dart';
import 'domain/repositories/inspection_review_repository.dart';
import 'domain/usecases/approve_inspection.dart';
import 'domain/usecases/get_inspections.dart';
import 'domain/usecases/reset_inspection_decision.dart';
import 'domain/usecases/return_inspection.dart';
import 'presentation/cubits/inspection_review_cubit.dart';

/// DataSource → Repository → UseCases → Cubit.
/// The data source is a singleton, so review decisions survive page changes.
void registerInspectionReviewDependencies(GetIt sl) {
  sl
    ..registerLazySingleton(() => InspectionReviewLocalDataSource())
    ..registerLazySingleton<InspectionReviewRepository>(
      () => InspectionReviewRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => GetInspections(sl()))
    ..registerLazySingleton(() => ApproveInspection(sl()))
    ..registerLazySingleton(() => ReturnInspection(sl()))
    ..registerLazySingleton(() => ResetInspectionDecision(sl()))
    ..registerFactory(
      () => InspectionReviewCubit(
        getInspections: sl(),
        approveInspection: sl(),
        returnInspection: sl(),
        resetDecision: sl(),
      ),
    );
}
