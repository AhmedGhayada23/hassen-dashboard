import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_toast.dart';
import '../../../../shared/dashboard_shell/domain/entities/nav_destination.dart';
import '../../../../shared/dashboard_shell/presentation/config/dashboard_layout_config.dart';
import '../../../../shared/dashboard_shell/presentation/config/dashboard_navigation_config.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/dashboard_load_error.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/dashboard_shell.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/demo_snack_bar.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/header/dashboard_header.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/header/notifications_button.dart';
import '../../../../shared/visit_scheduling/visit_scheduler.dart';
import '../config/clients_layout_config.dart';
import '../config/clients_messages.dart';
import '../cubits/dashboard_clients_cubit.dart';
import '../cubits/dashboard_clients_state.dart';
import '../widgets/add_client_dialog.dart';
import '../widgets/client_details_panel.dart';
import '../widgets/clients_filter_bar.dart';
import '../widgets/clients_skeleton.dart';
import '../widgets/clients_table.dart';

/// HASEEN dashboard — clients & facilities. Expects a [DashboardClientsCubit]
/// and a [VisitScheduler] (for "جدولة زيارة") above it.
class DashboardClientsPage extends StatelessWidget {
  const DashboardClientsPage({super.key});

  static bool _hasOutcome(
    DashboardClientsState previous,
    DashboardClientsState current,
  ) =>
      current is DashboardClientsLoaded &&
      previous != current &&
      (current.lastAdded != null ||
          current.actionFailure != null ||
          current.formFailure != null);

  static void _showOutcome(BuildContext context, DashboardClientsState state) {
    if (state is! DashboardClientsLoaded) return;
    if (state.lastAdded case (:final client, :final schedulePreInspection)) {
      showSuccessToast(
        context,
        ClientsMessages.added(client, schedulePreInspection),
        actionLabel: schedulePreInspection ? 'جدولة الآن' : null,
        onAction: () => context.read<VisitScheduler>().scheduleAt(
          context,
          facility: client.name,
        ),
      );
    } else if (state.actionFailure case final failure?) {
      showErrorToast(context, ClientsMessages.addFailed(failure));
    } else if (state.formFailure case final failure?) {
      showErrorToast(context, ClientsMessages.formFailed(failure));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      destination: NavDestination.clients,
      header: DashboardHeader(
        title: 'العملاء والمنشآت',
        searchHint: 'ابحث عن عميل، زيارة، أو إجراء…',
        actions: [
          NotificationsButton(
            hasUnread: demoHasUnreadNotifications,
            onPressed: () {},
          ),
        ],
      ),
      body: BlocConsumer<DashboardClientsCubit, DashboardClientsState>(
        listenWhen: _hasOutcome,
        listener: _showOutcome,
        builder: (context, state) => switch (state) {
          DashboardClientsInitial() ||
          DashboardClientsLoading() => const ClientsSkeleton(),
          DashboardClientsFailure(:final failure) => DashboardLoadError(
            onRetry: context.read<DashboardClientsCubit>().load,
            details: ClientsMessages.loadFailed(failure),
          ),
          DashboardClientsLoaded() => _ClientsContent(state: state),
        },
      ),
    );
  }
}

class _ClientsContent extends StatelessWidget {
  final DashboardClientsLoaded state;

  const _ClientsContent({required this.state});

  Future<void> _addClient(BuildContext context) async {
    final cubit = context.read<DashboardClientsCubit>();
    final existingNames = {for (final c in state.clients) c.name};
    final options = await cubit.prepareNewClient();
    if (options == null || !context.mounted) return;
    if (options.sectors.isEmpty) {
      showErrorToast(context, ClientsMessages.noSectors);
      return;
    }
    final client = await showAddClientDialog(
      context,
      options: options,
      existingNames: existingNames,
    );
    if (client != null) await cubit.addClient(client);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DashboardClientsCubit>();
    return SingleChildScrollView(
      padding: DashboardLayoutConfig.contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClientsFilterBar(
            selectedStage: state.stageFilter,
            summary: state.summary,
            onStageSelected: cubit.selectStage,
            onAddClient: () => _addClient(context),
            isBusy: state.isPreparingForm || state.isAdding,
          ),
          SizedBox(height: DashboardLayoutConfig.sectionGap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClientsTable(
                  clients: state.visibleClients,
                  selectedClientId: state.selectedClientId,
                  onClientTap: (client) => cubit.selectClient(client.id),
                  emptyMessage: state.clients.isEmpty
                      ? ClientsMessages.noClients
                      : ClientsMessages.noClientsInStage,
                ),
              ),
              SizedBox(width: ClientsLayoutConfig.panelGap),
              SizedBox(
                width: ClientsLayoutConfig.detailsPanelWidth,
                child: ClientDetailsPanel(
                  client: state.selectedClient,
                  onScheduleVisit: (client) => context
                      .read<VisitScheduler>()
                      .scheduleAt(context, facility: client.name),
                  onReports: (client) =>
                      showDemoSnackBar(context, 'تقارير ${client.name}'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
