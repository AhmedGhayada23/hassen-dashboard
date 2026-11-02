import '../../domain/entities/visit_facility.dart';
import '../../domain/entities/visit_scheduling_options.dart';
import '../../domain/entities/visit_task_catalog.dart';

/// The visit types (local) offered alongside the facilities (Firebase).
class VisitTypesModel {
  final List<String> visitTypes;
  final String routineType;
  final String preContractType;

  const VisitTypesModel({
    required this.visitTypes,
    required this.routineType,
    required this.preContractType,
  });

  /// Throws [FormatException] when the list is empty or a default type isn't
  /// offered.
  factory VisitTypesModel.fromJson(Map<String, Object?> json) {
    final model = VisitTypesModel(
      visitTypes: [for (final t in json['visit_types'] as List) t as String],
      routineType: json['routine_type'] as String,
      preContractType: json['pre_contract_type'] as String,
    );
    if (model.visitTypes.isEmpty) {
      throw const FormatException('Scheduling needs visit types.');
    }
    for (final type in [model.routineType, model.preContractType]) {
      if (!model.visitTypes.contains(type)) {
        throw FormatException('Unknown visit type: $type');
      }
    }
    return model;
  }

  VisitSchedulingOptions withFacilities(
    List<VisitFacility> facilities, {
    VisitTaskCatalog taskCatalog = const VisitTaskCatalog(),
  }) => VisitSchedulingOptions(
    facilities: facilities,
    visitTypes: visitTypes,
    routineType: routineType,
    preContractType: preContractType,
    taskCatalog: taskCatalog,
  );
}
