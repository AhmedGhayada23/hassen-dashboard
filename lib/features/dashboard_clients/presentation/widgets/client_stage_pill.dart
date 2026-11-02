import 'package:flutter/material.dart';

import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/client_stage.dart';
import '../config/client_stage_style.dart';

class ClientStagePill extends StatelessWidget {
  final ClientStage stage;

  const ClientStagePill({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    final style = stage.style;
    return StatusBadge(style.label, style.background, style.foreground);
  }
}
