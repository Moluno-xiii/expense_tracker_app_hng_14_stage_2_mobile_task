import 'package:flutter/material.dart';

import '../../../app/app_data.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/allocation_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/ledger_entry.dart';
import '../../../data/models/transaction_model.dart';
import '../../auth/data/auth_controller.dart';
import '../../transactions/presentation/widgets/ledger_row.dart';

class AllocationDetailScreen extends StatefulWidget {
  const AllocationDetailScreen({required this.allocationId, super.key});

  final String allocationId;

  @override
  State<AllocationDetailScreen> createState() =>
      _AllocationDetailScreenState();
}

class _AllocationDetailScreenState extends State<AllocationDetailScreen> {
  Stream<List<TransactionModel>>? _stream;
  String? _uid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uid = AuthScope.of(context).user?.uid;
    if (uid != null && uid != _uid) {
      _uid = uid;
      _stream = AppDataScope.of(context).transactions.watchForUser(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appData = AppDataScope.of(context);
    final uid = _uid;
    if (uid == null) return const Scaffold();
    final allocation = appData.allocations.byId(widget.allocationId);
    if (allocation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Allocation')),
        body: const Center(child: Text('Allocation not found.')),
      );
    }
    final bc =
        appData.budgetCategories.byId(allocation.budgetCategoryId);
    final category =
        bc == null ? null : appData.categories.byId(bc.categoryId);
    return Scaffold(
      appBar: AppBar(
        leading: _BackPill(onTap: () => Navigator.of(context).pop()),
        leadingWidth: 64,
        title: Text(allocation.name),
      ),
      body: StreamBuilder<List<TransactionModel>>(
        stream: _stream,
        builder: (_, snap) {
          final txs = (snap.data ?? const <TransactionModel>[])
              .where((t) => t.allocationId == allocation.id)
              .toList();
          final spent = txs
              .where((t) => !t.isIncome)
              .fold<double>(0, (s, t) => s + t.amount);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              _HeaderCard(
                allocation: allocation,
                category: category,
                spent: spent,
              ),
              const SizedBox(height: 24),
              Text(
                'Transactions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: context.tokens.headingText,
                ),
              ),
              const SizedBox(height: 12),
              if (txs.isEmpty)
                const _EmptyTxs()
              else
                for (final t in txs) ...[
                  if (category != null)
                    LedgerRow(
                      entry: LedgerEntry.fromTransaction(
                        t,
                        allocation,
                        category,
                      ),
                    ),
                  const SizedBox(height: 10),
                ],
            ],
          );
        },
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.allocation,
    required this.category,
    required this.spent,
  });

  final AllocationModel allocation;
  final CategoryModel? category;
  final double spent;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final budget = allocation.amount;
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
          if (category != null)
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: tokens.softLilacAlt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(category!.icon,
                      size: 20, color: tokens.brandDeep),
                ),
                const SizedBox(width: 12),
                Text(
                  category!.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: tokens.bodyText,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 14),
          Text(
            allocation.name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: tokens.headingText,
            ),
          ),
          if (allocation.notes != null && allocation.notes!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              allocation.notes!,
              style: TextStyle(fontSize: 13, color: tokens.bodyText),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Metric(
                label: 'SPENT',
                value: formatMoney(spent),
                color: tokens.expenseRed,
              ),
              _Metric(
                label: 'BUDGET',
                value: budget != null ? formatMoney(budget) : '—',
                color: tokens.brandDeep,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: tokens.bodyText,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _EmptyTxs extends StatelessWidget {
  const _EmptyTxs();

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
              'No transactions against this allocation yet.',
              style: TextStyle(fontSize: 13, color: tokens.bodyText),
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
