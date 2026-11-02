import 'package:flutter/material.dart';

import '../../../../shared/dashboard_shell/presentation/config/dashboard_layout_config.dart';
import '../cubits/dashboard_settings_state.dart';
import 'inspection_templates_card.dart';
import 'operation_rules_card.dart';
import 'settings_responsive_grid.dart';
import 'system_roles_card.dart';

/// The three settings cards — templates, roles, rules — in a scrolling
/// responsive grid.
class SettingsContent extends StatelessWidget {
  final DashboardSettingsLoaded settings;
  final VoidCallback onAddTemplate;

  const SettingsContent({
    super.key,
    required this.settings,
    required this.onAddTemplate,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: DashboardLayoutConfig.contentPadding,
    child: SettingsResponsiveGrid(
      children: [
        InspectionTemplatesCard(
          templates: settings.templates,
          onAddTemplate: onAddTemplate,
        ),
        SystemRolesCard(roles: settings.roles),
        OperationRulesCard(rules: settings.rules),
      ],
    ),
  );
}
