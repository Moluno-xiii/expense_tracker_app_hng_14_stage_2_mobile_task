import 'package:flutter/material.dart';

import '../../../app/app_data.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/numeric_keypad_sheet.dart';
import '../../../data/models/allocation_model.dart';
import '../../../data/models/budget_category_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../auth/data/auth_controller.dart';

class CategoryBudgetsScreen extends StatefulWidget {
  const CategoryBudgetsScreen({super.key});

  @override
  State<CategoryBudgetsScreen> createState() =>
      _CategoryBudgetsScreenState();
}

class _CategoryBudgetsScreenState extends State<CategoryBudgetsScreen> {
  Stream<List<BudgetCategoryModel>>? _stream;
  String? _uid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uid = AuthScope.of(context).user?.uid;
    if (uid != null && uid != _uid) {
      _uid = uid;
      _stream =
          AppDataScope.of(context).budgetCategories.watchForUser(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      appBar: AppBar(
        leading: _BackPill(onTap: () => Navigator.of(context).pop()),
        leadingWidth: 64,
        title: const Text('Budget Categories'),
      ),
      body: StreamBuilder<List<BudgetCategoryModel>>(
        stream: _stream,
        builder: (_, snap) {
          final uid = _uid;
          if (uid == null) return const SizedBox.shrink();
          final appData = AppDataScope.of(context);
          final bcs = (snap.data ?? const <BudgetCategoryModel>[])
              .where((b) => !b.isBuiltIn)
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));
          if (bcs.isEmpty) {
            return _EmptyState(tokens: tokens);
          }
          final allocs = appData.allocations.forUser(uid);
          final txs = appData.transactions.forUser(uid);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              for (final b in bcs) ...[
                _BudgetCategoryCard(
                  budgetCategory: b,
                  spent: _spentFor(b, allocs, txs),
                ),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }

  double _spentFor(
    BudgetCategoryModel b,
    List<AllocationModel> allocs,
    List<TransactionModel> txs,
  ) {
    final allocIds = {
      for (final a in allocs)
        if (a.budgetCategoryId == b.id) a.id,
    };
    double spent = 0;
    for (final t in txs) {
      if (allocIds.contains(t.allocationId) && !t.isIncome) {
        spent += t.amount;
      }
    }
    return spent;
  }
}

class _BudgetCategoryCard extends StatefulWidget {
  const _BudgetCategoryCard({
    required this.budgetCategory,
    required this.spent,
  });

  final BudgetCategoryModel budgetCategory;
  final double spent;

  @override
  State<_BudgetCategoryCard> createState() => _BudgetCategoryCardState();
}

class _BudgetCategoryCardState extends State<_BudgetCategoryCard> {
  Future<void> _edit() async {
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
    final category = AppDataScope.of(context).categories.byId(b.categoryId);
    final budget = b.amount;
    final pct = budget <= 0 ? 0.0 : (widget.spent / budget).clamp(0, 1);
    final over = widget.spent > budget;
    final primary = Theme.of(context).colorScheme.primary;
    final bar = over ? tokens.expenseRed : primary;
    return Material(
      color: tokens.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: tokens.bentoBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _edit,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: tokens.headingText,
                          ),
                        ),
                        if (category != null)
                          Text(
                            category.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: tokens.bodyText,
                              letterSpacing: 0.8,
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
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${formatMoney(widget.spent)} of ${formatMoney(budget)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: tokens.headingText,
                    ),
                  ),
                  Text(
                    over
                        ? '${(widget.spent - budget).toStringAsFixed(0)} '
                            'over'
                        : '${((1 - pct) * budget).toStringAsFixed(0)} left',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: over
                          ? tokens.expenseRed
                          : tokens.incomeGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: over ? 1 : pct.toDouble(),
                  minHeight: 8,
                  color: bar,
                  backgroundColor: tokens.bentoBorder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.tokens});

  final MyColors tokens;

  @override
  Widget build(BuildContext context) {
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
                Icons.pie_chart_outline,
                size: 32,
                color: tokens.brandDeep,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No budget categories yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: tokens.headingText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Back out and tap "Add New Budget Category" to create one.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: tokens.bodyText,
                height: 1.5,
              ),
            ),
          ],
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
