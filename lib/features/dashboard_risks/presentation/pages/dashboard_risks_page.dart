import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/dashboard_shell/domain/entities/nav_destination.dart';
import '../../../../shared/dashboard_shell/presentation/config/dashboard_navigation_config.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/dashboard_load_error.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/dashboard_shell.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/header/dashboard_header.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/header/notifications_button.dart';
import '../config/risks_messages.dart';
import '../cubits/dashboard_risks_cubit.dart';
import '../cubits/dashboard_risks_state.dart';
import '../widgets/risk_register_layout.dart';
import '../widgets/risks_skeleton.dart';

/// HASEEN dashboard — risk register, read from Firebase `risks`. Expects a
/// [DashboardRisksCubit] above it.
class DashboardRisksPage extends StatelessWidget {
  const DashboardRisksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      destination: NavDestination.riskRegister,
      header: DashboardHeader(
        title: 'سجل المخاطر',
        searchHint: 'ابحث عن عميل، زيارة، أو إجراء…',
        actions: [
          NotificationsButton(
            hasUnread: demoHasUnreadNotifications,
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<DashboardRisksCubit, DashboardRisksState>(
        builder: (context, state) => switch (state) {
          DashboardRisksInitial() ||
          DashboardRisksLoading() => const RisksSkeleton(),
          DashboardRisksFailure(:final failure) => DashboardLoadError(
            onRetry: context.read<DashboardRisksCubit>().load,
            details: RisksMessages.loadFailed(failure),
          ),
          DashboardRisksLoaded() => RiskRegisterLayout(
            risks: state.risks,
            matrix: state.matrix,
            selected: state.selectedRisk,
            emptyMessage: RisksMessages.noRisks,
            onRiskTap: (risk) =>
                context.read<DashboardRisksCubit>().selectRisk(risk.id),
          ),
        },
      ),
    );
  }
}
