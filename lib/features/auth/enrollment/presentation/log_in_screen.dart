import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/auth_controller.dart';
import 'widgets/enrollment_scaffold.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _obscure = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _obscure.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = AuthScope.of(context);
    auth.clearError();
    final ok = await auth.signIn(
      email: _email.text,
      password: _password.text,
    );
    if (!mounted || !ok) return;
    if (auth.emailVerified) {
      context.go(Routes.overview);
    } else {
      context.go(Routes.enrollVerifyEmail);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    return EnrollmentScaffold(
      centerBrand: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: ListenableBuilder(
            listenable: auth,
            builder: (_, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const _Heading(),
                const SizedBox(height: 32),
                _LabeledField(
                  label: 'Email Address',
                  hint: 'john@company.com',
                  icon: Icons.mail_outline,
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                _PasswordField(controller: _password, obscure: _obscure),
                const SizedBox(height: 16),
                if (auth.error != null) _ErrorBanner(message: auth.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: auth.busy ? null : _submit,
                  child: auth.busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Log In'),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                ),
                const SizedBox(height: 20),
                const _SignUpLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      children: [
        Text(
          'Welcome back',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: tokens.headingText,
            letterSpacing: -0.6,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Log in to continue.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: tokens.bodyText,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: tokens.headingText,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          autocorrect: false,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: tokens.inputBorder),
            prefixIcon: Icon(icon, size: 18, color: tokens.inputBorder),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 44, minHeight: 0),
          ),
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({required this.controller, required this.obscure});

  final TextEditingController controller;
  final ValueNotifier<bool> obscure;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: tokens.headingText,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<bool>(
          valueListenable: obscure,
          builder: (_, hidden, _) => TextField(
            controller: controller,
            obscureText: hidden,
            autocorrect: false,
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: TextStyle(color: tokens.inputBorder),
              prefixIcon: Icon(
                Icons.lock_outline,
                size: 18,
                color: tokens.inputBorder,
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 44, minHeight: 0),
              suffixIcon: IconButton(
                icon: Icon(
                  hidden ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                ),
                onPressed: () => obscure.value = !hidden,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SignUpLink extends StatelessWidget {
  const _SignUpLink();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final primary = Theme.of(context).colorScheme.primary;
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Don't have an account? ",
            style: TextStyle(fontSize: 14, color: tokens.bodyText),
          ),
          GestureDetector(
            onTap: () => context.go(Routes.enroll),
            child: Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final red = context.tokens.expenseRed;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 16, color: red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, color: red),
            ),
          ),
        ],
      ),
    );
  }
}
