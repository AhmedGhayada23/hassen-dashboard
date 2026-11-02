import 'package:equatable/equatable.dart';

import 'client.dart';
import 'client_stage.dart';

/// Per-stage counts derived from one client list, so they can't drift from it.
class ClientsSummary extends Equatable {
  final int total;
  final Map<ClientStage, int> countsByStage;

  const ClientsSummary({required this.total, required this.countsByStage});

  factory ClientsSummary.fromClients(List<Client> clients) => ClientsSummary(
    total: clients.length,
    countsByStage: {
      for (final stage in ClientStage.values)
        stage: clients.where((c) => c.stage == stage).length,
    },
  );

  /// Count for a filter; null means "all stages".
  int countFor(ClientStage? stage) =>
      stage == null ? total : countsByStage[stage] ?? 0;

  @override
  List<Object> get props => [total, countsByStage];
}
