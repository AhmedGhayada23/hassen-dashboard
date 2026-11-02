import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_status.dart';
import 'package:hassen_dashboard/features/visits/presentation/config/visit_status_style.dart';

void main() {
  test('labels and colors match the original visitStyles table', () {
    final styles = {
      for (final s in VisitStatus.values)
        s: (s.style.label, s.style.background, s.style.bar, s.style.foreground),
    };

    expect(styles, {
      VisitStatus.done: (
        'منجزة',
        const Color(0xFFE3F2EA),
        const Color(0xFF2E9466),
        const Color(0xFF1E6B47),
      ),
      VisitStatus.inProgress: (
        'جارية',
        const Color(0xFFFDF1D8),
        const Color(0xFFE8A319),
        const Color(0xFF6B4500),
      ),
      VisitStatus.planned: (
        'مجدولة',
        const Color(0xFFF4F6F8),
        const Color(0xFF9FB0C1),
        const Color(0xFF41556A),
      ),
      VisitStatus.preContract: (
        'فحص أولي قبل التعاقد',
        const Color(0xFFFDF4F3),
        const Color(0xFFC8382F),
        const Color(0xFFA3261E),
      ),
    });
  });
}
