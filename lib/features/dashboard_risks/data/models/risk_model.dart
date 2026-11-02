import '../../domain/entities/risk.dart';
import '../../domain/entities/risk_status.dart';

/// A document of the Firestore `risks` collection:
/// `hazard`, `facility`, `likelihood` and `severity` (1–5), `owner`,
/// `status` (open / in_treatment / monitoring) and `control`.
class RiskModel {
  /// What a missing text field reads as.
  static const unknown = '—';

  final String id;
  final String hazard;
  final String facility;
  final int likelihood;
  final int severity;
  final String owner;
  final RiskStatus status;
  final String control;

  const RiskModel({
    required this.id,
    required this.hazard,
    required this.facility,
    required this.likelihood,
    required this.severity,
    required this.owner,
    required this.status,
    required this.control,
  });

  /// Reads a document leniently, so one hand-edited record never breaks the
  /// page: missing text reads as "—" and an unknown `status` as open. A risk
  /// that can't be placed on the matrix — no `hazard`, or a rating missing or
  /// outside 1–5 — is null and left out.
  static RiskModel? fromDocument(String id, Map<String, Object?> json) {
    String text(String key) {
      final value = (json[key] as String?)?.trim() ?? '';
      return value.isEmpty ? unknown : value;
    }

    int? rating(String key) => switch (json[key]) {
      final num n
          when n == n.roundToDouble() && Risk.isValidRating(n.toInt()) =>
        n.toInt(),
      _ => null,
    };

    final hazard = (json['hazard'] as String?)?.trim() ?? '';
    final likelihood = rating('likelihood');
    final severity = rating('severity');
    if (hazard.isEmpty || likelihood == null || severity == null) return null;
    return RiskModel(
      id: id,
      hazard: hazard,
      facility: text('facility'),
      likelihood: likelihood,
      severity: severity,
      owner: text('owner'),
      status: _statusByCode[json['status']] ?? RiskStatus.open,
      control: text('control'),
    );
  }

  static const _statusByCode = {
    'open': RiskStatus.open,
    'in_treatment': RiskStatus.inTreatment,
    'monitoring': RiskStatus.monitoring,
  };

  Risk toEntity() => Risk(
    id: id,
    hazard: hazard,
    facility: facility,
    likelihood: likelihood,
    severity: severity,
    owner: owner,
    status: status,
    control: control,
  );
}
