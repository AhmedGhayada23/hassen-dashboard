import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_toast.dart';
import '../../../../shared/dashboard_shell/domain/entities/nav_destination.dart';
import '../../../../shared/dashboard_shell/presentation/config/dashboard_layout_config.dart';
import '../../../../shared/dashboard_shell/presentation/config/dashboard_navigation_config.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/dashboard_load_error.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/dashboard_shell.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/header/dashboard_header.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/header/notifications_button.dart';
import '../../domain/entities/team_member.dart';
import '../config/team_messages.dart';
import '../cubits/dashboard_team_cubit.dart';
import '../cubits/dashboard_team_state.dart';
import '../widgets/add_employee_dialog.dart';
import '../widgets/team_empty_state.dart';
import '../widgets/team_grid.dart';
import '../widgets/team_page_header.dart';
import '../widgets/team_skeleton.dart';

/// HASEEN dashboard — team roster. Expects a [DashboardTeamCubit] above it.
class DashboardTeamPage extends StatelessWidget {
  const DashboardTeamPage({super.key});

  static bool _hasOutcome(
    DashboardTeamState previous,
    DashboardTeamState current,
  ) =>
      current is DashboardTeamLoaded &&
      previous != current &&
      (current.lastAdded != null || current.actionFailure != null);

  static void _showOutcome(BuildContext context, DashboardTeamState state) {
    if (state is! DashboardTeamLoaded) return;
    if (state.lastAdded case final member?) {
      showSuccessToast(context, TeamMessages.added(member));
    } else if (state.actionFailure case final failure?) {
      showErrorToast(context, TeamMessages.addFailed(failure));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      destination: NavDestination.team,
      header: DashboardHeader(
        title: 'الفريق',
        searchHint: 'ابحث عن عميل، زيارة، أو إجراء…',
        actions: [
          NotificationsButton(
            hasUnread: demoHasUnreadNotifications,
            onPressed: () {},
          ),
        ],
      ),
      body: BlocConsumer<DashboardTeamCubit, DashboardTeamState>(
        listenWhen: _hasOutcome,
        listener: _showOutcome,
        builder: (context, state) => switch (state) {
          DashboardTeamInitial() ||
          DashboardTeamLoading() => const TeamSkeleton(),
          DashboardTeamFailure(:final failure) => DashboardLoadError(
            onRetry: context.read<DashboardTeamCubit>().load,
            details: TeamMessages.loadFailed(failure),
          ),
          DashboardTeamLoaded() => _TeamContent(state: state),
        },
      ),
    );
  }
}

class _TeamContent extends StatelessWidget {
  final DashboardTeamLoaded state;

  const _TeamContent({required this.state});

  Future<void> _addEmployee(BuildContext context) async {
    if (state.roles.isEmpty) {
      showErrorToast(context, TeamMessages.noRoles);
      return;
    }
    final cubit = context.read<DashboardTeamCubit>();
    final employee = await showAddEmployeeDialog(context, roles: state.roles);
    if (employee != null) await cubit.addEmployee(employee);
  }

  Future<void> _copyPassword(BuildContext context, TeamMember member) async {
    final password = member.temporaryPassword;
    if (password == null) return;
    await Clipboard.setData(ClipboardData(text: password));
    if (context.mounted) showSuccessToast(context, TeamMessages.passwordCopied);
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: DashboardLayoutConfig.contentPadding,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TeamPageHeader(
          memberCount: state.members.length,
          isAdding: state.isAdding,
          onAddEmployee: () => _addEmployee(context),
        ),
        SizedBox(height: DashboardLayoutConfig.sectionGap),
        if (state.members.isEmpty)
          const TeamEmptyState()
        else
          TeamGrid(
            members: state.members,
            revealedPasswordIds: state.revealedPasswordIds,
            onTogglePassword: context
                .read<DashboardTeamCubit>()
                .togglePasswordVisibility,
            onCopyPassword: (member) => _copyPassword(context, member),
          ),
      ],
    ),
  );
}
