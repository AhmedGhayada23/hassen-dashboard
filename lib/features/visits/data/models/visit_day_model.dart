import '../../domain/entities/visit_day.dart';

class VisitDayModel {
  final int order;
  final String label;
  final String date;

  const VisitDayModel({
    required this.order,
    required this.label,
    required this.date,
  });

  factory VisitDayModel.fromJson(Map<String, Object?> json) => VisitDayModel(
    order: json['order'] as int,
    label: json['label'] as String,
    date: json['date'] as String,
  );

  VisitDay toEntity() => VisitDay(order: order, label: label, date: date);
}
