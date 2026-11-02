import '../../domain/entities/risk_status.dart';

extension RiskStatusLabel on RiskStatus {
  String get label => switch (this) {
    RiskStatus.open => 'مفتوح',
    RiskStatus.inTreatment => 'قيد المعالجة',
    RiskStatus.monitoring => 'مراقبة',
  };
}
