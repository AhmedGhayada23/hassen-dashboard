import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/monthly_report.dart';
import '../../domain/entities/report_delivery.dart';
import '../config/reports_messages.dart';
import 'report_input_decoration.dart';

/// Asks where to email [report]; completes with the delivery, or null if
/// cancelled.
Future<ReportDelivery?> showSendReportDialog(
  BuildContext context,
  MonthlyReport report,
) => showDialog<ReportDelivery>(
  context: context,
  builder: (_) => Directionality(
    textDirection: TextDirection.rtl,
    child: SendReportDialog(report: report),
  ),
);

/// "إرسال التقرير عبر الإيميل": the facility's address (required), a copy
/// (optional), the subject, and the PDF attached.
class SendReportDialog extends StatefulWidget {
  final MonthlyReport report;

  const SendReportDialog({super.key, required this.report});

  @override
  State<SendReportDialog> createState() => _SendReportDialogState();
}

class _SendReportDialogState extends State<SendReportDialog> {
  static const invalidEmail = 'صيغة البريد غير صحيحة';

  final _form = GlobalKey<FormState>();
  final _to = TextEditingController();
  final _cc = TextEditingController();

  @override
  void dispose() {
    _to.dispose();
    _cc.dispose();
    super.dispose();
  }

  void _send() {
    if (!_form.currentState!.validate()) return;
    Navigator.pop(
      context,
      ReportDelivery(to: _to.text.trim(), cc: _cc.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final label = TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w700,
      color: HaseenColors.navy,
    );
    final muted = TextStyle(fontSize: 12.sp, color: HaseenColors.muted);
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 520.w),
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 12.w, 12.h),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: HaseenColors.line)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'إرسال التقرير عبر الإيميل',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          color: HaseenColors.navy,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'إغلاق',
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        size: 20.sp,
                        color: HaseenColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('إلى (بريد المنشأة)', style: label),
                      SizedBox(height: 6.h),
                      TextFormField(
                        controller: _to,
                        keyboardType: TextInputType.emailAddress,
                        textDirection: TextDirection.ltr,
                        decoration: reportInputDecoration(),
                        validator: (v) {
                          final text = v?.trim() ?? '';
                          if (text.isEmpty) return 'أدخل بريد المنشأة';
                          return ReportDelivery.isValidEmail(text)
                              ? null
                              : invalidEmail;
                        },
                      ),
                      SizedBox(height: 14.h),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: 'نسخة إلى', style: label),
                            TextSpan(text: '  اختياري', style: muted),
                          ],
                        ),
                      ),
                      SizedBox(height: 6.h),
                      TextFormField(
                        controller: _cc,
                        keyboardType: TextInputType.emailAddress,
                        textDirection: TextDirection.ltr,
                        decoration: reportInputDecoration(),
                        validator: (v) {
                          final text = v?.trim() ?? '';
                          return text.isEmpty ||
                                  ReportDelivery.isValidEmail(text)
                              ? null
                              : invalidEmail;
                        },
                      ),
                      SizedBox(height: 14.h),
                      Text('الموضوع', style: muted),
                      Text(
                        ReportsMessages.subject(widget.report),
                        style: label,
                      ),
                      SizedBox(height: 14.h),
                      _Attachment(fileName: widget.report.fileName),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: HaseenColors.tableHeader,
                  border: const Border(
                    top: BorderSide(color: HaseenColors.line),
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(14.r),
                  ),
                ),
                child: Row(
                  children: [
                    FilledButton(
                      onPressed: _send,
                      style: FilledButton.styleFrom(
                        backgroundColor: HaseenColors.gold,
                        foregroundColor: HaseenColors.navy,
                        minimumSize: Size(0, 42.h),
                        padding: EdgeInsets.symmetric(horizontal: 22.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: const Text(
                        'إرسال',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: HaseenColors.navy,
                        minimumSize: Size(0, 42.h),
                        side: const BorderSide(color: HaseenColors.fieldBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: const Text(
                        'إلغاء',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The PDF the report goes out as.
class _Attachment extends StatelessWidget {
  final String fileName;

  const _Attachment({required this.fileName});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(10.r),
    decoration: BoxDecoration(
      color: HaseenColors.tableHeader,
      border: Border.all(color: HaseenColors.line),
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Row(
      children: [
        Container(
          width: 32.r,
          height: 32.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: HaseenColors.dangerSoft,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            'PDF',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: HaseenColors.red,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            fileName,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w700,
              color: HaseenColors.navy,
            ),
          ),
        ),
      ],
    ),
  );
}
