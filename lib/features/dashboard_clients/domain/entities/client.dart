import 'package:equatable/equatable.dart';

import 'client_stage.dart';

class Client extends Equatable {
  /// More open findings than this flags the client as high-risk.
  static const manyOpenFindingsThreshold = 5;

  /// Stable key, so selection survives filtering and reloads.
  final String id;
  final String name;
  final String type;
  final int branches;
  final ClientStage stage;
  final int openFindings;

  /// Latest compliance percentage; null until the first inspection.
  final int? compliance;
  final String contract;
  final String visits;
  final String inspector;
  final String contact;

  /// City and address, as one line.
  final String city;

  const Client({
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

  bool get hasManyOpenFindings => openFindings > manyOpenFindingsThreshold;

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    branches,
    stage,
    openFindings,
    compliance,
    contract,
    visits,
    inspector,
    contact,
    city,
  ];
}
