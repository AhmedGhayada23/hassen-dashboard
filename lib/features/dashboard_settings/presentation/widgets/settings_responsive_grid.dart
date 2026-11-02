import 'package:flutter/material.dart';

import '../config/settings_layout_config.dart';

/// Wraps the settings cards into 1–3 equal columns depending on the width
/// available, top-aligned.
class SettingsResponsiveGrid extends StatelessWidget {
  final List<Widget> children;

  const SettingsResponsiveGrid({super.key, required this.children});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = SettingsLayoutConfig.cardWidth(constraints.maxWidth);
      return Wrap(
        spacing: SettingsLayoutConfig.cardGap,
        runSpacing: SettingsLayoutConfig.cardGap,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );
}
