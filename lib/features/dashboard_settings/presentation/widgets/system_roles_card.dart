import 'package:flutter/material.dart';

import '../../domain/entities/system_role.dart';
import '../config/settings_texts.dart';
import 'settings_list_card.dart';
import 'system_role_row.dart';

/// "الأدوار والصلاحيات": every role with its user count and organization.
class SystemRolesCard extends StatelessWidget {
  final List<SystemRole> roles;

  const SystemRolesCard({super.key, required this.roles});

  @override
  Widget build(BuildContext context) => SettingsListCard(
    title: SettingsTexts.rolesTitle,
    rows: [for (final r in roles) SystemRoleRow(role: r)],
  );
}
