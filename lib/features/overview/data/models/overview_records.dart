/// The few fields the overview needs from each Firestore collection, read
/// leniently so one hand-edited document never breaks the page.
library;

/// A `clients` document.
class OverviewClient {
  final String name;

  /// Its deal was accepted — or, for clients contracted before decisions
  /// were kept, its `stage` is contracted.
  final bool isContracted;

  /// Latest compliance percentage (0–100); null until inspected.
  final int? compliance;

  /// Last day of its contract, from the `contract` line
  /// ("2026-03-01 ← 2027-02-28"); null without one.
  final DateTime? contractEnd;

  const OverviewClient({
    required this.name,
    required this.isContracted,
    this.compliance,
    this.contractEnd,
  });

  /// Null for a client without a name.
  static OverviewClient? fromDocument(Map<String, Object?> json) {
    final name = (json['name'] as String?)?.trim() ?? '';
    if (name.isEmpty) return null;
    final contract = json['contract'] as String? ?? '';
    final compliance = (json['compliance'] as num?)?.round();
    return OverviewClient(
      name: name,
      isContracted: switch (json['deal_status']) {
        'accepted' => true,
        null => json['stage'] == 'contracted',
        _ => false,
      },
      compliance: compliance != null && compliance >= 0 && compliance <= 100
          ? compliance
          : null,
      contractEnd: contract.contains('←')
          ? DateTime.tryParse(contract.split('←').last.trim())
          : null,
    );
  }
}

/// A `visits` document.
class OverviewVisit {
  /// As `yyyy-MM-dd`.
  final String date;

  /// As `HH:mm`.
  final String time;
  final String facility;
  final String inspector;

  /// done / now / planned / pre.
  final String status;

  const OverviewVisit({
    required this.date,
    required this.time,
    required this.facility,
    required this.inspector,
    required this.status,
  });

  /// Null without a date or a facility.
  static OverviewVisit? fromDocument(Map<String, Object?> json) {
    String text(String key) => (json[key] as String?)?.trim() ?? '';
    final date = text('date');
    final facility = text('facility');
    if (date.isEmpty || facility.isEmpty) return null;
    final inspector = text('inspector_name');
    return OverviewVisit(
      date: date,
      time: text('time'),
      facility: facility,
      inspector: inspector.isEmpty ? '—' : inspector,
      status: text('status'),
    );
  }
}

/// A `risks` document.
class OverviewRisk {
  final String hazard;
  final String facility;
  final String owner;

  /// Likelihood × severity (1–25).
  final int score;

  /// open / in_treatment / monitoring.
  final String status;

  const OverviewRisk({
    required this.hazard,
    required this.facility,
    required this.owner,
    required this.score,
    required this.status,
  });

  /// Null without a hazard, or with a rating missing or outside 1–5.
  static OverviewRisk? fromDocument(Map<String, Object?> json) {
    String text(String key) {
      final value = (json[key] as String?)?.trim() ?? '';
      return value.isEmpty ? '—' : value;
    }

    int? rating(String key) => switch (json[key]) {
      final num n when n == n.roundToDouble() && n >= 1 && n <= 5 => n.toInt(),
      _ => null,
    };
    final hazard = (json['hazard'] as String?)?.trim() ?? '';
    final likelihood = rating('likelihood');
    final severity = rating('severity');
    if (hazard.isEmpty || likelihood == null || severity == null) return null;
    return OverviewRisk(
      hazard: hazard,
      facility: text('facility'),
      owner: text('owner'),
      score: likelihood * severity,
      status: json['status'] as String? ?? 'open',
    );
  }
}

/// A `corrective_actions` document.
class OverviewAction {
  /// open / in_progress / pending_closure / closed.
  final String status;

  /// late / soon / ok / done.
  final String dueStatus;

  const OverviewAction({required this.status, required this.dueStatus});

  /// Null without a title.
  static OverviewAction? fromDocument(Map<String, Object?> json) {
    if (((json['title'] as String?)?.trim() ?? '').isEmpty) return null;
    return OverviewAction(
      status: json['status'] as String? ?? 'open',
      dueStatus: json['due_status'] as String? ?? 'ok',
    );
  }
}
