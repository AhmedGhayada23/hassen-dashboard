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
import '../config/actions_messages.dart';
import '../cubits/dashboard_actions_cubit.dart';
import '../cubits/dashboard_actions_state.dart';
import '../widgets/actions_kanban_board.dart';
import '../widgets/actions_skeleton.dart';
import '../widgets/corrective_action_details_dialog.dart';

/// HASEEN dashboard — corrective actions board, read from Firebase
/// `corrective_actions`. Expects a [DashboardActionsCubit] above it.
class DashboardActionsPage extends StatelessWidget {
  const DashboardActionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardActionsCubit, DashboardActionsState>(
      listenWhen: (previous, state) =>
          state is DashboardActionsLoaded &&
          state.actionFailure != null &&
          previous != state,
      listener: (context, state) => showErrorToast(
        context,
        ActionsMessages.moveFailed(
          (state as DashboardActionsLoaded).actionFailure!,
        ),
      ),
      builder: (context, state) => DashboardShell(
        destination: NavDestination.correctiveActions,
        // Red sidebar counter = late or due-soon actions, once loaded.
        badgeCounts: {
          if (state is DashboardActionsLoaded)
            NavDestination.correctiveActions: state.summary.attentionCount,
        },
        header: DashboardHeader(
          title: 'الإجراءات التصحيحية',
          searchHint: 'ابحث عن عميل، زيارة، أو إجراء…',
          actions: [
            NotificationsButton(
              hasUnread: demoHasUnreadNotifications,
              onPressed: () {},
            ),
          ],
        ),
        body: switch (state) {
          DashboardActionsInitial() ||
          DashboardActionsLoading() => const ActionsSkeleton(),
          DashboardActionsFailure(:final failure) => DashboardLoadError(
            onRetry: context.read<DashboardActionsCubit>().load,
            details: ActionsMessages.loadFailed(failure),
          ),
          DashboardActionsLoaded() => SingleChildScrollView(
            padding: DashboardLayoutConfig.contentPadding,
            child: ActionsKanbanBoard(
              columns: state.columns,
              onActionTap: (action) =>
                  showCorrectiveActionDetailsDialog(context, action),
            ),
          ),
        },
      ),
    );
  }
}
