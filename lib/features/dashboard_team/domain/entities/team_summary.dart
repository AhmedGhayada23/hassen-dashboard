import 'package:equatable/equatable.dart';

import 'team_member.dart';

/// Team-wide totals derived from one member list, so they can't drift from it.
class TeamSummary extends Equatable {
  final int memberCount;
  final int monthlyVisits;
  final int lateVisits;
  final int overloadedCount;

  /// Mean workload, rounded; 0 for an empty team.
  final int averageWorkload;

  const TeamSummary({
    required this.memberCount,
    required this.monthlyVisits,
    required this.lateVisits,
    required this.overloadedCount,
    required this.averageWorkload,
  });

  factory TeamSummary.fromMembers(List<TeamMember> members) {
    int sum(int Function(TeamMember) of) =>
        members.fold(0, (total, m) => total + of(m));
    return TeamSummary(
      memberCount: members.length,
      monthlyVisits: sum((m) => m.monthlyVisits),
      lateVisits: sum((m) => m.lateVisits),
      overloadedCount: members.where((m) => m.isOverloaded).length,
      averageWorkload: members.isEmpty
          ? 0
          : (sum((m) => m.workload) / members.length).round(),
    );
  }

  @override
  List<Object> get props => [
    memberCount,
    monthlyVisits,
    lateVisits,
    overloadedCount,
    averageWorkload,
  ];
}
