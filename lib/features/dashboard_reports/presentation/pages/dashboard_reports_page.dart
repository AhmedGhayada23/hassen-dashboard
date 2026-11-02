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
import '../../domain/entities/monthly_report.dart';
import '../config/reports_messages.dart';
import '../cubits/dashboard_reports_cubit.dart';
import '../cubits/dashboard_reports_state.dart';
import '../widgets/monthly_report_preview.dart';
import '../widgets/reports_month_bar.dart';
import '../widgets/reports_skeleton.dart';
import '../widgets/reports_table.dart';
import '../widgets/send_report_dialog.dart';

/// HASEEN dashboard — monthly reports: one per contracted facility, built
/// from its month in Firebase, to preview and email. Expects a
/// [DashboardReportsCubit] above it.
class DashboardReportsPage extends StatelessWidget {
  const DashboardReportsPage({super.key});

  static bool _hasOutcome(
    DashboardReportsState previous,
    DashboardReportsState current,
  ) =>
      current is DashboardReportsLoaded &&
      previous != current &&
      (current.lastSent != null || current.actionFailure != null);

  static void _showOutcome(BuildContext context, DashboardReportsState state) {
    if (state is! DashboardReportsLoaded) return;
    if (state.lastSent case (_, final delivery)) {
      showSuccessToast(context, ReportsMessages.sent(delivery));
    } else if (state.actionFailure case final failure?) {
      showErrorToast(context, ReportsMessages.sendFailed(failure));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      destination: NavDestination.reports,
      header: DashboardHeader(
        title: 'التقارير',
        searchHint: 'ابحث عن عميل، زيارة، أو إجراء…',
        actions: [
          NotificationsButton(
            hasUnread: demoHasUnreadNotifications,
            onPressed: () {},
          ),
        ],
      ),
      body: BlocConsumer<DashboardReportsCubit, DashboardReportsState>(
        listenWhen: _hasOutcome,
        listener: _showOutcome,
        builder: (context, state) => switch (state) {
          DashboardReportsInitial() ||
          DashboardReportsLoading() => SingleChildScrollView(
            padding: DashboardLayoutConfig.contentPadding,
            physics: const NeverScrollableScrollPhysics(),
            child: const ReportsSkeleton(),
          ),
          DashboardReportsFailure(:final failure) => DashboardLoadError(
            onRetry: context.read<DashboardReportsCubit>().load,
            details: ReportsMessages.loadFailed(failure),
          ),
          DashboardReportsLoaded() => _ReportsContent(state: state),
        },
      ),
    );
  }
}

class _ReportsContent extends StatelessWidget {
  final DashboardReportsLoaded state;

  const _ReportsContent({required this.state});

  Future<void> _preview(BuildContext context, MonthlyReport report) async {
    if (await showMonthlyReportPreview(context, report) && context.mounted) {
      await _send(context, report);
    }
  }

  Future<void> _send(BuildContext context, MonthlyReport report) async {
    final cubit = context.read<DashboardReportsCubit>();
    final delivery = await showSendReportDialog(context, report);
    if (delivery != null) await cubit.send(report, delivery);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DashboardReportsCubit>();
    return SingleChildScrollView(
      padding: DashboardLayoutConfig.contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ReportsMonthBar(
            months: state.months,
            month: state.month,
            summary: ReportsMessages.summary(
              state.reports.length,
              state.sentCount,
            ),
            onMonthSelected: cubit.selectMonth,
          ),
          SizedBox(height: 10.h),
          Text(
            ReportsMessages.intro,
            style: TextStyle(fontSize: 12.5.sp, color: HaseenColors.muted),
          ),
          SizedBox(height: 14.h),
          ReportsTable(
            reports: state.reports,
            emptyMessage: ReportsMessages.noFacilities,
            onPreview: (report) => _preview(context, report),
            onSend: (report) => _send(context, report),
          ),
        ],
      ),
    );
  }
}
