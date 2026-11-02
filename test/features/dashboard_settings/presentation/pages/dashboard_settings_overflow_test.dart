import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/constants/app_layout.dart';
import 'package:hassen_dashboard/core/theme/haseen_theme.dart';
import 'package:hassen_dashboard/features/dashboard_settings/presentation/pages/dashboard_settings_page.dart';
import 'package:hassen_dashboard/features/dashboard_settings/presentation/widgets/operation_rule_row.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/cubits/dashboard_navigation_cubit.dart';

import '../../../../helpers/test_view.dart';
import '../../helpers/settings_cubit_factory.dart';

/// The default test font draws every glyph as a 1em square, which would
/// report overflows Arial never has; these checks need the real font, so they
/// run only where Arial is installed.
const _arial = 'C:/Windows/Fonts/arial.ttf';
const _arialBold = 'C:/Windows/Fonts/arialbd.ttf';
final _skip = File(_arial).existsSync() && File(_arialBold).existsSync()
    ? false
    : 'Arial is not installed';

void main() {
  setUpAll(() async {
    if (_skip != false) return;
    ByteData font(String path) =>
        ByteData.sublistView(File(path).readAsBytesSync());
    await (FontLoader('Arial')
          ..addFont(Future.value(font(_arial)))
          ..addFont(Future.value(font(_arialBold))))
        .load();
  });

  for (final size in const [
    Size(1920, 1080),
    Size(1440, 900),
    Size(1280, 800),
    Size(1024, 768),
  ]) {
    testWidgets(
      'no overflow at ${size.width.toInt()}×${size.height.toInt()}',
      (tester) async {
        // No overflow filter: any layout error fails the test.
        useDesktopView(tester, size: size);
        final cubit = buildSettingsCubit(FakeSettingsRepository());
        addTearDown(cubit.close);
        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => DashboardNavigationCubit()),
              BlocProvider.value(value: cubit),
            ],
            child: ScreenUtilInit(
              designSize: AppLayout.designSize,
              builder: (_, _) => MaterialApp(
                theme: HaseenTheme.light,
                home: const Directionality(
                  textDirection: TextDirection.rtl,
                  child: DashboardSettingsPage(),
                ),
              ),
            ),
          ),
        );
        await cubit.load();
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(OperationRuleRow), findsNWidgets(7));
      },
      skip: _skip != false,
    );
  }
}
