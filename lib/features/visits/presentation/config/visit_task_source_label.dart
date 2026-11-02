import '../../domain/entities/visit_task.dart';

extension VisitTaskSourceLabel on VisitTaskSource {
  /// The teal line under a task saying where it came from.
  String get label => switch (this) {
    VisitTaskSource.template => 'تلقائي — حسب قطاع المنشأة',
    VisitTaskSource.correctiveAction => 'تلقائي — من الإجراءات التصحيحية',
    VisitTaskSource.manual => 'أضافها مدير العمليات',
  };
}

/// "3 مهام", as the original words every count.
String visitTaskCount(int count) => '$count مهام';
