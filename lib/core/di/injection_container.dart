import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../api/api_interceptors.dart';
import '../config/app_config.dart';
import '../network/network_info.dart';
import '../../features/auth/auth_injection.dart';
import '../../features/dashboard_actions/dashboard_actions_injection.dart';
import '../../features/dashboard_clients/dashboard_clients_injection.dart';
import '../../features/dashboard_contracts/dashboard_contracts_injection.dart';
import '../../features/dashboard_inspection_review/dashboard_inspection_review_injection.dart';
import '../../features/dashboard_reports/dashboard_reports_injection.dart';
import '../../features/dashboard_risks/dashboard_risks_injection.dart';
import '../../features/dashboard_settings/dashboard_settings_injection.dart';
import '../../features/dashboard_team/dashboard_team_injection.dart';
import '../../features/overview/overview_injection.dart';
import '../../features/overview/data/datasources/pending_reviews_datasource.dart';
import '../../features/visits/data/datasources/open_actions_datasource.dart';
import '../../features/visits/visits_injection.dart';
import 'open_actions_bridge.dart';
import 'pending_reviews_bridge.dart';

final sl = GetIt.instance;

/// Initialize Dependency Injection
Future<void> init() async {
  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //! External
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());

  // Firebase, shared by sign-in and the team page. Lazy: only touched once a
  // feature needs it, after Firebase.initializeApp in main.
  sl
    ..registerLazySingleton(() => FirebaseAuth.instance)
    ..registerLazySingleton(() => FirebaseFirestore.instance);

  sl.registerLazySingleton(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(ApiInterceptor());

    // Add pretty logger in debug mode
    if (AppConfig.enableLogging) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
        ),
      );
    }

    return dio;
  });

  //! Features
  registerOverviewDependencies(sl);
  registerVisitsDependencies(sl);
  registerInspectionReviewDependencies(sl);
  registerActionsDependencies(sl);
  registerClientsDependencies(sl);
  registerContractsDependencies(sl);
  registerRisksDependencies(sl);
  registerReportsDependencies(sl);
  registerSettingsDependencies(sl);
  registerTeamDependencies(sl);
  registerAuthDependencies(sl);

  //! Between features
  sl
    ..registerLazySingleton<OpenActionsDataSource>(
      () => CorrectiveActionsOpenActions(sl()),
    )
    ..registerLazySingleton<PendingReviewsDataSource>(
      () => InspectionReviewsPending(sl()),
    );
}
