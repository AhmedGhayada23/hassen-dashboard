import '../../domain/entities/report_facility.dart';

/// A contracted client, read from its `clients` document: under contract
/// when its deal was accepted (`deal_status`), or — for clients contracted
/// before decisions were kept — when its `stage` is contracted.
class ReportFacilityModel {
  final String id;
  final String name;
  final String sector;
  final String contractPeriod;

  const ReportFacilityModel({
    required this.id,
    required this.name,
    required this.sector,
    required this.contractPeriod,
  });

  /// Null for a client without a name or not under contract.
  static ReportFacilityModel? fromClient(String id, Map<String, Object?> json) {
    String text(String key) {
      final value = (json[key] as String?)?.trim() ?? '';
      return value.isEmpty ? '—' : value;
    }

    final name = (json['name'] as String?)?.trim() ?? '';
    final contracted = switch (json['deal_status']) {
      'accepted' => true,
      null => json['stage'] == 'contracted',
      _ => false,
    };
    if (name.isEmpty || !contracted) return null;
    return ReportFacilityModel(
      id: id,
      name: name,
      sector: text('type'),
      contractPeriod: text('contract'),
    );
  }

  ReportFacility toEntity() => ReportFacility(
    id: id,
    name: name,
    sector: sector,
    contractPeriod: contractPeriod,
  );
}
