import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/routes.dart';
import '../../../../shared/dashboard_shell/domain/entities/nav_destination.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/dashboard_load_error.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/dashboard_shell.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/demo_snack_bar.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/header/dashboard_header.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/header/notifications_button.dart';
import '../config/overview_messages.dart';
import '../cubits/dashboard_overview_cubit.dart';
import '../cubits/dashboard_overview_state.dart';
import '../widgets/overview_content.dart';
import '../widgets/overview_skeleton.dart';

/// HASEEN dashboard — overview, summarised from the other pages' data.
/// Expects a [DashboardOverviewCubit] above it.
class DashboardOverviewPage extends StatelessWidget {
  const DashboardOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      destination: NavDestination.overview,
      header: DashboardHeader(
        title: 'نظرة عامة',
        searchHint: 'ابحث عن عميل، زيارة، أو إجراء…',
        actions: [
          BlocSelector<DashboardOverviewCubit, DashboardOverviewState, bool>(
            selector: (state) =>
                state is DashboardOverviewLoaded &&
                state.overview.hasUnreadNotifications,
            builder: (context, hasUnread) =>
                NotificationsButton(hasUnread: hasUnread, onPressed: () {}),
          ),
        ],
      ),
      body: BlocBuilder<DashboardOverviewCubit, DashboardOverviewState>(
        builder: (context, state) => switch (state) {
          DashboardOverviewInitial() ||
          DashboardOverviewLoading() => const OverviewSkeleton(),
          DashboardOverviewFailure(:final failure) => DashboardLoadError(
            onRetry: context.read<DashboardOverviewCubit>().load,
            details: OverviewMessages.loadFailed(failure),
          ),
          DashboardOverviewLoaded(:final overview) => OverviewContent(
            overview: overview,
            onKpiTap: (kpi) => showDemoSnackBar(context, 'فتح ${kpi.label}'),
            onOpenReview: () => Navigator.of(
              context,
            ).pushReplacementNamed(Routes.inspectionReview),
            onManageContracts: () =>
                Navigator.of(context).pushReplacementNamed(Routes.contracts),
          ),
        },
      ),
    );
  }
}
