import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/inspection_template.dart';
import '../repositories/settings_repository.dart';

class GetInspectionTemplates
    extends UseCase<List<InspectionTemplate>, NoParams> {
  final SettingsRepository repository;

  GetInspectionTemplates(this.repository);

  @override
  Future<Either<Failure, List<InspectionTemplate>>> call(NoParams params) =>
      repository.getInspectionTemplates();
}
