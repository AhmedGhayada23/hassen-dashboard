import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/client_registration_options.dart';
import '../../domain/entities/client_stage.dart';
import '../../domain/entities/new_client.dart';
import '../cubits/add_client_form_cubit.dart';
import '../validation/add_client_validator.dart';
import 'add_client_fields.dart';
import 'add_client_footer.dart';
import 'add_client_stage_card.dart';

/// Opens the registration form; completes with the new client, or null if
/// cancelled. [existingNames] are refused as duplicates.
Future<NewClient?> showAddClientDialog(
  BuildContext context, {
  required ClientRegistrationOptions options,
  required Set<String> existingNames,
}) => showDialog<NewClient>(
  context: context,
  builder: (_) => Directionality(
    textDirection: TextDirection.rtl,
    child: BlocProvider(
      create: (_) => AddClientFormCubit(options),
      child: AddClientDialog(existingNames: existingNames),
    ),
  ),
);

/// "عميل جديد": the facility, its contact person, the starting stage, and
/// the assignment. Expects an [AddClientFormCubit] above it.
class AddClientDialog extends StatefulWidget {
  final Set<String> existingNames;

  const AddClientDialog({super.key, required this.existingNames});

  @override
  State<AddClientDialog> createState() => _AddClientDialogState();
}

class _AddClientDialogState extends State<AddClientDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _branches = TextEditingController(text: '1');
  final _city = TextEditingController();
  final _address = TextEditingController();
  final _contactName = TextEditingController();
  final _contactTitle = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _name,
      _branches,
      _city,
      _address,
      _contactName,
      _contactTitle,
      _email,
      _phone,
      _note,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final choices = context.read<AddClientFormCubit>().state;
    Navigator.pop(
      context,
      NewClient(
        name: _name.text.trim(),
        sector: choices.sector!,
        branches: int.parse(_branches.text.trim()),
        city: _city.text.trim(),
        address: _address.text.trim(),
        contactName: _contactName.text.trim(),
        contactTitle: _contactTitle.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        stage: choices.stage,
        inspector: choices.inspector,
        note: _note.text.trim(),
        schedulePreInspection: choices.schedulePreInspection,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddClientFormCubit>();
    return BlocBuilder<AddClientFormCubit, AddClientFormState>(
      builder: (context, form) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 640.w),
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TitleBar(onClose: () => Navigator.pop(context)),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 18.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ..._facility(cubit),
                        SizedBox(height: 18.h),
                        ..._contact(),
                        SizedBox(height: 18.h),
                        ..._stage(cubit, form),
                        SizedBox(height: 18.h),
                        ..._assignment(cubit, form),
                      ],
                    ),
                  ),
                ),
                AddClientFooter(
                  onSubmit: _submit,
                  onCancel: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _facility(AddClientFormCubit cubit) => [
    const AddClientSection('1 · بيانات المنشأة'),
    const AddClientFieldLabel('اسم المنشأة'),
    TextFormField(
      controller: _name,
      decoration: addClientInputDecoration(),
      validator: (v) => AddClientValidator.name(v, widget.existingNames),
    ),
    SizedBox(height: 14.h),
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AddClientFieldLabel('القطاع'),
              DropdownButtonFormField<String>(
                hint: Text('اختر القطاع', style: TextStyle(fontSize: 14.sp)),
                decoration: addClientInputDecoration(),
                items: [
                  for (final s in cubit.options.sectors) addClientOption(s, s),
                ],
                onChanged: (v) {
                  if (v != null) cubit.selectSector(v);
                },
                validator: AddClientValidator.sector,
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        SizedBox(
          width: 120.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AddClientFieldLabel('عدد الفروع'),
              TextFormField(
                controller: _branches,
                keyboardType: TextInputType.number,
                decoration: addClientInputDecoration(),
                validator: AddClientValidator.branches,
              ),
            ],
          ),
        ),
      ],
    ),
    SizedBox(height: 14.h),
    AddClientFieldPair(
      start: AddClientTextField(
        label: 'المدينة',
        controller: _city,
        optional: true,
        hint: 'غزة',
      ),
      end: AddClientTextField(
        label: 'العنوان',
        controller: _address,
        optional: true,
      ),
    ),
  ];

  List<Widget> _contact() => [
    const AddClientSection('2 · جهة التواصل لدى المنشأة'),
    AddClientFieldPair(
      start: AddClientTextField(
        label: 'الاسم',
        controller: _contactName,
        validator: AddClientValidator.contactName,
      ),
      end: AddClientTextField(
        label: 'المسمى الوظيفي',
        controller: _contactTitle,
        optional: true,
        hint: 'مسؤول السلامة',
      ),
    ),
    SizedBox(height: 14.h),
    AddClientFieldPair(
      start: AddClientTextField(
        label: 'البريد الإلكتروني',
        controller: _email,
        leftToRight: true,
        keyboardType: TextInputType.emailAddress,
        validator: (v) => AddClientValidator.email(v, phone: _phone.text),
      ),
      end: AddClientTextField(
        label: 'رقم الهاتف',
        controller: _phone,
        leftToRight: true,
        keyboardType: TextInputType.phone,
        validator: AddClientValidator.phone,
      ),
    ),
  ];

  List<Widget> _stage(AddClientFormCubit cubit, AddClientFormState form) => [
    const AddClientSection('3 · المرحلة'),
    Row(
      children: [
        for (final (i, stage) in ClientStage.forNewClient.indexed) ...[
          if (i > 0) SizedBox(width: 8.w),
          Expanded(
            child: AddClientStageCard(
              stage: stage,
              selected: stage == form.stage,
              onTap: () => cubit.selectStage(stage),
            ),
          ),
        ],
      ],
    ),
    SizedBox(height: 6.h),
    Text(
      'يصبح العميل «متعاقداً» بعد توقيع العقد من صفحة العروض والعقود.',
      style: TextStyle(fontSize: 12.sp, color: HaseenColors.muted),
    ),
  ];

  List<Widget> _assignment(AddClientFormCubit cubit, AddClientFormState form) {
    final suggested = cubit.options.suggestedInspector;
    return [
      const AddClientSection('4 · الإسناد'),
      Row(
        children: [
          const Expanded(
            child: AddClientFieldLabel('المفتش المسؤول', optional: true),
          ),
          TextButton(
            onPressed: cubit.assignSuggestedInspector,
            style: TextButton.styleFrom(foregroundColor: HaseenColors.teal),
            child: Text(
              'اختيار المقترح',
              style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      DropdownButtonFormField<String>(
        // Rebuilt when "اختيار المقترح" picks the inspector.
        key: ValueKey(form.inspector),
        initialValue: form.inspector,
        decoration: addClientInputDecoration(),
        items: [
          addClientOption('', 'بدون إسناد الآن'),
          for (final i in cubit.options.inspectors)
            addClientOption(
              i.name,
              '${i.name} — ${i.weeklyVisits} زيارات هذا الأسبوع'
              '${i == suggested ? ' (مقترح)' : ''}',
            ),
        ],
        onChanged: (v) => cubit.selectInspector(v ?? ''),
      ),
      SizedBox(height: 14.h),
      const AddClientFieldLabel('ملاحظات', optional: true),
      TextFormField(
        controller: _note,
        maxLines: 2,
        decoration: addClientInputDecoration(),
      ),
      SizedBox(height: 14.h),
      Material(
        color: HaseenColors.tableHeader,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
          side: const BorderSide(color: HaseenColors.line),
        ),
        child: CheckboxListTile(
          value: form.schedulePreInspection,
          onChanged: (v) => cubit.setSchedulePreInspection(v ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: HaseenColors.navy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          title: Text(
            'جدولة فحص أولي بعد الإضافة',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: HaseenColors.navy,
            ),
          ),
          subtitle: Text(
            'يُسجَّل العميل بحالة «فحص أولي مطلوب»',
            style: TextStyle(fontSize: 12.sp, color: HaseenColors.muted),
          ),
        ),
      ),
    ];
  }
}

class _TitleBar extends StatelessWidget {
  final VoidCallback onClose;

  const _TitleBar({required this.onClose});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(20.w, 12.h, 12.w, 12.h),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: HaseenColors.line)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            'عميل جديد',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: HaseenColors.navy,
            ),
          ),
        ),
        IconButton(
          tooltip: 'إغلاق',
          onPressed: onClose,
          icon: Icon(Icons.close, size: 20.sp, color: HaseenColors.muted),
        ),
      ],
    ),
  );
}
