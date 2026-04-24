import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/tx_row.dart';

class AllocationLedgerScreen extends StatelessWidget {
  const AllocationLedgerScreen({required this.categoryId, super.key});

  final String categoryId;

  MockCategory get _category => MockData.allocations.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => MockData.allocations.first,
      );

  List<MockTransaction> get _transactions =>
      MockData.recent.take(4).toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final c = _category;
    return Scaffold(
      appBar: AppBar(
        leading: const _BackPill(),
        leadingWidth: 64,
        title: Text(c.name),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _SummaryCard(category: c),
          const SizedBox(height: 24),
          _SectionHeading(title: 'This month'),
          const SizedBox(height: 12),
          for (final tx in _transactions) ...[
            TxRow(tx: tx),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _BackPill extends StatelessWidget {
  const _BackPill();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Material(
        color: tokens.cardSurface,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () => Navigator.of(context).pop(),
          customBorder: const CircleBorder(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: tokens.bentoBorder),
            ),
            child: Icon(
              Icons.arrow_back,
              size: 18,
              color: tokens.brandDeep,
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.category});

  final MockCategory category;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final over = category.overLimit;
    final pct = category.limit == 0
        ? 0
        : (category.spent / category.limit * 100).round();
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
            'MONTHLY BUDGET',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: tokens.bodyText,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatMoney(category.spent),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: tokens.brandDeep,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'of ${formatMoney(category.limit)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: tokens.bodyText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: over ? 1.0 : category.progress,
              minHeight: 8,
              color: over
                  ? tokens.expenseRed
                  : Theme.of(context).colorScheme.primary,
              backgroundColor: tokens.bentoBorder,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$pct% used',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: over ? tokens.expenseRed : tokens.incomeGreen,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit Budget'),
              style: OutlinedButton.styleFrom(
                foregroundColor: tokens.brandDeep,
                side: BorderSide(color: tokens.bentoBorder),
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: context.tokens.headingText,
      ),
    );
  }
}
