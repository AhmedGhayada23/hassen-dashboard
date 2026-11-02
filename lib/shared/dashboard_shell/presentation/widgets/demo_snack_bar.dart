import 'package:flutter/material.dart';

/// Placeholder feedback for actions that need the backend.
void showDemoSnackBar(BuildContext context, String message) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('نموذج توضيحي — $message'),
        behavior: SnackBarBehavior.floating,
      ),
    );
