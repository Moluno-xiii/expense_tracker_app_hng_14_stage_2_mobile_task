import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_data.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/allocation_model.dart';
import '../../../data/models/budget_category_model.dart';
import '../../../data/models/category_model.dart';
import '../../auth/data/auth_controller.dart';

class AllocationsScreen extends StatefulWidget {
  const AllocationsScreen({super.key});

  @override
  State<AllocationsScreen> createState() => _AllocationsScreenState();
}

class _AllocationsScreenState extends State<AllocationsScreen> {
  final _selected = ValueNotifier<String>('All');
  Stream<List<AllocationModel>>? _stream;
  String? _uid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uid = AuthScope.of(context).user?.uid;
    if (uid != null && uid != _uid) {
      _uid = uid;
      _stream = AppDataScope.of(context).allocations.watchForUser(uid);
    }
  }

  @override
  void dispose() {
    _selected.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _BackPill(onTap: () => Navigator.of(context).pop()),
        leadingWidth: 64,
        title: const Text('Allocation'),
      ),
      body: StreamBuilder<List<AllocationModel>>(
        stream: _stream,
        builder: (ctx, snap) {
          final uid = _uid;
          if (uid == null) return const SizedBox.shrink();
          final appData = AppDataScope.of(ctx);
          final cats = {
            for (final c in appData.categories.forUser(uid)) c.id: c,
          };
          final bcs = {
            for (final b in appData.budgetCategories.forUser(uid))
              b.id: b,
          };
          final all = (snap.data ?? const <AllocationModel>[])
              .where((a) => !a.isBuiltIn)
              .toList();
          if (all.isEmpty) {
            return _EmptyState(
              onAdd: () => context.push(Routes.allocationsNew),
            );
          }
          final bcNames = <String>{
            for (final a in all)
              if (bcs[a.budgetCategoryId] != null)
                bcs[a.budgetCategoryId]!.name,
          }.toList()
            ..sort();
          final chips = <String>['All', ...bcNames];
          return ValueListenableBuilder<String>(
            valueListenable: _selected,
            builder: (_, sel, _) {
              final filtered = sel == 'All'
                  ? all
                  : all
                      .where(
                        (a) => bcs[a.budgetCategoryId]?.name == sel,
                      )
                      .toList();
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _FilterChipsRow(selected: _selected, chips: chips),
                  const SizedBox(height: 16),
                  for (final a in filtered) ...[
                    _AllocationCard(
                      allocation: a,
                      budgetCategory: bcs[a.budgetCategoryId],
                      parentCategory: () {
                        final bc = bcs[a.budgetCategoryId];
                        return bc == null ? null : cats[bc.categoryId];
                      }(),
                      onTap: () => context.push('/allocations/${a.id}'),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 8),
                  _QuickAddCard(
                    onTap: () => context.push(Routes.allocationsNew),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: tokens.softLilacAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_tree_outlined,
                size: 32,
                color: tokens.brandDeep,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No allocations yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: tokens.headingText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create allocations under categories that have a budget. '
              'Transactions slot into the allocation you pick.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: tokens.bodyText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Allocation'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllocationCard extends StatelessWidget {
  const _AllocationCard({
    required this.allocation,
    required this.budgetCategory,
    required this.parentCategory,
    this.onTap,
  });

  final AllocationModel allocation;
  final BudgetCategoryModel? budgetCategory;
  final CategoryModel? parentCategory;
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
          padding: const EdgeInsets.all(16),
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
                      parentCategory?.icon ?? Icons.category_outlined,
                      size: 18,
                      color: tokens.brandDeep,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          allocation.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: tokens.headingText,
                          ),
                        ),
                        if (budgetCategory != null)
                          Text(
                            '${budgetCategory!.name.toUpperCase()}'
                            '${parentCategory == null ? '' : ' • '
                                '${parentCategory!.name.toUpperCase()}'}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: tokens.bodyText,
                              letterSpacing: 0.6,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (allocation.amount != null)
                    Text(
                      '\$${allocation.amount!.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: tokens.brandDeep,
                      ),
                    ),
                ],
              ),
              if (allocation.notes != null &&
                  allocation.notes!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  allocation.notes!,
                  style: TextStyle(
                    fontSize: 12,
                    color: tokens.bodyText,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChipsRow extends StatelessWidget {
  const _FilterChipsRow({required this.selected, required this.chips});

  final ValueNotifier<String> selected;
  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ValueListenableBuilder<String>(
        valueListenable: selected,
        builder: (_, sel, _) => ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: chips.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final label = chips[i];
            return _FilterChip(
              label: label,
              active: label == sel,
              onTap: () => selected.value = label,
            );
          },
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
    final bg = active ? tokens.softLilacAlt : Colors.transparent;
    final fg = active ? tokens.brandDeep : tokens.bodyText;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: active ? FontWeight.w800 : FontWeight.w500,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAddCard extends StatelessWidget {
  const _QuickAddCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final navy = tokens.brandDeep;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tokens.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.inputBorder, width: 1.2),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tokens.softLilacAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.add_card_outlined,
              size: 22,
              color: tokens.brandDeep,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'New Allocation',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: tokens.headingText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Record a new allocation',
            style: TextStyle(fontSize: 12, color: tokens.bodyText),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onTap,
              child: const Text(
                'Quick Add',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
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
