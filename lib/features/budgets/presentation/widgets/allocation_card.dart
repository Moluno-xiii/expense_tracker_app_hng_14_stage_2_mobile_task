import 'package:flutter/material.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';

class AllocationCard extends StatelessWidget {
  const AllocationCard({
    required this.category,
    this.onTap,
    this.width,
    super.key,
  });

  final MockCategory category;
  final VoidCallback? onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final c = category;
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
          padding: const EdgeInsets.all(14),
          child: SizedBox(
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _IconBubble(icon: c.icon),
                const SizedBox(height: 12),
                Text(
                  c.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: tokens.headingText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  formatMoney(c.spent),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: tokens.brandDeep,
                  ),
                ),
                const SizedBox(height: 10),
                _Progress(category: c),
                const SizedBox(height: 8),
                Text(
                  '${formatMoney(c.left.abs())} ${c.overLimit ? 'OVER' : 'LEFT'}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: c.overLimit
                        ? tokens.expenseRed
                        : tokens.incomeGreen,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: tokens.softLilacAlt,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: tokens.brandDeep),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.category});

  final MockCategory category;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final over = category.overLimit;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: over ? 1.0 : category.progress,
        minHeight: 4,
        color: over ? tokens.expenseRed : Theme.of(context).colorScheme.primary,
        backgroundColor: tokens.bentoBorder,
      ),
    );
  }
}

class AllocationListTile extends StatelessWidget {
  const AllocationListTile({
    required this.category,
    this.onTap,
    super.key,
  });

  final MockCategory category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final c = category;
    final over = c.overLimit;
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
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: tokens.softLilacAlt,
                  shape: BoxShape.circle,
                ),
                child: Icon(c.icon, size: 16, color: tokens.brandDeep),
              ),
              const SizedBox(height: 12),
              Text(
                c.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: tokens.headingText,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: over ? 1.0 : c.progress,
                  minHeight: 4,
                  color: over
                      ? tokens.expenseRed
                      : Theme.of(context).colorScheme.primary,
                  backgroundColor: tokens.bentoBorder,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatMoney(c.spent),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: tokens.brandDeep,
                    ),
                  ),
                  Text(
                    '${formatMoney(c.left.abs())} ${over ? 'OVER' : 'LEFT'}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color:
                          over ? tokens.expenseRed : tokens.incomeGreen,
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
