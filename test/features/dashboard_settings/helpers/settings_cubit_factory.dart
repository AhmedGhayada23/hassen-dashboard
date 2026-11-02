import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/dashboard_settings/domain/entities/inspection_template.dart';
import 'package:hassen_dashboard/features/dashboard_settings/domain/entities/operation_rule.dart';
import 'package:hassen_dashboard/features/dashboard_settings/domain/entities/system_role.dart';
import 'package:hassen_dashboard/features/dashboard_settings/domain/repositories/settings_repository.dart';
import 'package:hassen_dashboard/features/dashboard_settings/domain/usecases/get_inspection_templates.dart';
import 'package:hassen_dashboard/features/dashboard_settings/domain/usecases/get_operation_rules.dart';
import 'package:hassen_dashboard/features/dashboard_settings/domain/usecases/get_system_roles.dart';
import 'package:hassen_dashboard/features/dashboard_settings/presentation/cubits/dashboard_settings_cubit.dart';

import '../fixtures/settings_fixture.dart';

/// Serves the original settings, optionally held until [gate] completes;
/// [rolesFailure] fails the roles.
class FakeSettingsRepository implements SettingsRepository {
  Completer<void>? gate;
  Failure? rolesFailure;

  @override
  Future<Either<Failure, List<InspectionTemplate>>>
  getInspectionTemplates() async {
    await gate?.future;
    return const Right(expectedTemplates);
  }

  @override
  Future<Either<Failure, List<SystemRole>>> getSystemRoles() async =>
      rolesFailure != null ? Left(rolesFailure!) : const Right(expectedRoles);

  @override
  Future<Either<Failure, List<OperationRule>>> getOperationRules() async =>
      const Right(expectedRules);
}

DashboardSettingsCubit buildSettingsCubit(SettingsRepository repository) =>
    DashboardSettingsCubit(
      getTemplates: GetInspectionTemplates(repository),
      getRoles: GetSystemRoles(repository),
      getRules: GetOperationRules(repository),
    );
