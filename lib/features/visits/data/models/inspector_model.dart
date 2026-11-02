import '../../domain/entities/inspector.dart';

/// A safety inspector: a `users` document whose `role` is `inspector`.
class InspectorModel {
  final String id;
  final String name;

  const InspectorModel({required this.id, required this.name});

  factory InspectorModel.fromUserDocument(
    String uid,
    Map<String, Object?> json,
  ) => InspectorModel(id: uid, name: (json['name'] as String? ?? '').trim());

  Inspector toEntity() => Inspector(id: id, name: name);
}
