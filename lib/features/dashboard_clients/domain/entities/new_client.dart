import 'package:equatable/equatable.dart';

import 'client_stage.dart';

/// A facility being registered as a client, as filled in the form, plus the
/// rules that turn it into the record's display lines.
class NewClient extends Equatable {
  /// Shown for anything not known yet.
  static const unknown = '—';

  /// Visit frequency of a client waiting for its pre-contract inspection.
  static const preInspectionNeeded = 'فحص أولي مطلوب';

  final String name;
  final String sector;
  final int branches;
  final String city;
  final String address;
  final String contactName;
  final String contactTitle;
  final String email;
  final String phone;
  final ClientStage stage;

  /// Responsible inspector's name; empty when none is assigned yet.
  final String inspector;
  final String note;
  final bool schedulePreInspection;

  const NewClient({
    required this.name,
    required this.sector,
    required this.branches,
    this.city = '',
    this.address = '',
    required this.contactName,
    this.contactTitle = '',
    this.email = '',
    this.phone = '',
    required this.stage,
    this.inspector = '',
    this.note = '',
    this.schedulePreInspection = true,
  });

  /// "Name — title", or just the name when there is no title.
  String get contactLine {
    final name = contactName.trim(), title = contactTitle.trim();
    return title.isEmpty ? name : '$name — $title';
  }

  /// "City، address" with blanks skipped; [unknown] when both are blank.
  String get cityLine {
    final parts = [city.trim(), address.trim()].where((p) => p.isNotEmpty);
    return parts.isEmpty ? unknown : parts.join('، ');
  }

  String get visitsLine =>
      schedulePreInspection ? preInspectionNeeded : unknown;

  String get inspectorLine => inspector.isEmpty ? unknown : inspector;

  @override
  List<Object?> get props => [
    name,
    sector,
    branches,
    city,
    address,
    contactName,
    contactTitle,
    email,
    phone,
    stage,
    inspector,
    note,
    schedulePreInspection,
  ];
}
