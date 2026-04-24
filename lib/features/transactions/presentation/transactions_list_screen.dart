import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_data.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/ledger_entry.dart';
import '../../auth/data/auth_controller.dart';
import 'widgets/ledger_row.dart';

class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  State<TransactionsListScreen> createState() =>
      _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  Stream<List<LedgerEntry>>? _stream;
  String? _uid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uid = AuthScope.of(context).user?.uid;
    if (uid != null && uid != _uid) {
      _uid = uid;
      _stream = AppDataScope.of(context).watchLedger(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const _BackPill(),
        leadingWidth: 64,
        title: const Text('Recent Ledgers'),
      ),
      body: StreamBuilder<List<LedgerEntry>>(
        stream: _stream,
        builder: (_, snap) {
          final entries = snap.data ?? const [];
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              if (entries.isEmpty)
                const _EmptyState()
              else
                for (final e in entries) ...[
                  LedgerRow(entry: e),
                  const SizedBox(height: 10),
                ],
              const SizedBox(height: 12),
              const _QuickAddCard(),
            ],
          );
        },
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
        elevation: 0,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
              'No ledger entries yet. Make a deposit or record a '
              'transaction below.',
              style: TextStyle(fontSize: 13, color: tokens.bodyText),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAddCard extends StatelessWidget {
  const _QuickAddCard();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: tokens.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.bentoBorder),
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
            'New Entry',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: tokens.headingText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Record a new transaction',
            style: TextStyle(fontSize: 12, color: tokens.bodyText),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  context.push('${Routes.transactionsNew}?tab=manual'),
              child: const Text('Quick Add'),
            ),
          ),
        ],
      ),
    );
  }
}
