import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CategoryFilterChips extends StatelessWidget {
  const CategoryFilterChips({
    required this.selected,
    required this.onSelect,
    required this.onNew,
    super.key,
  });

  final ValueNotifier<String?> selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onNew;

  static const _chips = <_ChipSpec>[
    _ChipSpec('Food', Icons.restaurant_outlined),
    _ChipSpec('Travel', Icons.directions_car_outlined),
    _ChipSpec('Salary', Icons.payments_outlined),
    _ChipSpec('Shop', Icons.shopping_bag_outlined),
    _ChipSpec('Home', Icons.home_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: ValueListenableBuilder<String?>(
        valueListenable: selected,
        builder: (_, sel, _) => ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _chips.length + 1,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            if (i < _chips.length) {
              final c = _chips[i];
              return _Chip(
                spec: c,
                active: sel == c.label,
                onTap: () => onSelect(c.label),
              );
            }
            return _NewChip(onTap: onNew);
          },
        ),
      ),
    );
  }
}

class _ChipSpec {
  const _ChipSpec(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.spec,
    required this.active,
    required this.onTap,
  });

  final _ChipSpec spec;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final primary = Theme.of(context).colorScheme.primary;
    final bg = active ? tokens.softLilacAlt : tokens.cardSurface;
    final border = active ? primary : tokens.bentoBorder;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 76,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(spec.icon, size: 22, color: tokens.brandDeep),
              const SizedBox(height: 6),
              Text(
                spec.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: tokens.headingText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewChip extends StatelessWidget {
  const _NewChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      color: tokens.softLilacAlt,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 76,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primary.withValues(alpha: 0.4)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 22, color: primary),
              const SizedBox(height: 6),
              Text(
                'New',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
