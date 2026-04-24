import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_data.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/amount_field.dart';
import '../../../data/models/allocation_model.dart';
import '../../../data/models/budget_category_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../auth/data/auth_controller.dart';

enum AddTxTab { manual, capture, upload }

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({this.initialTab = AddTxTab.manual, super.key});

  final AddTxTab initialTab;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late final ValueNotifier<AddTxTab> _tab;

  @override
  void initState() {
    super.initState();
    _tab = ValueNotifier<AddTxTab>(widget.initialTab);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _BackPill(onTap: () => Navigator.of(context).pop()),
        leadingWidth: 64,
        title: const Text('Add Transaction'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: _TabBar(tab: _tab),
          ),
          Expanded(
            child: ValueListenableBuilder<AddTxTab>(
              valueListenable: _tab,
              builder: (_, t, _) {
                switch (t) {
                  case AddTxTab.manual:
                    return const _ManualTab();
                  case AddTxTab.capture:
                    return const _ComingSoonTab(
                      title: 'Capture something',
                      subtitle: 'Coming soon',
                    );
                  case AddTxTab.upload:
                    return const _ComingSoonTab(
                      title: 'Upload data',
                      subtitle: 'Coming soon',
                    );
                }
              },
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

class _TabBar extends StatelessWidget {
  const _TabBar({required this.tab});

  final ValueNotifier<AddTxTab> tab;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AddTxTab>(
      valueListenable: tab,
      builder: (_, t, _) => Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Manual',
              active: t == AddTxTab.manual,
              onTap: () => tab.value = AddTxTab.manual,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TabButton(
              label: 'Capture',
              active: t == AddTxTab.capture,
              onTap: () => tab.value = AddTxTab.capture,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TabButton(
              label: 'Upload Data',
              active: t == AddTxTab.upload,
              onTap: () => tab.value = AddTxTab.upload,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
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
    final bg = active ? tokens.softLilacAlt : tokens.cardSurface;
    final fg = active ? tokens.brandDeep : tokens.bodyText;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active
                  ? Theme.of(context).colorScheme.primary
                  : tokens.bentoBorder,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}

class _ManualTab extends StatefulWidget {
  const _ManualTab();

  @override
  State<_ManualTab> createState() => _ManualTabState();
}

class _ManualTabState extends State<_ManualTab> {
  final _payee = TextEditingController();
  final _allocation = ValueNotifier<AllocationModel?>(null);
  final _amount = ValueNotifier<double>(0);
  final _notes = TextEditingController();

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
    _payee.dispose();
    _allocation.dispose();
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AllocationModel>>(
      stream: _stream,
      builder: (ctx, snap) {
        final all = snap.data ?? const [];
        final uid = _uid;
        if (uid == null) return const SizedBox.shrink();
        final appData = AppDataScope.of(ctx);
        final categories = {
          for (final c in appData.categories.forUser(uid)) c.id: c,
        };
        final bcs = {
          for (final b in appData.budgetCategories.forUser(uid)) b.id: b,
        };
        final selectable = all.where((a) => !a.isBuiltIn).toList();

        if (selectable.isEmpty) {
          return const _NoAllocationsEmpty();
        }

        if (_allocation.value != null &&
            !selectable.any((a) => a.id == _allocation.value!.id)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _allocation.value = null;
          });
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            _DetailsCard(
              payee: _payee,
              allocation: _allocation,
              allocations: selectable,
              categories: categories,
              budgetCategories: bcs,
            ),
            const SizedBox(height: 16),
            AmountField(
              label: 'AMOUNT',
              value: _amount,
              onChanged: (_) {},
              showSideToggle: false,
              primaryLabel: 'Continue',
            ),
            const SizedBox(height: 16),
            _NotesCard(controller: _notes),
            const SizedBox(height: 24),
            ListenableBuilder(
              listenable: Listenable.merge([_payee, _allocation, _amount]),
              builder: (_, _) => _SaveBar(enabled: _canSubmit(), onSave: _save),
            ),
          ],
        );
      },
    );
  }

  bool _canSubmit() {
    return _allocation.value != null &&
        _amount.value > 0 &&
        _payee.text.trim().isNotEmpty;
  }

  Future<void> _save() async {
    final uid = _uid;
    if (uid == null) return;
    final picked = _allocation.value;
    if (picked == null) return;
    final appData = AppDataScope.of(context);
    final now = DateTime.now().millisecondsSinceEpoch;
    await appData.transactions.add(
      TransactionModel(
        id: appData.newId(),
        userId: uid,
        allocationId: picked.id,
        amount: _amount.value,
        type: TxType.expense,
        date: now,
        description: _payee.text.trim(),
        note: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        createdAt: now,
      ),
    );
    if (!mounted) return;
    context.go(Routes.transactions);
  }
}

class _NoAllocationsEmpty extends StatelessWidget {
  const _NoAllocationsEmpty();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final primary = Theme.of(context).colorScheme.primary;
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
                color: primary,
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
              'Every transaction pulls from an allocation you set up.\n'
              'Create one first, then come back here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: tokens.bodyText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push(Routes.allocations),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Go to Allocations'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({
    required this.payee,
    required this.allocation,
    required this.allocations,
    required this.categories,
    required this.budgetCategories,
  });

  final TextEditingController payee;
  final ValueNotifier<AllocationModel?> allocation;
  final List<AllocationModel> allocations;
  final Map<String, CategoryModel> categories;
  final Map<String, BudgetCategoryModel> budgetCategories;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.softLilacAlt.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.bentoBorder),
      ),
      child: Column(
        children: [
          _LabeledInput(
            label: 'PAYEE',
            hint: 'e.g. Apple Store',
            icon: Icons.person_outline,
            controller: payee,
          ),
          const SizedBox(height: 14),
          const _DateRow(),
          const SizedBox(height: 14),
          _AllocationPickerRow(
            value: allocation,
            allocations: allocations,
            categories: categories,
            budgetCategories: budgetCategories,
          ),
        ],
      ),
    );
  }
}

class _LabeledInput extends StatelessWidget {
  const _LabeledInput({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: tokens.bodyText,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: tokens.cardSurface,
            hintText: hint,
            hintStyle: TextStyle(color: tokens.inputBorder),
            prefixIcon: Icon(icon, size: 18, color: tokens.inputBorder),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DATE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: tokens.bodyText,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: tokens.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: tokens.inputBorder),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: tokens.inputBorder,
              ),
              const SizedBox(width: 12),
              Text(
                '${now.month.toString().padLeft(2, '0')}/'
                '${now.day.toString().padLeft(2, '0')}/'
                '${now.year}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: tokens.headingText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AllocationPickerRow extends StatelessWidget {
  const _AllocationPickerRow({
    required this.value,
    required this.allocations,
    required this.categories,
    required this.budgetCategories,
  });

  final ValueNotifier<AllocationModel?> value;
  final List<AllocationModel> allocations;
  final Map<String, CategoryModel> categories;
  final Map<String, BudgetCategoryModel> budgetCategories;

  CategoryModel? _categoryFor(AllocationModel a) {
    final bc = budgetCategories[a.budgetCategoryId];
    if (bc == null) return null;
    return categories[bc.categoryId];
  }

  Future<void> _pick(BuildContext context) async {
    final selected = await showModalBottomSheet<AllocationModel>(
      context: context,
      backgroundColor: context.tokens.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AllocationPickerSheet(
        allocations: allocations,
        categories: categories,
        budgetCategories: budgetCategories,
      ),
    );
    if (selected != null) value.value = selected;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ALLOCATION',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: tokens.bodyText,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        ValueListenableBuilder<AllocationModel?>(
          valueListenable: value,
          builder: (_, current, _) {
            final cat = current == null ? null : _categoryFor(current);
            String label;
            if (current == null) {
              label = 'Pick an allocation';
            } else {
              final name = current.name.isEmpty
                  ? (cat?.name ?? 'Allocation')
                  : current.name;
              final amt = current.amount;
              label = amt == null
                  ? name
                  : '$name  •  \$${amt.toStringAsFixed(0)}';
            }
            return InkWell(
              onTap: () => _pick(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: tokens.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: tokens.inputBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: current == null
                              ? tokens.inputBorder
                              : tokens.headingText,
                        ),
                      ),
                    ),
                    Icon(Icons.expand_more, size: 20, color: tokens.bodyText),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AllocationPickerSheet extends StatelessWidget {
  const _AllocationPickerSheet({
    required this.allocations,
    required this.categories,
    required this.budgetCategories,
  });

  final List<AllocationModel> allocations;
  final Map<String, CategoryModel> categories;
  final Map<String, BudgetCategoryModel> budgetCategories;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: tokens.bentoBorder,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Text(
              'Choose an allocation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: tokens.headingText,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: allocations.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final a = allocations[i];
                  final bc = budgetCategories[a.budgetCategoryId];
                  final c = bc == null ? null : categories[bc.categoryId];
                  final sublineParts = <String>[
                    if (bc != null) bc.name,
                    if (c != null) c.name,
                    if (a.amount != null) '\$${a.amount!.toStringAsFixed(0)}',
                  ];
                  return ListTile(
                    onTap: () => Navigator.of(context).pop(a),
                    leading: c == null
                        ? null
                        : CircleAvatar(
                            backgroundColor: tokens.softLilacAlt,
                            child: Icon(
                              c.icon,
                              size: 18,
                              color: tokens.brandDeep,
                            ),
                          ),
                    title: Text(a.name.isEmpty ? (c?.name ?? '—') : a.name),
                    subtitle: Text(sublineParts.join('  •  ')),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: tokens.bentoBorder),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.bentoBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes_outlined, size: 16, color: tokens.inputBorder),
              const SizedBox(width: 8),
              Text(
                'NOTES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: tokens.bodyText,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              isDense: true,
              hintText: 'What was this for?',
              hintStyle: TextStyle(color: tokens.inputBorder),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComingSoonTab extends StatelessWidget {
  const _ComingSoonTab({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: DottedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: tokens.softLilacAlt,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.add_card_outlined,
                size: 24,
                color: tokens.brandDeep,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: tokens.headingText,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: tokens.bodyText),
            ),
          ],
        ),
      ),
    );
  }
}

class DottedBox extends StatelessWidget {
  const DottedBox({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: tokens.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.inputBorder, width: 1.2),
      ),
      child: Center(child: child),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.enabled, required this.onSave});

  final bool enabled;
  final VoidCallback onSave;

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
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: enabled ? onSave : null,
        child: Ink(
          decoration: BoxDecoration(
            gradient: enabled
                ? LinearGradient(colors: [navy, const Color(0xFF0051D5)])
                : null,
            color: enabled ? null : context.tokens.bentoBorder,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            alignment: Alignment.center,
            child: const Text(
              'Save Up!',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
