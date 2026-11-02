import '../../domain/entities/action_due_status.dart';
import '../../domain/entities/action_severity.dart';
import '../../domain/entities/action_status.dart';
import '../../domain/entities/corrective_action.dart';

/// A document of the Firestore `corrective_actions` collection, its id the
/// action number (e.g. `CA-0431`): `title`, `facility`, `severity`
/// (critical / high / medium / low), `owner`, `due_text` (as the board words
/// it), `due_status` (late / soon / ok / done) and `status` (open /
/// in_progress / pending_closure / closed).
class CorrectiveActionModel {
  /// What a missing text field reads as.
  static const unknown = '—';

  final String id;
  final String title;
  final String facility;
  final ActionSeverity severity;
  final String owner;
  final String dueText;
  final ActionDueStatus dueStatus;
  final ActionStatus status;

  const CorrectiveActionModel({
    required this.id,
    required this.title,
    required this.facility,
    required this.severity,
    required this.owner,
    required this.dueText,
    required this.dueStatus,
    required this.status,
  });

  /// Reads a document leniently, so one hand-edited record never breaks the
  /// board: missing text reads as "—", an unknown severity as medium, an
  /// unknown deadline standing as ok and an unknown status as open. An
  /// action without a `title` is null and left out.
  static CorrectiveActionModel? fromDocument(
    String id,
    Map<String, Object?> json,
  ) {
    String text(String key) {
      final value = (json[key] as String?)?.trim() ?? '';
      return value.isEmpty ? unknown : value;
    }

    final title = (json['title'] as String?)?.trim() ?? '';
    if (title.isEmpty) return null;
    return CorrectiveActionModel(
      id: id,
      title: title,
      facility: text('facility'),
      severity:
          ActionSeverity.values.asNameMap()[json['severity']] ??
          ActionSeverity.medium,
      owner: text('owner'),
      dueText: text('due_text'),
      dueStatus:
          ActionDueStatus.values.asNameMap()[json['due_status']] ??
          ActionDueStatus.ok,
      status: _statusByCode[json['status']] ?? ActionStatus.open,
    );
  }

  static const _statusByCode = {
    'open': ActionStatus.open,
    'in_progress': ActionStatus.inProgress,
    'pending_closure': ActionStatus.pendingClosure,
    'closed': ActionStatus.closed,
  };

  static String statusToJson(ActionStatus status) => switch (status) {
    ActionStatus.open => 'open',
    ActionStatus.inProgress => 'in_progress',
    ActionStatus.pendingClosure => 'pending_closure',
    ActionStatus.closed => 'closed',
  };

  CorrectiveAction toEntity() => CorrectiveAction(
    id: id,
    title: title,
    facility: facility,
    severity: severity,
    owner: owner,
    dueText: dueText,
    dueStatus: dueStatus,
    status: status,
  );
}
