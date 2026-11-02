import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/employee_role.dart';
import '../../domain/entities/new_employee.dart';
import '../cubits/employee_role_cubit.dart';
import '../validation/add_employee_validator.dart';
import 'add_employee_field.dart';
import 'add_employee_footer.dart';
import 'employee_role_card.dart';

/// Opens the invitation form; completes with the new employee, or null if
/// cancelled.
Future<NewEmployee?> showAddEmployeeDialog(
  BuildContext context, {
  required List<EmployeeRole> roles,
}) => showDialog<NewEmployee>(
  context: context,
  builder: (_) => Directionality(
    textDirection: TextDirection.rtl,
    child: BlocProvider(
      create: (_) => EmployeeRoleCubit(roles),
      child: AddEmployeeDialog(roles: roles),
    ),
  ),
);

/// "إضافة موظف": name, work email, optional phone and a role. Expects an
/// [EmployeeRoleCubit] above it.
class AddEmployeeDialog extends StatefulWidget {
  final List<EmployeeRole> roles;

  const AddEmployeeDialog({super.key, required this.roles});

  @override
  State<AddEmployeeDialog> createState() => _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<AddEmployeeDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    Navigator.pop(
      context,
      NewEmployee(
        fullName: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        role: context.read<EmployeeRoleCubit>().state,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
    insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 560.w),
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
                    const AddEmployeeFieldLabel('الاسم الكامل'),
                    TextFormField(
                      controller: _name,
                      decoration: addEmployeeInputDecoration(),
                      validator: AddEmployeeValidator.fullName,
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _emailField()),
                        SizedBox(width: 12.w),
                        Expanded(child: _phoneField()),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    const AddEmployeeFieldLabel('الدور'),
                    BlocBuilder<EmployeeRoleCubit, EmployeeRole>(
                      builder: (context, selected) => Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: [
                          for (final role in widget.roles)
                            SizedBox(
                              width: 254.w,
                              child: EmployeeRoleCard(
                                role: role,
                                selected: role == selected,
                                onTap: () => context
                                    .read<EmployeeRoleCubit>()
                                    .select(role),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AddEmployeeFooter(
              onSubmit: _submit,
              onCancel: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _emailField() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const AddEmployeeFieldLabel('البريد الإلكتروني للعمل'),
      TextFormField(
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        textDirection: TextDirection.ltr,
        decoration: addEmployeeInputDecoration(hint: 'name@haseen.ps'),
        validator: AddEmployeeValidator.email,
      ),
    ],
  );

  Widget _phoneField() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          const AddEmployeeFieldLabel('رقم الهاتف'),
          SizedBox(width: 6.w),
          Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Text(
              'اختياري',
              style: TextStyle(fontSize: 12.sp, color: HaseenColors.muted),
            ),
          ),
        ],
      ),
      TextFormField(
        controller: _phone,
        keyboardType: TextInputType.phone,
        textDirection: TextDirection.ltr,
        decoration: addEmployeeInputDecoration(),
        validator: AddEmployeeValidator.phone,
      ),
    ],
  );
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
            'إضافة موظف',
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
