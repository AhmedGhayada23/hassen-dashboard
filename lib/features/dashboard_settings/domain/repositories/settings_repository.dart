import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/inspection_template.dart';
import '../entities/operation_rule.dart';
import '../entities/system_role.dart';

/// The platform's configuration, read-only for now.
abstract interface class SettingsRepository {
  Future<Either<Failure, List<InspectionTemplate>>> getInspectionTemplates();

  Future<Either<Failure, List<SystemRole>>> getSystemRoles();

  Future<Either<Failure, List<OperationRule>>> getOperationRules();
}
