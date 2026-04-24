import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/data/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final auth = AuthScope.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: _BackPill(onTap: () => Navigator.of(context).pop()),
        leadingWidth: 64,
        title: const Text('Profile'),
      ),
      body: ListenableBuilder(
        listenable: auth,
        builder: (_, _) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _IdentityCard(
            name: auth.user?.displayName ?? '',
            email: auth.user?.email ?? '',
            verified: auth.emailVerified,
          ),
          const SizedBox(height: 16),
          _InfoCard(
            tokens: tokens,
            memberSince: _formatCreated(auth.user?.metadata.creationTime),
          ),
          const SizedBox(height: 20),
          Text(
            'DANGER ZONE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: tokens.bodyText,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          _DangerCard(tokens: tokens),
        ],
      ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit'),
            ),
          ),
        ),
      ),
    );
  }
}

String _formatCreated(DateTime? dt) {
  if (dt == null) return '—';
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  return '${months[dt.month - 1]} ${dt.year}';
}

class _BackPill extends StatelessWidget {
  const _BackPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Material(
        color: tokens.cardSurface,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: tokens.bentoBorder),
            ),
            child: Icon(Icons.arrow_back, size: 18, color: tokens.brandDeep),
          ),
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.name,
    required this.email,
    required this.verified,
  });

  final String name;
  final String email;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final displayName = name.trim().isEmpty ? email : name;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tokens.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.bentoBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: tokens.softLilacAlt,
              shape: BoxShape.circle,
              border: Border.all(color: tokens.bentoBorder),
            ),
            child: Icon(Icons.person, size: 48, color: tokens.brandDeep),
          ),
          const SizedBox(height: 12),
          Text(
            displayName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: tokens.headingText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(fontSize: 13, color: tokens.bodyText),
          ),
          const SizedBox(height: 10),
          _StatusChip(verified: verified),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.verified});

  final bool verified;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = verified ? tokens.incomeGreen : tokens.warningAmber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verified ? Icons.verified_outlined : Icons.schedule,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            verified ? 'VERIFIED' : 'PENDING VERIFICATION',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.tokens, required this.memberSince});

  final MyColors tokens;
  final String memberSince;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.bentoBorder),
      ),
      child: Column(
        children: [
          _Row(label: 'Member since', value: memberSince, tokens: tokens),
          Divider(color: tokens.dividerSoft, height: 20),
          _Row(label: 'Timezone', value: 'UTC+01:00', tokens: tokens),
          Divider(color: tokens.dividerSoft, height: 20),
          _Row(label: 'Currency', value: 'USD (\$)', tokens: tokens),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    required this.tokens,
  });

  final String label;
  final String value;
  final MyColors tokens;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: tokens.bodyText),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: tokens.headingText,
          ),
        ),
      ],
    );
  }
}

class _DangerCard extends StatelessWidget {
  const _DangerCard({required this.tokens});

  final MyColors tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.expenseRed.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.expenseRed.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reset all data',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: tokens.expenseRed,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Wipe all transactions, categories, budgets and recurring '
            'rules. Your profile will be cleared.',
            style: TextStyle(
              fontSize: 12,
              color: tokens.bodyText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: tokens.expenseRed,
                side: BorderSide(color: tokens.expenseRed),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Reset all data',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
