import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';

class _Rule {
  const _Rule({
    required this.title,
    required this.icon,
    required this.amount,
    required this.isIncome,
    required this.frequency,
    required this.nextRun,
  });

  final String title;
  final IconData icon;
  final double amount;
  final bool isIncome;
  final String frequency;
  final String nextRun;
}

class RecurringListScreen extends StatelessWidget {
  const RecurringListScreen({super.key});

  static const _rules = <_Rule>[
    _Rule(
      title: 'Salary',
      icon: Icons.work_outline,
      amount: 3500,
      isIncome: true,
      frequency: 'MONTHLY',
      nextRun: 'May 1',
    ),
    _Rule(
      title: 'Rent',
      icon: Icons.home_outlined,
      amount: 1200,
      isIncome: false,
      frequency: 'MONTHLY',
      nextRun: 'May 1',
    ),
    _Rule(
      title: 'Netflix',
      icon: Icons.tv_outlined,
      amount: 15.99,
      isIncome: false,
      frequency: 'WEEKLY',
      nextRun: 'Apr 25',
    ),
    _Rule(
      title: 'Gym',
      icon: Icons.fitness_center_outlined,
      amount: 45.00,
      isIncome: false,
      frequency: 'MONTHLY',
      nextRun: 'May 6',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _BackPill(onTap: () => Navigator.of(context).pop()),
        leadingWidth: 64,
        title: const Text('Recurring'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          for (final r in _rules) ...[
            _RuleTile(rule: r),
            const SizedBox(height: 10),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => context.push(Routes.settingsRecurringNew),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New Rule'),
            ),
          ),
        ),
      ),
    );
  }
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

class _RuleTile extends StatelessWidget {
  const _RuleTile({required this.rule});

  final _Rule rule;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = rule.isIncome ? tokens.incomeGreen : tokens.expenseRed;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.bentoBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: tokens.softLilacAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  rule.icon,
                  size: 18,
                  color: tokens.brandDeep,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  rule.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: tokens.headingText,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: tokens.softLilacAlt,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  rule.frequency,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: tokens.brandDeep,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${rule.isIncome ? '+' : '-'}\$${rule.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                'Next: ${rule.nextRun}',
                style: TextStyle(fontSize: 12, color: tokens.bodyText),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
