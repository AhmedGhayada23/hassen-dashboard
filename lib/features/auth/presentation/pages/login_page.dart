import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/routes.dart';
import '../../../../core/widgets/app_toast.dart';
import '../config/login_layout_config.dart';
import '../config/login_messages.dart';
import '../cubits/login_cubit.dart';
import '../cubits/login_state.dart';
import '../widgets/login_brand_panel.dart';
import '../widgets/login_form.dart';

/// Brand panel (wide windows only) beside the centred, scrollable form.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wide =
        MediaQuery.sizeOf(context).width >=
        LoginLayoutConfig.brandPanelMinWidth;
    return BlocListener<LoginCubit, LoginState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) => switch (state) {
        LoginState(status: LoginStatus.success) => Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(Routes.overview, (_) => false),
        LoginState(status: LoginStatus.failure, :final failure?) =>
          showErrorToast(context, LoginMessages.forFailure(failure)),
        _ => null,
      },
      child: Scaffold(
        body: Row(
          children: [
            if (wide)
              const Expanded(
                flex: LoginLayoutConfig.brandPanelFlex,
                child: LoginBrandPanel(),
              ),
            Expanded(
              flex: LoginLayoutConfig.formFlex,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(LoginLayoutConfig.formPadding),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: LoginLayoutConfig.formMaxWidth,
                    ),
                    child: const LoginForm(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
