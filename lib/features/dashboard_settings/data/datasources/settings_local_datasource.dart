import '../../../../core/errors/exceptions.dart';
import '../models/inspection_template_model.dart';
import '../models/operation_rule_model.dart';
import '../models/system_role_model.dart';

/// Serves the demo settings as raw JSON, the shape a REST API would return.
/// Swap this class for a remote data source when the backend exists.
class SettingsLocalDataSource {
  final List<Map<String, Object?>> _templatesJson;
  final List<Map<String, Object?>> _rolesJson;
  final List<Map<String, Object?>> _rulesJson;

  const SettingsLocalDataSource({
    List<Map<String, Object?>> templatesJson = demoTemplatesJson,
    List<Map<String, Object?>> rolesJson = demoRolesJson,
    List<Map<String, Object?>> rulesJson = demoRulesJson,
  }) : _templatesJson = templatesJson,
       _rolesJson = rolesJson,
       _rulesJson = rulesJson;

  /// Throws [ParseException] when the payload doesn't match the expected shape.
  Future<List<InspectionTemplateModel>> getInspectionTemplates() async =>
      _parse(_templatesJson, InspectionTemplateModel.fromJson);

  /// Throws [ParseException] when the payload doesn't match the expected shape.
  Future<List<SystemRoleModel>> getSystemRoles() async =>
      _parse(_rolesJson, SystemRoleModel.fromJson);

  /// Throws [ParseException] when the payload doesn't match the expected shape.
  Future<List<OperationRuleModel>> getOperationRules() async =>
      _parse(_rulesJson, OperationRuleModel.fromJson);

  static List<T> _parse<T>(
    List<Map<String, Object?>> json,
    T Function(Map<String, Object?>) fromJson,
  ) {
    try {
      return [for (final item in json) fromJson(item)];
    } catch (_) {
      throw ParseException();
    }
  }

  // بيانات تجريبية — مطابقة للأصل وبترتيبه.
  static const demoTemplatesJson = <Map<String, Object?>>[
    {'name': 'تفتيش المنشآت الصحية', 'version': 'v2', 'items': 38},
    {'name': 'تفتيش المنشآت الصناعية', 'version': 'v3', 'items': 42},
    {'name': 'تفتيش المباني الإدارية', 'version': 'v1', 'items': 28},
    {'name': 'تفتيش المكاتب والفروع', 'version': 'v1', 'items': 23},
    {'name': 'الفحص الأولي قبل التعاقد', 'version': 'v2', 'items': 30},
  ];

  static const demoRolesJson = <Map<String, Object?>>[
    {'name': 'مدير الشركة', 'users': 1, 'organization': 'haseen'},
    {'name': 'مدير العمليات', 'users': 1, 'organization': 'haseen'},
    {'name': 'مدير السلامة', 'users': 1, 'organization': 'haseen'},
    {'name': 'مفتش السلامة', 'users': 4, 'organization': 'haseen'},
    {'name': 'موظف العملاء والعقود', 'users': 1, 'organization': 'haseen'},
    {'name': 'مدير حساب المنشأة', 'users': 5, 'organization': 'facility'},
    {
      'name': 'مسؤول السلامة لدى المنشأة',
      'users': 7,
      'organization': 'facility',
    },
  ];

  static const demoRulesJson = <Map<String, Object?>>[
    {'title': 'منهجية التقييم', 'value': 'الاحتمال × الشدة (5×5)'},
    {'title': 'مهلة الخطر الحرج', 'value': 'احتواء 24 ساعة · معالجة 7 أيام'},
    {'title': 'مهلة الخطر العالي', 'value': '14 يوماً'},
    {'title': 'مهلة الخطر المتوسط', 'value': '30 يوماً'},
    {'title': 'مدة مراجعة نتائج التفتيش', 'value': 'يوما عمل'},
    {'title': 'تنبيه انتهاء العقد', 'value': 'قبل 60 و30 يوماً'},
    {'title': 'التصعيد', 'value': 'بعد 7 أيام تأخير'},
  ];
}
