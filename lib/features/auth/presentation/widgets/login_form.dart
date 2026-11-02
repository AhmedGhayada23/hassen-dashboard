import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../config/login_messages.dart';
import '../cubits/login_cubit.dart';
import '../cubits/login_state.dart';
import '../validation/login_validator.dart';
import 'login_header.dart';
import 'login_options_row.dart';
import 'login_password_field.dart';
import 'login_submit_button.dart';
import 'login_text_field.dart';

/// The sign-in form. Owns the text controllers and form key (UI resources);
/// every piece of state lives in [LoginCubit].
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    final cubit = context.read<LoginCubit>();
    if (cubit.state.isSubmitting) return;
    cubit.clearFailure();
    if (!_form.currentState!.validate()) return;
    cubit.signIn(email: _email.text, password: _password.text);
  }

  void _showForgotPassword() => ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(LoginMessages.forgotPassword),
    ),
  );

  @override
  Widget build(BuildContext context) => BlocBuilder<LoginCubit, LoginState>(
    builder: (context, state) {
      final cubit = context.read<LoginCubit>();
      return Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const LoginHeader(),
            const SizedBox(height: 28),
            LoginTextField(
              label: 'البريد الإلكتروني للعمل',
              hint: 'name@haseen.ps',
              icon: Icons.mail_outline,
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              autofillHints: const [AutofillHints.email],
              validator: LoginValidator.email,
            ),
            const SizedBox(height: 18),
            LoginPasswordField(
              controller: _password,
              obscured: state.obscurePassword,
              onToggleVisibility: cubit.togglePasswordVisibility,
              onSubmitted: _submit,
            ),
            const SizedBox(height: 12),
            LoginOptionsRow(
              rememberMe: state.rememberMe,
              onRememberMeChanged: cubit.setRememberMe,
              onForgotPassword: _showForgotPassword,
            ),
            const SizedBox(height: 22),
            LoginSubmitButton(
              isLoading: state.isSubmitting,
              onPressed: _submit,
            ),
            const SizedBox(height: 28),
            const Divider(color: HaseenColors.line, height: 1),
            const SizedBox(height: 16),
            const Text(
              'الحسابات تُنشأ من قِبل مدير النظام فقط. لا يوجد تسجيل ذاتي.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: HaseenColors.muted),
            ),
          ],
        ),
      );
    },
  );
}
