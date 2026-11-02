// HASEEN Dashboard
// Flutter 3.x (Web / Desktop) · Material 3 · RTL · Arial
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toastification/toastification.dart';

import 'core/constants/app_layout.dart';
import 'core/di/injection_container.dart' as di;
import 'core/routes/app_router.dart';
import 'core/routes/routes.dart';
import 'core/theme/haseen_theme.dart';
import 'core/usecases/usecase.dart';
import 'features/auth/domain/usecases/get_signed_in_admin.dart';
import 'firebase_options.dart';
import 'shared/dashboard_shell/presentation/cubits/dashboard_navigation_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await di.init();
  runApp(HaseenDashboardApp(initialRoute: await _startRoute()));
}

/// The overview for an admin still signed in on this device ("remember me");
/// otherwise — including when the check fails or takes too long — sign-in.
Future<String> _startRoute() async {
  try {
    final result = await di.sl<GetSignedInAdmin>()(const NoParams()).timeout(
      const Duration(seconds: 10),
    );
    return result.fold(
      (_) => Routes.login,
      (admin) => admin == null ? Routes.login : Routes.overview,
    );
  } catch (_) {
    return Routes.login;
  }
}

class HaseenDashboardApp extends StatelessWidget {
  /// Where the app opens; sign-in by default.
  final String initialRoute;

  const HaseenDashboardApp({super.key, this.initialRoute = Routes.login});

  @override
  Widget build(BuildContext context) => BlocProvider(
    // App-shell state: shared by every route that shows the sidebar.
    create: (_) => DashboardNavigationCubit(),
    child: ScreenUtilInit(
      designSize: AppLayout.designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => ToastificationWrapper(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'HASEEN Dashboard',
          builder: (c, child) =>
              Directionality(textDirection: TextDirection.rtl, child: child!),
          theme: HaseenTheme.light,
          initialRoute: initialRoute,
          // Only the requested route: the default would also stack '/' (the
          // overview) under '/login', letting "back" skip the sign-in.
          onGenerateInitialRoutes: (name) => [
            AppRouter.generateRoute(RouteSettings(name: name)),
          ],
          onGenerateRoute: AppRouter.generateRoute,
        ),
      ),
    ),
  );
}
