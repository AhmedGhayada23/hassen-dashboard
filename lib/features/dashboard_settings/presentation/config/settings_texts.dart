import 'package:flutter/painting.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/system_role.dart';

/// User-facing settings-page text.
class SettingsTexts {
  SettingsTexts._();

  static const templatesTitle = 'نماذج الفحص';
  static const rolesTitle = 'الأدوار والصلاحيات';
  static const rulesTitle = 'قواعد التشغيل';
  static const addTemplate = '+ نموذج';

  /// Shown by "+ نموذج" until the template editor exists.
  static const editorNotReady = 'محرر النماذج يُربط بالخادم عند التنفيذ';

  static String items(int count) => '$count بنداً';

  static String users(int count) => '$count مستخدم';
}

/// The organization pill on a role: label and colors.
extension RoleOrganizationStyling on RoleOrganization {
  (String, Color, Color) get pill => switch (this) {
    RoleOrganization.haseen => (
      'الحصين',
      HaseenColors.infoSoft,
      HaseenColors.infoText,
    ),
    RoleOrganization.facility => (
      'المنشأة',
      HaseenColors.tealSoft,
      HaseenColors.tealText,
    ),
  };
}
