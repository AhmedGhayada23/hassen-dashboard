import '../../domain/entities/client.dart';
import '../../domain/entities/client_stage.dart';
import '../../domain/entities/new_client.dart';

/// A document of the Firestore `clients` collection.
class ClientModel {
  final String id;
  final String name;
  final String type;
  final int branches;
  final ClientStage stage;
  final int openFindings;
  final int? compliance;
  final String contract;
  final String visits;
  final String inspector;
  final String contact;
  final String city;

  const ClientModel({
    required this.id,
    required this.name,
    required this.type,
    required this.branches,
    required this.stage,
    required this.openFindings,
    required this.compliance,
    required this.contract,
    required this.visits,
    required this.inspector,
    required this.contact,
    required this.city,
  });

  /// Reads a document leniently, so one hand-edited record never breaks the
  /// page: missing text reads as "—", missing counts as 0, an unknown
  /// `stage` as potential, and a missing `compliance` as "not inspected yet".
  factory ClientModel.fromDocument(String id, Map<String, Object?> json) {
    String text(String key) {
      final value = (json[key] as String?)?.trim() ?? '';
      return value.isEmpty ? NewClient.unknown : value;
    }

    int count(String key) {
      final value = (json[key] as num?)?.toInt() ?? 0;
      return value < 0 ? 0 : value;
    }

    return ClientModel(
      id: id,
      name: (json['name'] as String?)?.trim() ?? '',
      type: text('type'),
      branches: count('branches'),
      stage:
          ClientStage.values.asNameMap()[json['stage']] ??
          ClientStage.potential,
      openFindings: count('open_findings'),
      compliance: (json['compliance'] as num?)?.toInt(),
      contract: text('contract'),
      visits: text('visits'),
      inspector: text('inspector'),
      contact: text('contact'),
      city: text('city'),
    );
  }

  /// The document stored for a newly registered client: the display lines
  /// (built by the domain rules) plus the raw contact details and note.
  static Map<String, Object?> newDocument(NewClient client) => {
    'name': client.name.trim(),
    'type': client.sector,
    'branches': client.branches,
    'stage': client.stage.name,
    'open_findings': 0,
    'compliance': null,
    'contract': NewClient.unknown,
    'visits': client.visitsLine,
    'inspector': client.inspectorLine,
    'contact': client.contactLine,
    'city': client.cityLine,
    'city_name': client.city.trim(),
    'address': client.address.trim(),
    'contact_name': client.contactName.trim(),
    'contact_title': client.contactTitle.trim(),
    'email': client.email.trim(),
    'phone': client.phone.trim(),
    'note': client.note.trim(),
    'pre_inspection_requested': client.schedulePreInspection,
  };

  Client toEntity() => Client(
    id: id,
    name: name,
    type: type,
    branches: branches,
    stage: stage,
    openFindings: openFindings,
    compliance: compliance,
    contract: contract,
    visits: visits,
    inspector: inspector,
    contact: contact,
    city: city,
  );
}
