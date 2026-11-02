import 'package:equatable/equatable.dart';

import 'facility_open_action.dart';
import 'inspection_template.dart';
import 'visit_facility.dart';
import 'visit_task.dart';

/// What a visit's tasks are drawn from: the inspection template for the
/// facility's sector, and the corrective actions still open there.
class VisitTaskCatalog extends Equatable {
  /// Id of the inspection-template task.
  static const templateTaskId = 'tpl';

  final Map<String, InspectionTemplate> templatesBySector;

  /// For a sector without a template of its own.
  final InspectionTemplate? defaultTemplate;

  /// For a pre-contract assessment, whatever the sector.
  final InspectionTemplate? preContractTemplate;
  final List<FacilityOpenAction> openActions;

  const VisitTaskCatalog({
    this.templatesBySector = const {},
    this.defaultTemplate,
    this.preContractTemplate,
    this.openActions = const [],
  });

  /// The template to run, then (unless it is a pre-contract assessment,
  /// before any actions exist) a check of each action open at [facility].
  List<VisitTask> autoTasksFor(
    VisitFacility facility, {
    required bool isPreContract,
  }) {
    final template = isPreContract
        ? preContractTemplate
        : templatesBySector[facility.sector] ?? defaultTemplate;
    return [
      if (template != null)
        VisitTask(
          id: templateTaskId,
          title: 'تنفيذ نموذج الفحص: ${template.name}',
          detail: '${template.itemCount} بنداً',
          source: VisitTaskSource.template,
        ),
      if (!isPreContract)
        for (final action in openActions)
          if (action.facility == facility.name)
            VisitTask(
              id: action.id,
              title: 'التحقق من ${action.id}: ${action.title}',
              detail: action.hasEvidence
                  ? 'المنشأة رفعت دليل المعالجة — يتحقق منه ميدانياً'
                  : 'إجراء ${action.statusLabel} (${action.severityLabel}) — يتابع حالته',
              source: VisitTaskSource.correctiveAction,
            ),
    ];
  }

  @override
  List<Object?> get props => [
    templatesBySector,
    defaultTemplate,
    preContractTemplate,
    openActions,
  ];
}
