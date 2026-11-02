import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../shared/dashboard_shell/domain/entities/nav_destination.dart';
import '../../../../shared/dashboard_shell/presentation/config/dashboard_layout_config.dart';
import '../../../../shared/dashboard_shell/presentation/config/dashboard_navigation_config.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/dashboard_load_error.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/dashboard_shell.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/header/dashboard_header.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/header/notifications_button.dart';
import '../../domain/entities/deal.dart';
import '../config/contracts_messages.dart';
import '../cubits/dashboard_contracts_cubit.dart';
import '../cubits/dashboard_contracts_state.dart';
import '../widgets/deals_skeleton.dart';
import '../widgets/deals_table.dart';

/// HASEEN dashboard — quotes & contracts: every client with the decision on
/// its quote (which can be changed) and the contract length. Expects a
/// [DashboardContractsCubit] above it.
class DashboardContractsPage extends StatelessWidget {
  const DashboardContractsPage({super.key});

  static bool _hasOutcome(
    DashboardContractsState previous,
    DashboardContractsState current,
  ) =>
      current is DashboardContractsLoaded &&
      previous != current &&
      (current.lastDecided != null || current.actionFailure != null);

  static void _showOutcome(
    BuildContext context,
    DashboardContractsState state,
  ) {
    if (state is! DashboardContractsLoaded) return;
    if (state.lastDecided case final deal?) {
      showSuccessToast(context, ContractsMessages.decided(deal));
    } else if (state.actionFailure case final failure?) {
      showErrorToast(context, ContractsMessages.actionFailed(failure));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      destination: NavDestination.contracts,
      header: DashboardHeader(
        title: 'العروض والعقود',
        searchHint: 'ابحث عن عميل، زيارة، أو إجراء…',
        actions: [
          NotificationsButton(
            hasUnread: demoHasUnreadNotifications,
            onPressed: () {},
          ),
        ],
      ),
      body: BlocConsumer<DashboardContractsCubit, DashboardContractsState>(
        listenWhen: _hasOutcome,
        listener: _showOutcome,
        builder: (context, state) => switch (state) {
          DashboardContractsInitial() || DashboardContractsLoading() =>
            const _ContractsBody(table: DealsSkeleton()),
          DashboardContractsFailure(:final failure) => DashboardLoadError(
            onRetry: context.read<DashboardContractsCubit>().load,
            details: ContractsMessages.loadFailed(failure),
          ),
          DashboardContractsLoaded() => _ContractsBody(
            table: _LoadedTable(state: state),
          ),
        },
      ),
    );
  }
}

/// The intro line above the table (or its skeleton).
class _ContractsBody extends StatelessWidget {
  final Widget table;

  const _ContractsBody({required this.table});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: DashboardLayoutConfig.contentPadding,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          ContractsMessages.intro,
          style: TextStyle(fontSize: 12.5.sp, color: HaseenColors.muted),
        ),
        SizedBox(height: 14.h),
        table,
      ],
    ),
  );
}

class _LoadedTable extends StatelessWidget {
  final DashboardContractsLoaded state;

  const _LoadedTable({required this.state});

  /// Cancelling a signed contract is asked first; rejecting a pending quote
  /// is not.
  Future<void> _reject(BuildContext context, Deal deal) async {
    final cubit = context.read<DashboardContractsCubit>();
    if (deal.isAccepted && !await _confirmCancel(context, deal)) return;
    await cubit.reject(deal);
  }

  static Future<bool> _confirmCancel(BuildContext context, Deal deal) async =>
      await showDialog<bool>(
        context: context,
        builder: (dialogContext) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(ContractsMessages.confirmCancel(deal)),
            content: const Text(ContractsMessages.confirmCancelDetail),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: FilledButton.styleFrom(
                  backgroundColor: HaseenColors.red,
                ),
                child: const Text('رفض العقد'),
              ),
            ],
          ),
        ),
      ) ??
      false;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DashboardContractsCubit>();
    return DealsTable(
      deals: state.deals,
      plans: state.plans,
      savingIds: state.savingIds,
      emptyMessage: ContractsMessages.noClients,
      onAccept: cubit.accept,
      onReject: (deal) => _reject(context, deal),
      onSelectPlan: cubit.selectPlan,
    );
  }
}
