import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/inspection_template.dart';
import '../../domain/entities/operation_rule.dart';
import '../../domain/entities/system_role.dart';

sealed class DashboardSettingsState extends Equatable {
  const DashboardSettingsState();

  @override
  List<Object?> get props => [];
}

final class DashboardSettingsInitial extends DashboardSettingsState {
  const DashboardSettingsInitial();
}

final class DashboardSettingsLoading extends DashboardSettingsState {
  const DashboardSettingsLoading();
}

final class DashboardSettingsFailure extends DashboardSettingsState {
  final Failure failure;

  const DashboardSettingsFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}

final class DashboardSettingsLoaded extends DashboardSettingsState {
  final List<InspectionTemplate> templates;
  final List<SystemRole> roles;
  final List<OperationRule> rules;

  const DashboardSettingsLoaded({
    required this.templates,
    required this.roles,
    required this.rules,
  });

  @override
  List<Object?> get props => [templates, roles, rules];
}
