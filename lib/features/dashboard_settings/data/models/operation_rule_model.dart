import '../../domain/entities/operation_rule.dart';

/// An operating rule as JSON: `title`, `value`.
class OperationRuleModel {
  final String title;
  final String value;

  const OperationRuleModel({required this.title, required this.value});

  /// Throws on a malformed payload.
  factory OperationRuleModel.fromJson(Map<String, Object?> json) =>
      OperationRuleModel(
        title: json['title']! as String,
        value: json['value']! as String,
      );

  OperationRule toEntity() => OperationRule(title: title, value: value);
}
