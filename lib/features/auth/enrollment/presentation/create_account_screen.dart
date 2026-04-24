import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/auth_controller.dart';
import 'widgets/enrollment_scaffold.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _obscurePassword = ValueNotifier<bool>(true);
  final _obscureConfirm = ValueNotifier<bool>(true);
  final _localError = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _obscurePassword.dispose();
    _obscureConfirm.dispose();
    _localError.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = AuthScope.of(context);
    auth.clearError();
    if (_password.text != _confirm.text) {
      _localError.value = "Passwords don't match.";
      return;
    }
    _localError.value = null;
    final ok = await auth.signUp(
      fullName: _name.text,
      email: _email.text,
      password: _password.text,
    );
    if (ok && mounted) context.go(Routes.enrollVerifyEmail);
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    return EnrollmentScaffold(
      centerBrand: false,
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
                _Field(
                  label: 'Full Name',
                  hint: 'John Doe',
                  icon: Icons.person_outline,
                  controller: _name,
                ),
                const SizedBox(height: 24),
                _Field(
                  label: 'Email Address',
                  hint: 'john@company.com',
                  icon: Icons.mail_outline,
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                _PasswordField(
                  label: 'Password',
                  controller: _password,
                  obscure: _obscurePassword,
                ),
                const SizedBox(height: 24),
                _PasswordField(
                  label: 'Confirm Password',
                  controller: _confirm,
                  obscure: _obscureConfirm,
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<String?>(
                  valueListenable: _localError,
                  builder: (_, local, _) {
                    final msg = local ?? auth.error;
                    if (msg == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ErrorBanner(message: msg),
                    );
                  },
                ),
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
                            Text('Sign Up'),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                ),
                const SizedBox(height: 20),
                const _LoginLink(),
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
          'Create an Account',
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
          'Secure your financial data today.',
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

class _Field extends StatelessWidget {
  const _Field({
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
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscure,
  });

  final String label;
  final TextEditingController controller;
  final ValueNotifier<bool> obscure;

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
        ValueListenableBuilder<bool>(
          valueListenable: obscure,
          builder: (_, hidden, _) {
            return TextField(
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
            );
          },
        ),
      ],
    );
  }
}

class _LoginLink extends StatelessWidget {
  const _LoginLink();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final primary = Theme.of(context).colorScheme.primary;
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Already have an account? ',
            style: TextStyle(fontSize: 14, color: tokens.bodyText),
          ),
          GestureDetector(
            onTap: () => context.go(Routes.login),
            child: Text(
              'Log In',
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
