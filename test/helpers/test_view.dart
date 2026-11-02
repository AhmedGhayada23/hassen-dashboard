import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/constants/app_layout.dart';

/// Desktop-sized test surface for the dashboard layout.
void useDesktopView(WidgetTester tester, {Size size = const Size(1440, 900)}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// flutter_test draws every glyph as a 1em square, so Arabic labels measure far
/// wider than in Arial and trip RenderFlex overflow asserts that never occur in
/// the app. Only those reports are dropped; every other error still fails.
void ignoreTestFontOverflow() {
  final original = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().startsWith('A RenderFlex overflowed')) {
      return;
    }
    original?.call(details);
  };
  addTearDown(() => FlutterError.onError = original);
}

/// Pumps [child] the way the app hosts it: ScreenUtil, Material 3, RTL.
Future<void> pumpDashboardWidget(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(1440, 900),
}) async {
  useDesktopView(tester, size: size);
  ignoreTestFontOverflow();
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: AppLayout.designSize,
      builder: (_, _) => MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: child),
        ),
      ),
    ),
  );
}
