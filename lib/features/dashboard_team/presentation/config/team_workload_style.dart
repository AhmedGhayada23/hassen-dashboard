import 'package:flutter/painting.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/team_member.dart';

extension TeamWorkloadStyle on TeamMember {
  /// Orange once over the overload threshold (strictly above 80%), teal otherwise.
  Color get workloadColor =>
      isOverloaded ? HaseenColors.highStrong : HaseenColors.teal;

  Color get lateVisitsColor =>
      hasLateVisits ? HaseenColors.red : HaseenColors.navy;
}
