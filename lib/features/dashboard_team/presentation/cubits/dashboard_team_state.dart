import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/employee_role.dart';
import '../../domain/entities/team_member.dart';
import '../../domain/entities/team_summary.dart';

sealed class DashboardTeamState extends Equatable {
  const DashboardTeamState();

  @override
  List<Object?> get props => [];
}

final class DashboardTeamInitial extends DashboardTeamState {
  const DashboardTeamInitial();
}

final class DashboardTeamLoading extends DashboardTeamState {
  const DashboardTeamLoading();
}

final class DashboardTeamFailure extends DashboardTeamState {
  final Failure failure;

  const DashboardTeamFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}

final class DashboardTeamLoaded extends DashboardTeamState {
  final List<TeamMember> members;
  final List<EmployeeRole> roles;

  /// An account is being created.
  final bool isAdding;

  /// Members whose temporary password is shown in clear on their card.
  final Set<String> revealedPasswordIds;

  /// The member just added, for a one-off confirmation.
  final TeamMember? lastAdded;

  /// Set when the last addition failed; cleared by the next change.
  final Failure? actionFailure;

  const DashboardTeamLoaded(
    this.members,
    this.roles, {
    this.isAdding = false,
    this.revealedPasswordIds = const {},
    this.lastAdded,
    this.actionFailure,
  });

  TeamSummary get summary => TeamSummary.fromMembers(members);

  bool isPasswordRevealed(TeamMember member) =>
      revealedPasswordIds.contains(member.id);

  /// Same roster and toggles; the one-off outcome fields are dropped.
  DashboardTeamLoaded copyWith({
    List<TeamMember>? members,
    bool? isAdding,
    Set<String>? revealedPasswordIds,
    TeamMember? lastAdded,
    Failure? actionFailure,
  }) => DashboardTeamLoaded(
    members ?? this.members,
    roles,
    isAdding: isAdding ?? this.isAdding,
    revealedPasswordIds: revealedPasswordIds ?? this.revealedPasswordIds,
    lastAdded: lastAdded,
    actionFailure: actionFailure,
  );

  @override
  List<Object?> get props => [
    members,
    roles,
    isAdding,
    revealedPasswordIds,
    lastAdded,
    actionFailure,
  ];
}
