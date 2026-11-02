import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

/// Error toast shared by every page: top-centre, right-to-left, auto-closing.
void showErrorToast(BuildContext context, String message) =>
    _show(context, message, ToastificationType.error);

/// Confirmation toast, styled like [showErrorToast]. With [actionLabel], it
/// carries a button that runs [onAction] and closes the toast.
void showSuccessToast(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) => _show(
  context,
  message,
  ToastificationType.success,
  actionLabel: actionLabel,
  onAction: onAction,
);

void _show(
  BuildContext context,
  String message,
  ToastificationType type, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  late final ToastificationItem toast;
  toast = toastification.show(
    context: context,
    type: type,
    style: ToastificationStyle.flatColored,
    title: Text(message),
    description: actionLabel == null
        ? null
        : Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () {
                toastification.dismiss(toast);
                onAction?.call();
              },
              child: Text(
                actionLabel,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
    alignment: Alignment.topCenter,
    direction: TextDirection.rtl,
    autoCloseDuration: const Duration(seconds: 5),
    showProgressBar: false,
  );
}
