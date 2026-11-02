import 'package:flutter/material.dart';

import '../../domain/entities/team_member.dart';
import '../config/team_layout_config.dart';
import 'team_member_card.dart';

/// Wraps member cards into 1–4 equal columns depending on the width available.
class TeamGrid extends StatelessWidget {
  final List<TeamMember> members;

  /// Members whose temporary password is shown in clear.
  final Set<String> revealedPasswordIds;
  final ValueChanged<TeamMember>? onTogglePassword;
  final ValueChanged<TeamMember>? onCopyPassword;

  const TeamGrid({
    super.key,
    required this.members,
    this.revealedPasswordIds = const {},
    this.onTogglePassword,
    this.onCopyPassword,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = TeamLayoutConfig.cardWidth(constraints.maxWidth);
      return Wrap(
        spacing: TeamLayoutConfig.cardGap,
        runSpacing: TeamLayoutConfig.cardRunGap,
        children: [
          for (final member in members)
            SizedBox(
              width: width,
              child: TeamMemberCard(
                member: member,
                passwordRevealed: revealedPasswordIds.contains(member.id),
                onTogglePassword: () => onTogglePassword?.call(member),
                onCopyPassword: () => onCopyPassword?.call(member),
              ),
            ),
        ],
      );
    },
  );
}
