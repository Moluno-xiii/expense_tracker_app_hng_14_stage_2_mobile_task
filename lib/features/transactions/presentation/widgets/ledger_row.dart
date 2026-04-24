import 'package:flutter/material.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/ledger_entry.dart';

class LedgerRow extends StatelessWidget {
  const LedgerRow({required this.entry, this.onTap, super.key});

  final LedgerEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color =
        entry.isIncome ? tokens.incomeGreen : tokens.expenseRed;
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
              _IconChip(icon: entry.icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: tokens.headingText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${entry.categoryName.toUpperCase()}  •  '
                      '${_formatTime(entry.createdAt)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: tokens.bodyText,
                        letterSpacing: 0.4,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatMoney(
                      entry.amount,
                      withSign: true,
                      income: entry.isIncome,
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(entry.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: tokens.bodyText,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
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

const _months = <String>[
  'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
  'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
];

String _formatDate(int millis) {
  final d = DateTime.fromMillisecondsSinceEpoch(millis);
  return '${_months[d.month - 1]} ${d.day}';
}

String _formatTime(int millis) {
  final d = DateTime.fromMillisecondsSinceEpoch(millis);
  final h24 = d.hour;
  final h = h24 % 12 == 0 ? 12 : h24 % 12;
  final mm = d.minute.toString().padLeft(2, '0');
  final ampm = h24 >= 12 ? 'PM' : 'AM';
  return '$h:$mm $ampm';
}
