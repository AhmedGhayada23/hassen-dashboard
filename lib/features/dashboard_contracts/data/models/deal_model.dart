import '../../domain/entities/contract_plan.dart';
import '../../domain/entities/deal.dart';
import '../../domain/entities/deal_status.dart';

/// A `clients` document with its creation time (null until the server sets it).
typedef ClientRecord = ({
  String id,
  Map<String, Object?> json,
  DateTime? createdAt,
});

/// A client's deal, read from its Firestore `clients` document.
///
/// Fields kept on the client:
/// * `deal_status` — pending / accepted / rejected. Missing, it is accepted
///   for a client already at the `contracted` stage, and pending otherwise.
/// * `contract_plan`, `contract_start` (`yyyy-MM-dd`) — the contract.
/// * `quote_number` — optional; otherwise numbered by creation order.
///
/// Decisions also move the client's `stage` and its `contract` line, so the
/// clients page shows them.
class DealModel {
  static const contractedStage = 'contracted';
  static const quotationStage = 'quotation';

  /// What the clients page shows for a client without a contract.
  static const noContract = '—';

  final String id;
  final String number;
  final String client;
  final String date;
  final DealStatus status;
  final String? planId;
  final DateTime? startDate;

  const DealModel({
    required this.id,
    required this.number,
    required this.client,
    required this.date,
    required this.status,
    this.planId,
    this.startDate,
  });

  /// One deal per named client, oldest first (clients still being saved, with
  /// no `created_at` yet, last), each numbered by its order within its year.
  static List<DealModel> fromClients(
    List<ClientRecord> clients, {
    required int currentYear,
  }) {
    int order(ClientRecord a, ClientRecord b) =>
        switch ((a.createdAt, b.createdAt)) {
          (final x?, final y?) => x.compareTo(y),
          (null, null) => 0,
          (null, _) => 1,
          (_, null) => -1,
        };
    final perYear = <int, int>{};
    return [
      for (final c in clients.toList()..sort(order))
        if ((c.json['name'] as String? ?? '').trim().isNotEmpty)
          DealModel.fromClientDocument(
            c.id,
            c.json,
            createdAt: c.createdAt,
            sequence: perYear.update(
              c.createdAt?.year ?? currentYear,
              (n) => n + 1,
              ifAbsent: () => 1,
            ),
            fallbackYear: currentYear,
          ),
    ];
  }

  /// [sequence] numbers the client within [createdAt]'s year (from 1);
  /// [createdAt] is null for a client whose save is still pending.
  factory DealModel.fromClientDocument(
    String id,
    Map<String, Object?> json, {
    required DateTime? createdAt,
    required int sequence,
    required int fallbackYear,
  }) {
    final year = createdAt?.year ?? fallbackYear;
    final number = (json['quote_number'] as String?)?.trim() ?? '';
    return DealModel(
      id: id,
      number: number.isNotEmpty
          ? number
          : 'Q-$year-${sequence.toString().padLeft(3, '0')}',
      client: (json['name'] as String?)?.trim() ?? '',
      date: createdAt == null ? noContract : isoDate(createdAt),
      status:
          _statusByCode[json['deal_status']] ??
          (json['stage'] == contractedStage
              ? DealStatus.accepted
              : DealStatus.pending),
      planId: json['contract_plan'] as String?,
      startDate: DateTime.tryParse(json['contract_start'] as String? ?? ''),
    );
  }

  /// The client changes for accepting from [startDate], length still open.
  static Map<String, Object?> acceptance(DateTime startDate) => {
    'deal_status': 'accepted',
    'stage': contractedStage,
    'contract_start': isoDate(startDate),
    'contract_plan': null,
    'contract': noContract,
  };

  /// The client changes for a rejection: back to the quotation stage, with
  /// no contract.
  static Map<String, Object?> rejection() => {
    'deal_status': 'rejected',
    'stage': quotationStage,
    'contract_start': null,
    'contract_plan': null,
    'contract': noContract,
  };

  /// The client changes for a contract of [plan] from [startDate]; its
  /// `contract` line reads "start ← end", as the clients page shows it.
  static Map<String, Object?> contract(
    ContractPlan plan,
    DateTime startDate,
  ) => {
    'contract_plan': plan.id,
    'contract_start': isoDate(startDate),
    'contract': '${isoDate(startDate)} ← ${isoDate(plan.endFor(startDate))}',
  };

  /// `yyyy-MM-dd`.
  static String isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Deal toEntity() => Deal(
    id: id,
    number: number,
    client: client,
    date: date,
    status: status,
    planId: planId,
    startDate: startDate,
  );

  static const _statusByCode = {
    'pending': DealStatus.pending,
    'accepted': DealStatus.accepted,
    'rejected': DealStatus.rejected,
  };
}
