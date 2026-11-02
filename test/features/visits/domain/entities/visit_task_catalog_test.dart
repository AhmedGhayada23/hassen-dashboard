import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_facility.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_task.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_task_catalog.dart';

import '../../fixtures/visits_fixture.dart';

void main() {
  VisitFacility facility(String name) =>
      expectedOptions.facilities.firstWhere((f) => f.name == name);
  List<VisitTask> routine(String name) =>
      expectedOptions.autoTasksFor(facility(name), 'تفتيش دوري');

  test(
    'a routine visit runs the sector template, then checks each open action',
    () {
      expect(routine('مستشفى الشفاء'), const [
        VisitTask(
          id: 'tpl',
          title: 'تنفيذ نموذج الفحص: تفتيش المنشآت الصحية v2',
          detail: '38 بنداً',
          source: VisitTaskSource.template,
        ),
        VisitTask(
          id: 'CA-0431',
          title: 'التحقق من CA-0431: إزالة الأسرّة من أمام مخرج الطوارئ 2',
          detail: 'إجراء مفتوح (حرج) — يتابع حالته',
          source: VisitTaskSource.correctiveAction,
        ),
        VisitTask(
          id: 'CA-0399',
          title: 'التحقق من CA-0399: توفير ملصقات لمواد التنظيف',
          detail: 'إجراء قيد التنفيذ (متوسط) — يتابع حالته',
          source: VisitTaskSource.correctiveAction,
        ),
      ]);
    },
  );

  test('uploaded evidence is checked on site', () {
    expect(
      routine('بنك فلسطين').last.detail,
      'المنشأة رفعت دليل المعالجة — يتحقق منه ميدانياً',
    );
  });

  test('a sector without a template of its own gets the default one', () {
    expect(
      routine('بلدية غزة').first.title,
      'تنفيذ نموذج الفحص: تفتيش المباني الإدارية v1',
    );
    expect(
      routine('مدرسة خاصة — غزة').single.title,
      'تنفيذ نموذج الفحص: تفتيش المباني الإدارية v1',
    );
  });

  test('a pre-contract assessment is the pre-contract template only', () {
    expect(
      expectedOptions.autoTasksFor(facility('مستشفى الشفاء'), 'فحص أولي'),
      const [
        VisitTask(
          id: 'tpl',
          title: 'تنفيذ نموذج الفحص: الفحص الأولي قبل التعاقد v2',
          detail: '30 بنداً',
          source: VisitTaskSource.template,
        ),
      ],
    );
  });

  test('a follow-up visit is still checked against open actions', () {
    expect(
      expectedOptions
          .autoTasksFor(facility('مصنع العودة'), 'متابعة ملاحظات')
          .map((t) => t.id),
      ['tpl', 'CA-0412'],
    );
  });

  test('with no templates or actions there is nothing to suggest', () {
    expect(
      const VisitTaskCatalog().autoTasksFor(
        facility('مستشفى الشفاء'),
        isPreContract: false,
      ),
      isEmpty,
    );
  });

  test('a booked visit carries its tasks and a trimmed note', () {
    final visit = expectedOptions.buildVisit(
      inspector: layla,
      day: wed,
      time: '10:00',
      facility: facility('بنك فلسطين'),
      type: 'تفتيش دوري',
      tasks: routine('بنك فلسطين'),
      note: '  الدخول من البوابة الخلفية ',
    );

    expect(visit.tasks, routine('بنك فلسطين'));
    expect(visit.note, 'الدخول من البوابة الخلفية');
  });
}
