import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/entities/finding_severity.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/entities/inspection_decision.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/presentation/config/finding_severity_style.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/presentation/config/inspection_decision_style.dart';

void main() {
  test('severity labels and colors match the original table', () {
    expect(
      {
        for (final s in FindingSeverity.values)
          s: (s.style.label, s.style.background, s.style.foreground),
      },
      {
        FindingSeverity.critical: (
          'حرج',
          const Color(0xFFF7D9D6),
          const Color(0xFFA3261E),
        ),
        FindingSeverity.high: (
          'عالٍ',
          const Color(0xFFFBE3CF),
          const Color(0xFF8A3B00),
        ),
        FindingSeverity.medium: (
          'متوسط',
          const Color(0xFFFAF0CC),
          const Color(0xFF6B5200),
        ),
        FindingSeverity.low: (
          'منخفض',
          const Color(0xFFD6EDE0),
          const Color(0xFF1E6B47),
        ),
      },
    );
  });

  test('decision pill labels and colors match the original _status()', () {
    expect(
      {
        for (final d in InspectionDecision.values)
          d: (d.style.label, d.style.background, d.style.foreground),
      },
      {
        InspectionDecision.approved: (
          'معتمد',
          const Color(0xFFE3F2EA),
          const Color(0xFF1E6B47),
        ),
        InspectionDecision.returned: (
          'أُعيد للمفتش',
          const Color(0xFFEEF1F4),
          const Color(0xFF41556A),
        ),
        InspectionDecision.pending: (
          'بانتظار',
          const Color(0xFFFDF1D8),
          const Color(0xFF6B4500),
        ),
      },
    );
  });
}
