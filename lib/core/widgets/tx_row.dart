import 'package:flutter/material.dart';

import '../mock/mock_data.dart';
import '../theme/app_colors.dart';

class TxRow extends StatelessWidget {
  const TxRow({required this.tx, this.onTap, super.key});

  final MockTransaction tx;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Material(
      color: tokens.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: tokens.bentoBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _IconChip(icon: tx.icon),
              const SizedBox(width: 12),
              Expanded(child: _Middle(tx: tx)),
              _Right(tx: tx),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: tokens.cardSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tokens.bentoBorder),
      ),
      child: Icon(icon, size: 18, color: tokens.brandDeep),
    );
  }
}

class _Middle extends StatelessWidget {
  const _Middle({required this.tx});

  final MockTransaction tx;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tx.title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: tokens.headingText,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          '${tx.category}  •  ${tx.time}',
          style: TextStyle(
            fontSize: 11,
            color: tokens.bodyText,
            letterSpacing: 0.4,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _Right extends StatelessWidget {
  const _Right({required this.tx});

  final MockTransaction tx;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = tx.isIncome ? tokens.incomeGreen : tokens.expenseRed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          formatMoney(tx.amount, withSign: true, income: tx.isIncome),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          tx.dateLabel,
          style: TextStyle(
            fontSize: 10,
            color: tokens.bodyText,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
