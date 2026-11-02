import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'routes.dart';
import '../di/injection_container.dart';
import '../../features/auth/presentation/cubits/login_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard_actions/presentation/cubits/dashboard_actions_cubit.dart';
import '../../features/dashboard_actions/presentation/pages/dashboard_actions_page.dart';
import '../../features/dashboard_clients/presentation/cubits/dashboard_clients_cubit.dart';
import '../../features/dashboard_clients/presentation/pages/dashboard_clients_page.dart';
import '../../features/dashboard_contracts/presentation/cubits/dashboard_contracts_cubit.dart';
import '../../features/dashboard_contracts/presentation/pages/dashboard_contracts_page.dart';
import '../../features/dashboard_inspection_review/presentation/cubits/inspection_review_cubit.dart';
import '../../features/dashboard_inspection_review/presentation/pages/dashboard_inspection_review_page.dart';
import '../../features/dashboard_reports/presentation/cubits/dashboard_reports_cubit.dart';
import '../../features/dashboard_reports/presentation/pages/dashboard_reports_page.dart';
import '../../features/dashboard_risks/presentation/cubits/dashboard_risks_cubit.dart';
import '../../features/dashboard_risks/presentation/pages/dashboard_risks_page.dart';
import '../../features/dashboard_settings/presentation/cubits/dashboard_settings_cubit.dart';
import '../../features/dashboard_settings/presentation/pages/dashboard_settings_page.dart';
import '../../features/dashboard_team/presentation/cubits/dashboard_team_cubit.dart';
import '../../features/dashboard_team/presentation/pages/dashboard_team_page.dart';
import '../../features/overview/presentation/cubits/dashboard_overview_cubit.dart';
import '../../features/overview/presentation/pages/dashboard_overview_page.dart';
import '../../features/visits/presentation/cubits/dashboard_visits_cubit.dart';
import '../../features/visits/presentation/pages/dashboard_visits_page.dart';
import '../../shared/visit_scheduling/visit_scheduler.dart';

/// Application Router
class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.overview:
        return _buildRoute(
          BlocProvider(
            create: (_) => sl<DashboardOverviewCubit>()..load(),
            child: const DashboardOverviewPage(),
          ),
          settings,
        );
      case Routes.visits:
        return _buildRoute(
          BlocProvider(
            create: (_) => sl<DashboardVisitsCubit>()..load(),
            child: const DashboardVisitsPage(),
          ),
          settings,
        );
      case Routes.inspectionReview:
        return _buildRoute(
          BlocProvider(
            create: (_) => sl<InspectionReviewCubit>()..load(),
            child: const DashboardInspectionReviewPage(),
          ),
          settings,
        );
      case Routes.correctiveActions:
        return _buildRoute(
          BlocProvider(
            create: (_) => sl<DashboardActionsCubit>()..load(),
            child: const DashboardActionsPage(),
          ),
          settings,
        );
      case Routes.clients:
        return _buildRoute(
          RepositoryProvider<VisitScheduler>.value(
            value: sl<VisitScheduler>(),
            child: BlocProvider(
              create: (_) => sl<DashboardClientsCubit>()..load(),
              child: const DashboardClientsPage(),
            ),
          ),
          settings,
        );
      case Routes.contracts:
        return _buildRoute(
          BlocProvider(
            create: (_) => sl<DashboardContractsCubit>()..load(),
            child: const DashboardContractsPage(),
          ),
          settings,
        );
      case Routes.risks:
        return _buildRoute(
          BlocProvider(
            create: (_) => sl<DashboardRisksCubit>()..load(),
            child: const DashboardRisksPage(),
          ),
          settings,
        );
      case Routes.reports:
        return _buildRoute(
          BlocProvider(
            create: (_) => sl<DashboardReportsCubit>()..load(),
            child: const DashboardReportsPage(),
          ),
          settings,
        );
      case Routes.team:
        return _buildRoute(
          BlocProvider(
            create: (_) => sl<DashboardTeamCubit>()..load(),
            child: const DashboardTeamPage(),
          ),
          settings,
        );
      case Routes.settings:
        return _buildRoute(
          BlocProvider(
            create: (_) => sl<DashboardSettingsCubit>()..load(),
            child: const DashboardSettingsPage(),
          ),
          settings,
        );
      case Routes.login:
        return _buildRoute(
          BlocProvider(
            create: (_) => sl<LoginCubit>(),
            child: const LoginPage(),
          ),
          settings,
        );
      default:
        return _buildRoute(
          Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
          settings,
        );
    }
  }

  static PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static void navigateTo(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void navigateAndReplace(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void navigateAndRemoveUntil(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}
