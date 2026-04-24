import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_data.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_brand_bar.dart';
import '../../../core/widgets/fab_speed_dial.dart';
import '../../../core/widgets/numeric_keypad_sheet.dart';
import '../../../data/models/allocation_model.dart';
import '../../../data/models/budget_category_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/ledger_entry.dart';
import '../../../data/models/transaction_model.dart';
import '../../auth/data/auth_controller.dart';
import 'widgets/balance_card.dart';
import 'widgets/ledger_row.dart';
import 'widgets/spending_trend_card.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  Stream<double>? _balanceStream;
  // Two independent ledger streams: one for the allocations scroller,
  // one for the Recent Ledger section. `watchLedger` returns a broadcast
  // stream where the initial emission fires inside `onListen` — which
  // runs exactly once per controller. If two widgets share the same
  // stream, only the first one subscribes in time to receive the
  // initial value, leaving the second one stuck on "no data" until a
  // new box event comes along. Giving each widget its own controller
  // sidesteps that.
  Stream<List<LedgerEntry>>? _allocationsLedgerStream;
  Stream<List<LedgerEntry>>? _recentLedgerStream;
  String? _uid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uid = AuthScope.of(context).user?.uid;
    if (uid != null && uid != _uid) {
      _uid = uid;
      final appData = AppDataScope.of(context);
      _balanceStream = appData.watchBalance(uid);
      _allocationsLedgerStream = appData.watchLedger(uid);
      _recentLedgerStream = appData.watchLedger(uid);
    }
  }

  Future<void> _onDeposit() async {
    final uid = _uid;
    if (uid == null) return;
    final appData = AppDataScope.of(context);
    final result = await showAmountKeypad(
      context,
      primaryLabel: 'Deposit',
      showDescription: true,
      descriptionRequired: true,
      descriptionHint: 'What is this deposit for?',
    );
    if (!mounted || result == null || result.amount <= 0) return;
    final alloc = await appData.depositAllocation();
    if (!mounted) return;
    if (alloc == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Couldn't find the Deposit allocation. Try reopening the app.",
          ),
          backgroundColor: context.tokens.expenseRed,
        ),
      );
      return;
    }
    await _saveTransaction(
      appData,
      uid: uid,
      allocation: alloc,
      amount: result.amount,
      type: TxType.income,
      description: result.description ?? 'Deposit',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deposit of ${formatMoney(result.amount)} recorded.'),
      ),
    );
  }

  Future<void> _onWithdraw(double currentBalance) async {
    final uid = _uid;
    if (uid == null) return;
    final appData = AppDataScope.of(context);
    final result = await showAmountKeypad(
      context,
      primaryLabel: 'Withdraw',
      showDescription: true,
      descriptionRequired: true,
      descriptionHint: 'What is this withdrawal for?',
    );
    if (!mounted || result == null || result.amount <= 0) return;
    if (result.amount > currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient funds. Available balance: '
            '${formatMoney(currentBalance)}.',
          ),
          backgroundColor: context.tokens.expenseRed,
        ),
      );
      return;
    }
    final alloc = await appData.withdrawalAllocation();
    if (!mounted) return;
    if (alloc == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Couldn't find the Withdrawal allocation. "
            'Try reopening the app.',
          ),
          backgroundColor: context.tokens.expenseRed,
        ),
      );
      return;
    }
    await _saveTransaction(
      appData,
      uid: uid,
      allocation: alloc,
      amount: result.amount,
      type: TxType.expense,
      description: result.description ?? 'Withdrawal',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Withdrew ${formatMoney(result.amount)}.'),
      ),
    );
  }

  Future<void> _saveTransaction(
    AppData appData, {
    required String uid,
    required AllocationModel allocation,
    required double amount,
    required TxType type,
    required String description,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await appData.transactions.add(
      TransactionModel(
        id: appData.newId(),
        userId: uid,
        allocationId: allocation.id,
        amount: amount,
        type: type,
        date: now,
        description: description,
        createdAt: now,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const AppBrandBar(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                  children: [
                    StreamBuilder<double>(
                      stream: _balanceStream,
                      builder: (_, snap) {
                        final balance = snap.data ?? 0;
                        return BalanceCard(
                          balance: balance,
                          onDeposit: _onDeposit,
                          onWithdraw: () => _onWithdraw(balance),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    _SectionHeader(
                      title: 'Allocations',
                      actionLabel: 'View All',
                      onAction: () => context.push(Routes.allocations),
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<List<LedgerEntry>>(
                      stream: _allocationsLedgerStream,
                      builder: (ctx, _) {
                        final uid = _uid;
                        if (uid == null) {
                          return const SizedBox(height: 168);
                        }
                        final appData = AppDataScope.of(ctx);
                        final allocs = appData.allocations
                            .forUser(uid)
                            .where((a) => !a.isBuiltIn)
                            .take(10)
                            .toList();
                        final txs = appData.transactions.forUser(uid);
                        final bcs = {
                          for (final b
                              in appData.budgetCategories.forUser(uid))
                            b.id: b,
                        };
                        final cats = {
                          for (final c in appData.categories.forUser(uid))
                            c.id: c,
                        };
                        return _AllocationsScroller(
                          allocations: allocs,
                          transactions: txs,
                          budgetCategories: bcs,
                          categories: cats,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    SpendingTrendCard(title: 'Spending Trend'),
                    const SizedBox(height: 24),
                    _SectionHeader(
                      title: 'Recent Ledger',
                      actionLabel: 'VIEW ALL',
                      onAction: () => context.push(Routes.transactions),
                    ),
                    const SizedBox(height: 12),
                    _RecentLedger(stream: _recentLedgerStream),
                  ],
                ),
              ),
            ],
          ),
          Positioned.fill(child: _FabOverlay()),
        ],
      ),
    );
  }
}

class _RecentLedger extends StatelessWidget {
  const _RecentLedger({required this.stream});

  final Stream<List<LedgerEntry>>? stream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LedgerEntry>>(
      stream: stream,
      builder: (_, snap) {
        final entries = snap.data ?? const [];
        if (entries.isEmpty) return const _EmptyLedger();
        return Column(
          children: [
            for (final e in entries.take(10)) ...[
              LedgerRow(entry: e),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

class _EmptyLedger extends StatelessWidget {
  const _EmptyLedger();

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
          Icon(Icons.receipt_long_outlined, color: tokens.bodyText),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No transactions yet — deposit or make an allocation to start.',
              style: TextStyle(fontSize: 13, color: tokens.bodyText),
            ),
          ),
        ],
      ),
    );
  }
}

class _FabOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FabSpeedDial(
      actions: [
        FabAction(
          icon: Icons.edit_outlined,
          tooltip: 'Manual',
          onTap: () => context.push('${Routes.transactionsNew}?tab=manual'),
        ),
        FabAction(
          icon: Icons.center_focus_strong_outlined,
          tooltip: 'Capture',
          onTap: () => context.push('${Routes.transactionsNew}?tab=capture'),
        ),
        FabAction(
          icon: Icons.upload_file_outlined,
          tooltip: 'Upload Data',
          onTap: () => context.push('${Routes.transactionsNew}?tab=upload'),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

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
        GestureDetector(
          onTap: onAction,
          child: Text(
            actionLabel,
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

class _AllocationsScroller extends StatelessWidget {
  const _AllocationsScroller({
    required this.allocations,
    required this.transactions,
    required this.budgetCategories,
    required this.categories,
  });

  final List<AllocationModel> allocations;
  final List<TransactionModel> transactions;
  final Map<String, BudgetCategoryModel> budgetCategories;
  final Map<String, CategoryModel> categories;

  @override
  Widget build(BuildContext context) {
    if (allocations.isEmpty) {
      return const _NoAllocationsCard();
    }
    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: allocations.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) {
          final a = allocations[i];
          final bc = budgetCategories[a.budgetCategoryId];
          final cat = bc == null ? null : categories[bc.categoryId];
          double spent = 0;
          for (final t in transactions) {
            if (t.allocationId == a.id && !t.isIncome) {
              spent += t.amount;
            }
          }
          return _AllocationTile(
            allocation: a,
            parentCategory: cat,
            spent: spent,
            onTap: () => ctx.push('/allocations/${a.id}'),
          );
        },
      ),
    );
  }
}

class _AllocationTile extends StatelessWidget {
  const _AllocationTile({
    required this.allocation,
    required this.parentCategory,
    required this.spent,
    required this.onTap,
  });

  final AllocationModel allocation;
  final CategoryModel? parentCategory;
  final double spent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final limit = allocation.amount ?? 0;
    final hasLimit = limit > 0;
    final over = hasLimit && spent > limit;
    final progress = hasLimit ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final left = limit - spent;
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
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: tokens.softLilacAlt,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    parentCategory?.icon ?? Icons.account_tree_outlined,
                    size: 16,
                    color: tokens.brandDeep,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  allocation.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: tokens.headingText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${spent.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: tokens.brandDeep,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: over ? 1.0 : progress,
                    minHeight: 4,
                    color: over
                        ? tokens.expenseRed
                        : Theme.of(context).colorScheme.primary,
                    backgroundColor: tokens.bentoBorder,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hasLimit
                      ? '\$${left.abs().toStringAsFixed(0)} '
                          '${over ? 'OVER' : 'LEFT'}'
                      : 'NO LIMIT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: over
                        ? tokens.expenseRed
                        : (hasLimit
                            ? tokens.incomeGreen
                            : tokens.bodyText),
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

class _NoAllocationsCard extends StatelessWidget {
  const _NoAllocationsCard();

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
          Icon(Icons.account_tree_outlined, color: tokens.bodyText),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No allocations yet. Create one from Allocations to start '
              'budgeting by bucket.',
              style: TextStyle(fontSize: 13, color: tokens.bodyText),
            ),
          ),
        ],
      ),
    );
  }
}
