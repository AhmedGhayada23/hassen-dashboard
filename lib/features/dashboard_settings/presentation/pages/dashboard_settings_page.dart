import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/dashboard_shell/domain/entities/nav_destination.dart';
import '../../../../shared/dashboard_shell/presentation/config/dashboard_navigation_config.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/dashboard_load_error.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/dashboard_shell.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/demo_snack_bar.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/header/dashboard_header.dart';
import '../../../../shared/dashboard_shell/presentation/widgets/header/notifications_button.dart';
import '../config/settings_texts.dart';
import '../cubits/dashboard_settings_cubit.dart';
import '../cubits/dashboard_settings_state.dart';
import '../widgets/settings_content.dart';

/// HASEEN dashboard — settings: inspection templates, roles and operating
/// rules. Expects a [DashboardSettingsCubit] above it.
class DashboardSettingsPage extends StatelessWidget {
  const DashboardSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      destination: NavDestination.settings,
      header: DashboardHeader(
        title: 'الإعدادات',
        searchHint: 'ابحث عن عميل، زيارة، أو إجراء…',
        actions: [
          NotificationsButton(
            hasUnread: demoHasUnreadNotifications,
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<DashboardSettingsCubit, DashboardSettingsState>(
        builder: (context, state) => switch (state) {
          DashboardSettingsInitial() || DashboardSettingsLoading() =>
            const Center(child: CircularProgressIndicator()),
          DashboardSettingsFailure() => DashboardLoadError(
            onRetry: context.read<DashboardSettingsCubit>().load,
          ),
          DashboardSettingsLoaded() => SettingsContent(
            settings: state,
            // The template editor needs the backend.
            onAddTemplate: () =>
                showDemoSnackBar(context, SettingsTexts.editorNotReady),
          ),
        },
      ),
    );
  }
}
