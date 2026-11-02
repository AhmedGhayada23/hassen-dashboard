import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_toast.dart';
import '../../../../shared/dashboard_shell/domain/entities/nav_destination.dart';
import '../../../../shared/dashboard_shell/presentation/config/dashboard_layout_config.dart';
import '../../../../shared/dashboard_shell/presentation/config/dashboard_navigation_config.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/dashboard_load_error.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/dashboard_shell.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/header/dashboard_header.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/header/notifications_button.dart';
import '../config/visits_messages.dart';
import '../cubits/dashboard_visits_cubit.dart';
import '../cubits/dashboard_visits_state.dart';
import '../widgets/schedule_visit_dialog.dart';
import '../widgets/visit_details_dialog.dart';
import '../widgets/visits_legend.dart';
import '../widgets/visits_page_header.dart';
import '../widgets/visits_schedule_grid.dart';
import '../widgets/visits_skeleton.dart';

/// HASEEN dashboard — weekly visit schedule. Expects a [DashboardVisitsCubit] above it.
class DashboardVisitsPage extends StatelessWidget {
  const DashboardVisitsPage({super.key});

  static bool _hasOutcome(
    DashboardVisitsState previous,
    DashboardVisitsState current,
  ) =>
      current is DashboardVisitsLoaded &&
      previous != current &&
      (current.lastScheduled != null || current.actionFailure != null);

  static void _showOutcome(BuildContext context, DashboardVisitsState state) {
    if (state is! DashboardVisitsLoaded) return;
    if (state.lastScheduled case final visit?) {
      showSuccessToast(context, VisitsMessages.scheduled(visit));
    } else if (state.actionFailure case final failure?) {
      showErrorToast(context, VisitsMessages.scheduleFailed(failure));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      destination: NavDestination.visitSchedule,
      header: DashboardHeader(
        title: 'جدول الزيارات',
        searchHint: 'ابحث عن عميل، زيارة، أو إجراء…',
        actions: [
          NotificationsButton(
            hasUnread: demoHasUnreadNotifications,
            onPressed: () {},
          ),
        ],
      ),
      body: BlocConsumer<DashboardVisitsCubit, DashboardVisitsState>(
        listenWhen: _hasOutcome,
        listener: _showOutcome,
        builder: (context, state) => switch (state) {
          DashboardVisitsInitial() ||
          DashboardVisitsLoading() => const VisitsSkeleton(),
          DashboardVisitsFailure(:final failure) => DashboardLoadError(
            onRetry: context.read<DashboardVisitsCubit>().load,
            details: VisitsMessages.loadFailed(failure),
          ),
          DashboardVisitsLoaded() => _VisitsContent(state: state),
        },
      ),
    );
  }
}

class _VisitsContent extends StatelessWidget {
  final DashboardVisitsLoaded state;

  const _VisitsContent({required this.state});

  Future<void> _scheduleVisit(BuildContext context) async {
    // The form needs someone to assign and somewhere to go.
    if (state.schedule.inspectors.isEmpty) {
      showErrorToast(context, VisitsMessages.noInspectors);
      return;
    }
    if (state.options.facilities.isEmpty) {
      showErrorToast(context, VisitsMessages.noFacilities);
      return;
    }
    final cubit = context.read<DashboardVisitsCubit>();
    final visit = await showScheduleVisitDialog(
      context,
      schedule: state.schedule,
      options: state.options,
    );
    if (visit != null) await cubit.scheduleVisit(visit);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DashboardVisitsCubit>();
    return SingleChildScrollView(
      padding: DashboardLayoutConfig.contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          VisitsPageHeader(
            weekLabel: state.schedule.weekLabel,
            onScheduleVisit: () => _scheduleVisit(context),
            onPreviousWeek: cubit.showPreviousWeek,
            onNextWeek: cubit.showNextWeek,
            onCurrentWeek: state.weekOffset == 0 ? null : cubit.showCurrentWeek,
          ),
          SizedBox(height: DashboardLayoutConfig.sectionGap),
          VisitsScheduleGrid(
            schedule: state.schedule,
            onVisitTap: (visit) => showVisitDetailsDialog(context, visit),
          ),
          SizedBox(height: DashboardLayoutConfig.sectionGap),
          const VisitsLegend(),
        ],
      ),
    );
  }
}
