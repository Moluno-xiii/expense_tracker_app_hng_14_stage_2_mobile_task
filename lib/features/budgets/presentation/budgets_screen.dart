import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_data.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_brand_bar.dart';
import '../../../core/widgets/numeric_keypad_sheet.dart';
import '../../../data/models/budget_category_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/ledger_entry.dart';
import '../../analytics/presentation/widgets/spending_velocity_card.dart';
import '../../auth/data/auth_controller.dart';
import 'new_allocation_screen.dart' show showNewCategorySheet;
import 'widgets/add_budget_sheet.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  Stream<List<CategoryModel>>? _catStream;
  Stream<List<BudgetCategoryModel>>? _bcStream;
  Stream<List<LedgerEntry>>? _ledgerStream;
  String? _uid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uid = AuthScope.of(context).user?.uid;
    if (uid != null && uid != _uid) {
      _uid = uid;
      final appData = AppDataScope.of(context);
      _catStream = appData.categories.watchForUser(uid);
      _bcStream = appData.budgetCategories.watchForUser(uid);
      _ledgerStream = appData.watchLedger(uid);
    }
  }

  Future<void> _onAddCategory() async {
    final uid = _uid;
    if (uid == null) return;
    await showNewCategorySheet(context, uid: uid);
  }

  _MonthlyBurnMetrics _computeMonthlyBurn(
    BuildContext ctx,
    String uid,
    List<BudgetCategoryModel> budgetCategories,
  ) {
    final appData = AppDataScope.of(ctx);
    final now = DateTime.now();
    final monthStart =
        DateTime(now.year, now.month).millisecondsSinceEpoch;
    double balance = 0;
    double spent = 0;
    for (final t in appData.transactions.forUser(uid)) {
      if (t.isIncome) {
        balance += t.amount;
      } else {
        balance -= t.amount;
        if (t.date >= monthStart) spent += t.amount;
      }
    }
    double limit = 0;
    for (final b in budgetCategories) {
      limit += b.amount;
    }
    return _MonthlyBurnMetrics(
      balance: balance,
      limit: limit,
      spent: spent,
    );
  }

  Future<void> _onAddBudgetCategory(List<CategoryModel> categories) async {
    final uid = _uid;
    if (uid == null) return;
    final available = categories
        .where((c) => !c.isBuiltIn)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Create a category first, then come back and add a budget '
            'category under it.',
          ),
        ),
      );
      return;
    }
    await showAddBudgetSheet(context, uid: uid, categories: available);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppBrandBar(),
          Expanded(
            child: StreamBuilder<List<CategoryModel>>(
              stream: _catStream,
              builder: (_, catSnap) {
                final categories = (catSnap.data ?? const <CategoryModel>[])
                    .where((c) => !c.isBuiltIn)
                    .toList()
                  ..sort((a, b) => a.name.compareTo(b.name));
                return StreamBuilder<List<BudgetCategoryModel>>(
                  stream: _bcStream,
                  builder: (_, bcSnap) {
                    final bcs =
                        (bcSnap.data ?? const <BudgetCategoryModel>[])
                            .where((b) => !b.isBuiltIn)
                            .toList()
                          ..sort(
                            (a, b) => a.name.compareTo(b.name),
                          );
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      children: [
                        StreamBuilder<List<LedgerEntry>>(
                          stream: _ledgerStream,
                          builder: (ctx, _) {
                            final uid = _uid;
                            if (uid == null) {
                              return const SizedBox.shrink();
                            }
                            return _MonthlyBurnCard(
                              metrics: _computeMonthlyBurn(ctx, uid, bcs),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        const SpendingVelocityCard(),
                        const SizedBox(height: 24),
                        _CategoriesCard(
                          categories: categories,
                          onAddNew: _onAddCategory,
                        ),
                        const SizedBox(height: 24),
                        _SectionHeaderRow(
                          title: 'Budget Categories',
                          hasBudgets: bcs.isNotEmpty,
                        ),
                        const SizedBox(height: 12),
                        _AddBudgetCategoryButton(
                          onTap: () => _onAddBudgetCategory(categories),
                        ),
                        const SizedBox(height: 16),
                        if (bcs.isEmpty)
                          const _NoBudgetCategories()
                        else
                          for (final b in bcs) ...[
                            _BudgetCategoryRow(budgetCategory: b),
                            const SizedBox(height: 12),
                          ],
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesCard extends StatelessWidget {
  const _CategoriesCard({
    required this.categories,
    required this.onAddNew,
  });

  final List<CategoryModel> categories;
  final VoidCallback onAddNew;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.bentoBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CATEGORIES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: tokens.bodyText,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                if (i == categories.length) {
                  return _NewCategoryTile(onTap: onAddNew);
                }
                return _CategoryTile(category: categories[i]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      width: 92,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: tokens.bentoBorder.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(category.icon, size: 26, color: tokens.brandDeep),
          const SizedBox(height: 8),
          Text(
            category.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: tokens.headingText,
            ),
          ),
        ],
      ),
    );
  }
}

class _NewCategoryTile extends StatelessWidget {
  const _NewCategoryTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Material(
      color: tokens.softLilacAlt,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 92,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 26, color: tokens.brandDeep),
              const SizedBox(height: 8),
              Text(
                'New',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
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

class _AddBudgetCategoryButton extends StatelessWidget {
  const _AddBudgetCategoryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final navy = context.tokens.brandDeep;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [navy, const Color(0xFF0051D5)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Container(
            alignment: Alignment.center,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Add New Budget Category',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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

class _NoBudgetCategories extends StatelessWidget {
  const _NoBudgetCategories();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tokens.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.bentoBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.pie_chart_outline, color: tokens.bodyText),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No budget categories yet. Tap "Add New Budget Category" '
              'above to create one.',
              style: TextStyle(
                fontSize: 13,
                color: tokens.bodyText,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyBurnMetrics {
  const _MonthlyBurnMetrics({
    required this.balance,
    required this.limit,
    required this.spent,
  });

  final double balance;
  final double limit;
  final double spent;

  bool get hasLimit => limit > 0;
  double get percent =>
      hasLimit ? (spent / limit).clamp(0.0, 1.0) : 0.0;
  double get left => limit - spent;
  bool get over => hasLimit && spent > limit;
}

class _MonthlyBurnCard extends StatelessWidget {
  const _MonthlyBurnCard({required this.metrics});

  final _MonthlyBurnMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final navy = context.tokens.brandDeep;
    final m = metrics;
    final pctLabel = m.hasLimit ? '${(m.percent * 100).round()}%' : '—';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [navy, const Color(0xFF0051D5)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MONTHLY BURN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 1.2,
                ),
              ),
              _StatusChip(metrics: m),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '\$${m.balance.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: m.over ? 1.0 : m.percent,
              minHeight: 6,
              color: Colors.white,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  m.hasLimit
                      ? '$pctLabel of \$${m.limit.toStringAsFixed(2)} limit'
                      : 'No budget limit set',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
              if (m.hasLimit)
                Text(
                  m.over
                      ? '\$${(-m.left).toStringAsFixed(2)} over'
                      : '\$${m.left.toStringAsFixed(2)} left',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.metrics});

  final _MonthlyBurnMetrics metrics;

  @override
  Widget build(BuildContext context) {
    if (!metrics.hasLimit) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Text(
          'NO LIMIT',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.6,
          ),
        ),
      );
    }
    final over = metrics.over;
    final warn = !over && metrics.percent >= 0.9;
    final (bg, fg, label) = over
        ? (
            const Color(0xFFEF4444).withValues(alpha: 0.25),
            const Color(0xFFFCA5A5),
            'OVER BUDGET',
          )
        : warn
            ? (
                const Color(0xFFF59E0B).withValues(alpha: 0.25),
                const Color(0xFFFCD34D),
                'NEAR LIMIT',
              )
            : (
                const Color(0xFF10B981).withValues(alpha: 0.25),
                const Color(0xFF34D399),
                'ON TRACK',
              );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: fg,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _SectionHeaderRow extends StatelessWidget {
  const _SectionHeaderRow({
    required this.title,
    required this.hasBudgets,
  });

  final String title;
  final bool hasBudgets;

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
        if (hasBudgets)
          GestureDetector(
            onTap: () => context.push(Routes.budgetsList),
            child: Text(
              'View All',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}

class _BudgetCategoryRow extends StatefulWidget {
  const _BudgetCategoryRow({required this.budgetCategory});

  final BudgetCategoryModel budgetCategory;

  @override
  State<_BudgetCategoryRow> createState() => _BudgetCategoryRowState();
}

class _BudgetCategoryRowState extends State<_BudgetCategoryRow> {
  Future<void> _editAmount() async {
    final b = widget.budgetCategory;
    final result = await showAmountKeypad(
      context,
      initial: b.amount,
      primaryLabel: 'Update Budget',
    );
    if (result == null || result.amount <= 0 || !mounted) return;
    await AppDataScope.of(context)
        .budgetCategories
        .update(b.copyWith(amount: result.amount));
  }

  Future<void> _remove() async {
    final appData = AppDataScope.of(context);
    final b = widget.budgetCategory;
    final allocCount = appData.allocations
        .forUser(b.userId)
        .where((a) => a.budgetCategoryId == b.id)
        .length;
    final txCount = appData.allocations
        .forUser(b.userId)
        .where((a) => a.budgetCategoryId == b.id)
        .fold<int>(
          0,
          (sum, a) =>
              sum +
              appData.transactions
                  .forAllocation(uid: b.userId, allocationId: a.id)
                  .length,
        );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove "${b.name}"?'),
        content: Text(
          allocCount == 0
              ? 'This will delete the budget category "${b.name}".'
              : 'This will delete "${b.name}", $allocCount '
                  '${allocCount == 1 ? 'allocation' : 'allocations'} under '
                  'it, and $txCount '
                  '${txCount == 1 ? 'transaction' : 'transactions'}. Money '
                  'from deleted transactions will be returned to your '
                  'balance. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: context.tokens.expenseRed,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await appData.removeBudgetCategoryCascading(b);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final b = widget.budgetCategory;
    final category =
        AppDataScope.of(context).categories.byId(b.categoryId);
    return Material(
      color: tokens.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: tokens.bentoBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _editAmount,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tokens.softLilacAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  category?.icon ?? Icons.category_outlined,
                  size: 20,
                  color: tokens.brandDeep,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: tokens.headingText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${category?.name ?? 'Uncategorized'}  •  '
                      '\$${b.amount.toStringAsFixed(0)} / month',
                      style: TextStyle(
                        fontSize: 12,
                        color: tokens.bodyText,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _remove,
                icon: Icon(
                  Icons.delete_outline,
                  color: tokens.expenseRed,
                  size: 20,
                ),
                tooltip: 'Remove budget category',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
