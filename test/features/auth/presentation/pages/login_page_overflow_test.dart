import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/theme/haseen_theme.dart';
import 'package:hassen_dashboard/features/auth/domain/usecases/sign_in.dart';
import 'package:hassen_dashboard/features/auth/presentation/cubits/login_cubit.dart';
import 'package:hassen_dashboard/features/auth/presentation/pages/login_page.dart';
import 'package:toastification/toastification.dart';

import '../../../../helpers/test_view.dart';
import '../../helpers/fake_auth_repository.dart';

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
    await (FontLoader('Arial')
          ..addFont(
            Future.value(ByteData.sublistView(File(_arial).readAsBytesSync())),
          )
          ..addFont(
            Future.value(
              ByteData.sublistView(File(_arialBold).readAsBytesSync()),
            ),
          ))
        .load();
  });

  const sizes = [
    Size(1920, 1080),
    Size(1440, 900),
    Size(1280, 800),
    Size(1024, 768),
    Size(960, 640),
    Size(959, 640),
    Size(800, 600),
    Size(600, 900),
    Size(390, 844),
    Size(360, 640),
  ];

  for (final size in sizes) {
    testWidgets(
      'no overflow at ${size.width.toInt()}×${size.height.toInt()}, with errors and the notice',
      (tester) async {
        // No overflow filter: any layout error fails the test.
        useDesktopView(tester, size: size);
        await tester.pumpWidget(
          ToastificationWrapper(
            child: MaterialApp(
              theme: HaseenTheme.light,
              builder: (c, child) => Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              ),
              home: BlocProvider(
                create: (_) => LoginCubit(SignIn(FakeAuthRepository())),
                child: const LoginPage(),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(FilledButton));
        await tester.pump();
        expect(find.text('أدخل البريد الإلكتروني'), findsOneWidget);

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'name@haseen.ps',
        );
        await tester.enterText(find.byType(TextFormField).at(1), '12345678');
        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();
        expect(find.text('تعذّر تسجيل الدخول. حاول مرة أخرى.'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.visibility_outlined));
        await tester.tap(find.byType(Checkbox));
        await tester.pump();
        expect(
          tester
              .widget<EditableText>(find.byType(EditableText).at(1))
              .obscureText,
          isFalse,
        );
        expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
        expect(tester.takeException(), isNull);
        // Let the error toast run out so no timer outlives the test.
        await tester.pump(const Duration(seconds: 6));
        await tester.pumpAndSettle();
      },
      skip: _skip != false,
    );
  }
}
