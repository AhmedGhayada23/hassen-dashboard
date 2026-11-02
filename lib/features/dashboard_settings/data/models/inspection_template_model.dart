import '../../domain/entities/inspection_template.dart';

/// An inspection template as JSON: `name`, `version`, `items`.
class InspectionTemplateModel {
  final String name;
  final String version;
  final int items;

  const InspectionTemplateModel({
    required this.name,
    required this.version,
    required this.items,
  });

  /// Throws on a malformed payload or a template with no items.
  factory InspectionTemplateModel.fromJson(Map<String, Object?> json) {
    final model = InspectionTemplateModel(
      name: json['name']! as String,
      version: json['version']! as String,
      items: json['items']! as int,
    );
    if (model.items < 1) {
      throw FormatException('Template ${model.name} has no items.');
    }
    return model;
  }

  InspectionTemplate toEntity() =>
      InspectionTemplate(name: name, version: version, items: items);
}
