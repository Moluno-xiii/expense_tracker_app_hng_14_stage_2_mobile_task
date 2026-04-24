import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/auth_controller.dart';
import 'widgets/enrollment_scaffold.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _poll;
  Timer? _cooldownTicker;
  final _cooldown = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startPolling());
  }

  @override
  void dispose() {
    _poll?.cancel();
    _cooldownTicker?.cancel();
    _cooldown.dispose();
    super.dispose();
  }

  void _startPolling() {
    final auth = AuthScope.of(context);
    _poll = Timer.periodic(const Duration(seconds: 4), (_) async {
      final verified = await auth.refreshUser();
      if (verified && mounted) {
        _poll?.cancel();
        context.go(Routes.enrollLiveness);
      }
    });
  }

  Future<void> _resend() async {
    final auth = AuthScope.of(context);
    final ok = await auth.resendVerificationEmail();
    if (!mounted) return;
    if (ok) {
      _beginCooldown();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email sent')),
      );
    }
  }

  void _beginCooldown() {
    _cooldown.value = 30;
    _cooldownTicker?.cancel();
    _cooldownTicker =
        Timer.periodic(const Duration(seconds: 1), (t) {
      if (_cooldown.value <= 1) {
        t.cancel();
        _cooldown.value = 0;
      } else {
        _cooldown.value -= 1;
      }
    });
  }

  Future<void> _checkNow() async {
    final auth = AuthScope.of(context);
    final verified = await auth.refreshUser();
    if (!mounted) return;
    if (verified) {
      context.go(Routes.enrollLiveness);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email isn't verified yet.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final email = auth.user?.email ?? 'your email';
    return EnrollmentScaffold(
      centerBrand: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: _Card(
            email: email,
            cooldown: _cooldown,
            busy: auth.busy,
            onResend: _resend,
            onCheckNow: _checkNow,
            onBackToSignup: () {
              auth.signOut();
              context.go(Routes.enroll);
            },
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.email,
    required this.cooldown,
    required this.busy,
    required this.onResend,
    required this.onCheckNow,
    required this.onBackToSignup,
  });

  final String email;
  final ValueNotifier<int> cooldown;
  final bool busy;
  final VoidCallback onResend;
  final VoidCallback onCheckNow;
  final VoidCallback onBackToSignup;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: tokens.cardSurface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: tokens.brandDeep.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          const _IconBadge(),
          const SizedBox(height: 24),
          Text(
            'Check your email',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: tokens.headingText,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 15,
                color: tokens.bodyText,
                height: 1.5,
              ),
              children: [
                const TextSpan(
                  text: "We've sent a verification link to ",
                ),
                TextSpan(
                  text: email,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: tokens.headingText,
                  ),
                ),
                const TextSpan(
                  text: '. Tap the link to confirm '
                      'your address.',
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _PollingStatus(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: busy ? null : onCheckNow,
              child: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("I've verified — continue"),
            ),
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<int>(
            valueListenable: cooldown,
            builder: (_, seconds, _) {
              final canResend = seconds == 0;
              return TextButton(
                onPressed: canResend ? onResend : null,
                child: Text(
                  canResend
                      ? 'Resend email'
                      : 'Resend email in ${seconds}s',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: canResend ? primary : tokens.bodyText,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: onBackToSignup,
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Use a different email'),
          ),
        ],
      ),
    );
  }
}

class _PollingStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Waiting for you to verify…',
          style: TextStyle(fontSize: 13, color: tokens.bodyText),
        ),
      ],
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: tokens.softLilacAlt,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.mark_email_read_outlined,
        size: 32,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
