import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import 'widgets/enrollment_scaffold.dart';

class VerificationSuccessfulScreen extends StatelessWidget {
  const VerificationSuccessfulScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EnrollmentScaffold(
      centerBrand: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            children: [
              const SizedBox(height: 32),
              const _SuccessCard(),
              const SizedBox(height: 20),
              const _SecurityFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessCard extends StatelessWidget {
  const _SuccessCard();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final primary = Theme.of(context).colorScheme.primary;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: tokens.cardSurface,
          boxShadow: [
            BoxShadow(
              color: tokens.brandDeep.withValues(alpha: 0.06),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primary.withValues(alpha: 0.6),
                    primary,
                    primary.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: Column(
                children: [
                  const _CheckBadge(),
                  const SizedBox(height: 24),
                  Text(
                    'Verification\nSuccessful',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: tokens.headingText,
                      height: 1.15,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Connecting to your account securely...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: tokens.bodyText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Progress(color: primary, track: tokens.softLilacAlt),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: () => context.go(Routes.overview),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Go to Dashboard'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckBadge extends StatelessWidget {
  const _CheckBadge();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      width: 116,
      height: 116,
      decoration: BoxDecoration(
        color: tokens.softLilacAlt,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: tokens.headingText,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            size: 36,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.color, required this.track});

  final Color color;
  final Color track;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          minHeight: 6,
          value: 0.5,
          color: color,
          backgroundColor: track,
        ),
      ),
    );
  }
}

class _SecurityFooter extends StatelessWidget {
  const _SecurityFooter();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline, size: 14, color: tokens.bodyText),
        const SizedBox(width: 6),
        Text(
          'Secured by Enterprise Grade Encryption',
          style: TextStyle(fontSize: 12, color: tokens.bodyText),
        ),
      ],
    );
  }
}
