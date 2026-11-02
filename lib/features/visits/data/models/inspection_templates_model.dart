import '../../domain/entities/facility_open_action.dart';
import '../../domain/entities/inspection_template.dart';
import '../../domain/entities/visit_task_catalog.dart';

/// The inspection templates (local): one per sector, a default for any other
/// sector, and the pre-contract assessment.
class InspectionTemplatesModel {
  final Map<String, InspectionTemplate> bySector;
  final InspectionTemplate defaultTemplate;
  final InspectionTemplate preContract;

  const InspectionTemplatesModel({
    required this.bySector,
    required this.defaultTemplate,
    required this.preContract,
  });

  /// Throws on a malformed payload.
  factory InspectionTemplatesModel.fromJson(Map<String, Object?> json) {
    InspectionTemplate template(Object? item) {
      final map = item! as Map<String, Object?>;
      final name = map['name']! as String;
      final count = map['items']! as int;
      if (name.trim().isEmpty || count <= 0) {
        throw FormatException('Bad inspection template: $map');
      }
      return InspectionTemplate(name: name, itemCount: count);
    }

    return InspectionTemplatesModel(
      bySector: {
        for (final MapEntry(:key, :value)
            in (json['by_sector']! as Map<String, Object?>).entries)
          key: template(value),
      },
      defaultTemplate: template(json['default']),
      preContract: template(json['pre_contract']),
    );
  }

  VisitTaskCatalog withOpenActions(List<FacilityOpenAction> openActions) =>
      VisitTaskCatalog(
        templatesBySector: bySector,
        defaultTemplate: defaultTemplate,
        preContractTemplate: preContract,
        openActions: openActions,
      );
}
