import '../../domain/entities/contract_plan.dart';

/// A contract length as JSON: `id`, `name`, `months`.
class ContractPlanModel {
  final String id;
  final String name;
  final int months;

  const ContractPlanModel({
    required this.id,
    required this.name,
    required this.months,
  });

  /// Throws on a malformed payload or a length under a month.
  factory ContractPlanModel.fromJson(Map<String, Object?> json) {
    final model = ContractPlanModel(
      id: json['id']! as String,
      name: json['name']! as String,
      months: json['months']! as int,
    );
    if (model.months < 1) {
      throw FormatException('Bad contract length: ${model.months}');
    }
    return model;
  }

  ContractPlan toEntity() => ContractPlan(id: id, name: name, months: months);
}
