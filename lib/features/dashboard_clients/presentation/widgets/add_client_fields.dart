import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

/// Numbered teal section title with a hairline under it.
class AddClientSection extends StatelessWidget {
  final String text;

  const AddClientSection(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(bottom: 12.h),
    padding: EdgeInsets.only(bottom: 6.h),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: HaseenColors.soft)),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        color: HaseenColors.teal,
      ),
    ),
  );
}

/// Bold field label, with a muted "اختياري" after optional fields.
class AddClientFieldLabel extends StatelessWidget {
  final String text;
  final bool optional;

  const AddClientFieldLabel(this.text, {super.key, this.optional = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 6.h),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: text,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: HaseenColors.navy,
            ),
          ),
          if (optional)
            TextSpan(
              text: '  اختياري',
              style: TextStyle(fontSize: 12.sp, color: HaseenColors.muted),
            ),
        ],
      ),
    ),
  );
}

/// Compact outlined decoration of the form's inputs, red on error.
InputDecoration addClientInputDecoration({String? hint}) {
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: color, width: width),
      );
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: HaseenColors.fieldHint),
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
    enabledBorder: border(HaseenColors.fieldBorder),
    focusedBorder: border(HaseenColors.navy, 1.5),
    errorBorder: border(HaseenColors.red),
    focusedErrorBorder: border(HaseenColors.red, 1.5),
  );
}

/// A labelled text input of the "new client" form.
class AddClientTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool optional;
  final bool leftToRight;
  final String? hint;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;

  const AddClientTextField({
    super.key,
    required this.label,
    required this.controller,
    this.optional = false,
    this.leftToRight = false,
    this.hint,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AddClientFieldLabel(label, optional: optional),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textDirection: leftToRight ? TextDirection.ltr : null,
        decoration: addClientInputDecoration(hint: hint),
        validator: validator,
      ),
    ],
  );
}

/// Two inputs side by side, 12px apart.
class AddClientFieldPair extends StatelessWidget {
  final Widget start;
  final Widget end;

  const AddClientFieldPair({super.key, required this.start, required this.end});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: start),
      SizedBox(width: 12.w),
      Expanded(child: end),
    ],
  );
}

/// A dropdown option with the form's 14px text.
DropdownMenuItem<T> addClientOption<T>(T value, String label) =>
    DropdownMenuItem(
      value: value,
      child: Text(label, style: TextStyle(fontSize: 14.sp)),
    );
