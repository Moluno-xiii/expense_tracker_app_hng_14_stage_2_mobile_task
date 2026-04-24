import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_brand_bar.dart';
import 'widgets/allocation_donut_card.dart';
import 'widgets/smart_allocation_card.dart';
import 'widgets/smart_suggestion_card.dart';
import 'widgets/spending_velocity_card.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final _range = ValueNotifier<String>('Monthly');

  @override
  void dispose() {
    _range.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      body: Column(
        children: [
          const AppBrandBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                _TitleBlock(),
                const SizedBox(height: 16),
                _RangeToggle(selected: _range),
                const SizedBox(height: 16),
                const SpendingVelocityCard(),
                const SizedBox(height: 24),
                _MonthlyOverview(tokens: tokens),
                const SizedBox(height: 16),
                const _TotalSpentCard(),
                const SizedBox(height: 16),
                const AllocationDonutCard(),
                const SizedBox(height: 24),
                _SectionHeader(title: 'Smart Suggestions'),
                const SizedBox(height: 12),
                const SmartSuggestionCard(
                  icon: Icons.auto_awesome,
                  title: 'Optimize Subscriptions',
                  body: 'You have 3 overlapping streaming services. '
                      'Consolidating could save you \$34.99/mo.',
                  actionLabel: 'Take Action',
                  tone: SuggestionTone.highImpact,
                ),
                const SizedBox(height: 12),
                const SmartSuggestionCard(
                  icon: Icons.account_balance_outlined,
                  title: 'Investment Rebalance',
                  body: "Your 'Lifestyle' allocation is exceeding targets. "
                      'Shift \$200 to your index fund.',
                  actionLabel: 'Review Portfolio',
                  tone: SuggestionTone.strategy,
                ),
                const SizedBox(height: 24),
                const SmartAllocationCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PERFORMANCE ANALYTICS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: tokens.bodyText,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Financial Insights',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: tokens.brandDeep,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _RangeToggle extends StatelessWidget {
  const _RangeToggle({required this.selected});

  final ValueNotifier<String> selected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: tokens.softLilacAlt.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ValueListenableBuilder<String>(
        valueListenable: selected,
        builder: (_, sel, _) => Row(
          children: [
            for (final k in const ['Daily', 'Weekly', 'Monthly'])
              Expanded(
                child: _Seg(
                  label: k,
                  active: sel == k,
                  onTap: () => selected.value = k,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  const _Seg({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      color: active ? primary : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : tokens.bodyText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthlyOverview extends StatelessWidget {
  const _MonthlyOverview({required this.tokens});

  final MyColors tokens;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MONTHLY OVERVIEW',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: tokens.bodyText,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'September Budgets',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: tokens.headingText,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 14,
              color: tokens.bodyText,
              height: 1.5,
            ),
            children: const [
              TextSpan(text: "You've utilized "),
              TextSpan(
                text: '64%',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              TextSpan(
                text: ' of your total monthly allowance. Your trajectory '
                    "suggests you'll remain within limits by month-end.",
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TotalSpentCard extends StatelessWidget {
  const _TotalSpentCard();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tokens.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.bentoBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Spent',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: tokens.bodyText,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '\$4,280.00',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: tokens.brandDeep,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: 4280 / 6700,
              minHeight: 6,
              color: primary,
              backgroundColor: tokens.bentoBorder,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'of \$6,700.00 total budget',
            style: TextStyle(fontSize: 12, color: tokens.bodyText),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: tokens.headingText,
          ),
        ),
        Text(
          'View All',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
