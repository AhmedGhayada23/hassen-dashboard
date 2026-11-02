import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/core/routes/routes.dart';
import 'package:hassen_dashboard/core/theme/app_colors.dart';
import 'package:hassen_dashboard/core/theme/haseen_theme.dart';
import 'package:hassen_dashboard/features/auth/domain/failures/auth_failures.dart';
import 'package:hassen_dashboard/features/auth/domain/repositories/auth_repository.dart';
import 'package:hassen_dashboard/features/auth/domain/usecases/sign_in.dart';
import 'package:hassen_dashboard/features/auth/presentation/cubits/login_cubit.dart';
import 'package:hassen_dashboard/features/auth/presentation/pages/login_page.dart';
import 'package:hassen_dashboard/features/auth/presentation/widgets/login_brand_panel.dart';
import 'package:toastification/toastification.dart';

import '../../../../helpers/test_view.dart';
import '../../helpers/fake_auth_repository.dart';

const failureNotice = 'تعذّر تسجيل الدخول. حاول مرة أخرى.';

Finder get emailField => find.byType(TextFormField).at(0);
Finder get passwordField => find.byType(TextFormField).at(1);
Finder get submitButton => find.byType(FilledButton);

/// Hosts the page the way the app's router does, with a stand-in overview
/// route to observe navigation after a successful sign-in.
Future<LoginCubit> pumpLogin(
  WidgetTester tester, {
  AuthRepository? repository,
  Size size = const Size(1440, 900),
}) async {
  useDesktopView(tester, size: size);
  ignoreTestFontOverflow();
  late LoginCubit cubit;
  // A fresh tree, so a second call in one test builds a new route and cubit.
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(
    ToastificationWrapper(
      child: MaterialApp(
        theme: HaseenTheme.light,
        builder: (c, child) =>
            Directionality(textDirection: TextDirection.rtl, child: child!),
        initialRoute: Routes.login,
        onGenerateRoute: (settings) => MaterialPageRoute(
          settings: settings,
          builder: (_) => settings.name == Routes.login
              ? BlocProvider(
                  create: (_) => cubit = LoginCubit(
                    SignIn(repository ?? FakeAuthRepository()),
                  ),
                  child: const LoginPage(),
                )
              : const Text('overview-route'),
        ),
      ),
    ),
  );
  return cubit;
}

/// Lets error toasts run out their 5-second display so no timer outlives a test.
Future<void> closeToasts(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 6));
  await tester.pumpAndSettle();
}

Future<void> fillValid(WidgetTester tester) async {
  await tester.enterText(emailField, 'name@haseen.ps');
  await tester.enterText(passwordField, '12345678');
}

void main() {
  testWidgets('shows every original text, with the brand panel on wide windows', (
    tester,
  ) async {
    await pumpLogin(tester);

    for (final text in [
      'الحصين',
      'HASEEN',
      'تسجيل الدخول',
      'لوحة التحكم مخصصة لموظفي شركة الحصين.',
      'البريد الإلكتروني للعمل',
      'name@haseen.ps',
      'كلمة المرور',
      '••••••••',
      'تذكرني على هذا الجهاز',
      'نسيت كلمة المرور؟',
      'دخول',
      'الحسابات تُنشأ من قِبل مدير النظام فقط. لا يوجد تسجيل ذاتي.',
      'لوحة التحكم',
      'إدارة أذكى للسلامة.\nورؤية أوضح لكل منشأة.',
      'الزيارات، ونتائج التفتيش، والمخاطر، والإجراءات التصحيحية لجميع العملاء في مكان واحد.',
      '© 2026 الحصين HASEEN',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.text(failureNotice), findsNothing);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    // RTL: the brand panel is the first Row child, so it sits on the right.
    expect(tester.getTopRight(find.byType(LoginBrandPanel)).dx, 1440);
    expect(tester.getSize(find.byType(Form)).width, 400);
  });

  testWidgets('the brand panel shows from 960px and hides below', (
    tester,
  ) async {
    await pumpLogin(tester, size: const Size(960, 800));
    expect(find.byType(LoginBrandPanel), findsOneWidget);

    await pumpLogin(tester, size: const Size(959, 800));
    expect(find.byType(LoginBrandPanel), findsNothing);
    expect(find.text('تسجيل الدخول'), findsOneWidget);
  });

  testWidgets('empty fields show both errors and send nothing', (tester) async {
    final repository = FakeAuthRepository();
    await pumpLogin(tester, repository: repository);

    await tester.tap(submitButton);
    await tester.pump();

    expect(find.text('أدخل البريد الإلكتروني'), findsOneWidget);
    expect(find.text('كلمة المرور 8 أحرف على الأقل'), findsOneWidget);
    expect(repository.calls, isEmpty);
  });

  testWidgets('a malformed email and a 7-character password are rejected', (
    tester,
  ) async {
    final repository = FakeAuthRepository();
    await pumpLogin(tester, repository: repository);

    await tester.enterText(emailField, 'name@haseen');
    await tester.enterText(passwordField, '1234567');
    await tester.tap(submitButton);
    await tester.pump();

    expect(find.text('صيغة البريد غير صحيحة'), findsOneWidget);
    expect(find.text('كلمة المرور 8 أحرف على الأقل'), findsOneWidget);
    expect(repository.calls, isEmpty);
  });

  testWidgets(
    'admin sign-in: loading while the request runs, then the overview',
    (tester) async {
      final repository = FakeAuthRepository()
        ..result = const Right(adminUser)
        ..gate = Completer<void>();
      await pumpLogin(tester, repository: repository);
      await fillValid(tester);

      await tester.tap(submitButton);
      await tester.pump();
      expect(
        find.descendant(
          of: submitButton,
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      expect(find.text('دخول'), findsNothing);
      expect(tester.widget<FilledButton>(submitButton).onPressed, isNull);
      expect(find.text('overview-route'), findsNothing);

      repository.gate!.complete();
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsNothing);
      expect(find.text('overview-route'), findsOneWidget);
      // The sign-in is gone from the stack: "back" cannot return to it.
      expect(
        tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
        isFalse,
      );
    },
  );

  testWidgets(
    'while loading, neither the button nor Enter sends a second request',
    (tester) async {
      final repository = FakeAuthRepository()..gate = Completer<void>();
      await pumpLogin(tester, repository: repository);
      await fillValid(tester);

      await tester.tap(submitButton);
      await tester.pump();
      await tester.tap(submitButton, warnIfMissed: false);
      await tester.showKeyboard(passwordField);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(repository.calls, hasLength(1));
      repository.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.text(failureNotice), findsOneWidget);
      await closeToasts(tester);
    },
  );

  testWidgets('Enter in the password field submits, as in the original', (
    tester,
  ) async {
    final repository = FakeAuthRepository();
    await pumpLogin(tester, repository: repository);
    await fillValid(tester);

    await tester.showKeyboard(passwordField);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(repository.calls, hasLength(1));
    await closeToasts(tester);
  });

  testWidgets(
    'each failure shows its Arabic message as an error toast, and stays on sign-in',
    (tester) async {
      for (final (failure, message) in [
        (
          const InvalidCredentialsFailure(),
          'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
        ),
        (
          const AccessDeniedFailure(),
          'هذا الحساب لا يملك صلاحية الدخول إلى لوحة التحكم.',
        ),
        (
          const NetworkFailure(),
          'تعذّر الاتصال بالخادم. تحقق من الإنترنت وحاول مرة أخرى.',
        ),
      ]) {
        final repository = FakeAuthRepository()..result = Left(failure);
        await pumpLogin(tester, repository: repository);
        await fillValid(tester);

        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        expect(find.text(message), findsOneWidget, reason: '$failure');
        expect(find.byType(LoginPage), findsOneWidget);
        await closeToasts(tester);
      }
    },
  );

  testWidgets('a second failed attempt shows the toast again', (tester) async {
    await pumpLogin(tester);
    await fillValid(tester);

    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    await closeToasts(tester);
    expect(find.text(failureNotice), findsNothing);

    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text(failureNotice), findsOneWidget);
    await closeToasts(tester);
  });

  testWidgets('the eye button shows and hides the password', (tester) async {
    await pumpLogin(tester);
    bool obscured() => tester
        .widget<EditableText>(find.byType(EditableText).at(1))
        .obscureText;

    expect(obscured(), isTrue);
    expect(find.byTooltip('إظهار كلمة المرور'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();
    expect(obscured(), isFalse);
    expect(find.byTooltip('إخفاء كلمة المرور'), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();
    expect(obscured(), isTrue);
    // The email field is never obscured and stays left-to-right.
    final email = tester.widget<EditableText>(find.byType(EditableText).first);
    expect(
      (email.obscureText, email.textDirection),
      (false, TextDirection.ltr),
    );
  });

  testWidgets('"remember me" toggles and its value is sent with the request', (
    tester,
  ) async {
    final repository = FakeAuthRepository();
    await pumpLogin(tester, repository: repository);

    // The square test font pushes this row past the form, so the checkbox is
    // driven through its callback here; the overflow test taps it in Arial.
    tester.widget<Checkbox>(find.byType(Checkbox)).onChanged!(false);
    await tester.pump();
    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect((checkbox.value, checkbox.activeColor), (false, HaseenColors.navy));

    await fillValid(tester);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(repository.calls.single.rememberMe, isFalse);
    await closeToasts(tester);
  });

  testWidgets('"forgot password" shows the floating admin hint', (
    tester,
  ) async {
    await pumpLogin(tester);

    await tester.tap(find.text('نسيت كلمة المرور؟'));
    await tester.pump();

    expect(
      find.text('تواصل مع مدير النظام لإعادة تعيين كلمة المرور.'),
      findsOneWidget,
    );
    expect(
      tester.widget<SnackBar>(find.byType(SnackBar)).behavior,
      SnackBarBehavior.floating,
    );
  });

  testWidgets(
    'a successful sign-in replaces the page with the overview route',
    (tester) async {
      final repository = FakeAuthRepository()..result = const Right(adminUser);
      await pumpLogin(tester, repository: repository);
      await fillValid(tester);

      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsNothing);
      expect(find.text('overview-route'), findsOneWidget);
    },
  );

  testWidgets(
    'leaving the page disposes the text controllers and closes the cubit',
    (tester) async {
      final cubit = await pumpLogin(tester);
      final controllers = [
        for (final field in tester.widgetList<EditableText>(
          find.byType(EditableText),
        ))
          field.controller,
      ];
      expect(controllers, hasLength(2));

      await tester.pumpWidget(const SizedBox());

      for (final controller in controllers) {
        expect(() => controller.addListener(() {}), throwsFlutterError);
      }
      expect(cubit.isClosed, isTrue);
    },
  );
}
