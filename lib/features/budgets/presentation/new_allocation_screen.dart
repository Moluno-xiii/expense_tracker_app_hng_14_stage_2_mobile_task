import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_data.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/amount_field.dart';
import '../../../data/models/allocation_model.dart';
import '../../../data/models/budget_category_model.dart';
import '../../../data/models/category_model.dart';
import '../../auth/data/auth_controller.dart';

class NewAllocationScreen extends StatefulWidget {
  const NewAllocationScreen({super.key});

  @override
  State<NewAllocationScreen> createState() => _NewAllocationScreenState();
}

class _NewAllocationScreenState extends State<NewAllocationScreen> {
  final _name = TextEditingController();
  final _amount = ValueNotifier<double>(0);
  final _selectedBudgetCategory = ValueNotifier<BudgetCategoryModel?>(null);
  final _notes = TextEditingController();

  String? _uid;
  Stream<List<BudgetCategoryModel>>? _bcStream;

  @override
  void initState() {
    super.initState();
    _name.addListener(_onFieldChanged);
    _amount.addListener(_onFieldChanged);
    _selectedBudgetCategory.addListener(_onFieldChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uid = AuthScope.of(context).user?.uid;
    if (uid != null && uid != _uid) {
      _uid = uid;
      _bcStream = AppDataScope.of(context).budgetCategories.watchForUser(uid);
    }
  }

  @override
  void dispose() {
    _name.removeListener(_onFieldChanged);
    _amount.removeListener(_onFieldChanged);
    _selectedBudgetCategory.removeListener(_onFieldChanged);
    _name.dispose();
    _amount.dispose();
    _selectedBudgetCategory.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  bool _canSave() {
    return _name.text.trim().isNotEmpty &&
        _selectedBudgetCategory.value != null &&
        _amount.value > 0;
  }

  Future<void> _save() async {
    final uid = _uid;
    final bc = _selectedBudgetCategory.value;
    if (uid == null || bc == null || _amount.value <= 0) return;
    final appData = AppDataScope.of(context);
    final now = DateTime.now().millisecondsSinceEpoch;
    await appData.allocations.add(
      AllocationModel(
        id: appData.newId(),
        userId: uid,
        budgetCategoryId: bc.id,
        name: _name.text.trim(),
        amount: _amount.value,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        createdAt: now,
      ),
    );
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _BackPill(onTap: () => Navigator.of(context).pop()),
        leadingWidth: 64,
        title: const Text('Add Allocation'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          _NameField(controller: _name),
          const SizedBox(height: 16),
          StreamBuilder<List<BudgetCategoryModel>>(
            stream: _bcStream,
            builder: (_, snap) {
              final options =
                  (snap.data ?? const <BudgetCategoryModel>[])
                      .where((b) => !b.isBuiltIn)
                      .toList()
                    ..sort((a, b) => a.name.compareTo(b.name));
              if (options.isEmpty) {
                return const _NoBudgetCategoriesEmpty();
              }
              return _BudgetCategoryPicker(
                value: _selectedBudgetCategory,
                options: options,
              );
            },
          ),
          const SizedBox(height: 16),
          AmountField(
            label: 'AMOUNT',
            value: _amount,
            onChanged: (_) {},
            primaryLabel: 'Continue',
          ),
          const SizedBox(height: 16),
          _NotesCard(controller: _notes),
        ],
      ),
      bottomNavigationBar: _SaveBar(enabled: _canSave(), onSave: _save),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({required this.controller});

  final TextEditingController controller;

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
            'ALLOCATION NAME',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: tokens.bodyText,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'e.g. School fare',
              hintStyle: TextStyle(color: tokens.inputBorder),
              prefixIcon: Icon(
                Icons.label_outline,
                size: 18,
                color: tokens.inputBorder,
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetCategoryPicker extends StatelessWidget {
  const _BudgetCategoryPicker({required this.value, required this.options});

  final ValueNotifier<BudgetCategoryModel?> value;
  final List<BudgetCategoryModel> options;

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
            'BUDGET CATEGORIES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: tokens.bodyText,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 104,
            child: ValueListenableBuilder<BudgetCategoryModel?>(
              valueListenable: value,
              builder: (_, current, _) => ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: options.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final b = options[i];
                  return _BudgetCategoryTile(
                    budgetCategory: b,
                    active: current?.id == b.id,
                    onTap: () => value.value = b,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoBudgetCategoriesEmpty extends StatelessWidget {
  const _NoBudgetCategoriesEmpty();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tokens.softLilacAlt.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.bentoBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, color: tokens.brandDeep, size: 24),
          const SizedBox(height: 8),
          Text(
            'No budget categories yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: tokens.headingText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You need a budget category before you can add an allocation. '
            'Head to Budgets, pick a category, and set a monthly budget '
            'for it.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: tokens.bodyText),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go(Routes.budgets),
              child: const Text('Go to Budgets'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetCategoryTile extends StatelessWidget {
  const _BudgetCategoryTile({
    required this.budgetCategory,
    required this.active,
    required this.onTap,
  });

  final BudgetCategoryModel budgetCategory;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final primary = Theme.of(context).colorScheme.primary;
    final parent = AppDataScope.of(
      context,
    ).categories.byId(budgetCategory.categoryId);
    return Material(
      color: active
          ? tokens.softLilacAlt
          : tokens.bentoBorder.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 108,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active ? primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                parent?.icon ?? Icons.category_outlined,
                size: 24,
                color: tokens.brandDeep,
              ),
              const SizedBox(height: 6),
              Text(
                budgetCategory.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: tokens.headingText,
                ),
              ),
              if (parent != null)
                Text(
                  parent.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: tokens.bodyText),
                ),
            ],
          ),
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
            'NOTES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: tokens.bodyText,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Optional notes',
              hintStyle: TextStyle(color: tokens.inputBorder),
              prefixIcon: Icon(
                Icons.notes_outlined,
                size: 18,
                color: tokens.inputBorder,
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 0,
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

class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.enabled, required this.onSave});

  final bool enabled;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final navy = context.tokens.brandDeep;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
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
        ),
      ),
    );
  }
}

Future<CategoryModel?> showNewCategorySheet(
  BuildContext context, {
  required String uid,
}) {
  return showModalBottomSheet<CategoryModel?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _NewCategorySheet(uid: uid),
  );
}

class _NewCategorySheet extends StatefulWidget {
  const _NewCategorySheet({required this.uid});

  final String uid;

  @override
  State<_NewCategorySheet> createState() => _NewCategorySheetState();
}

class _NewCategorySheetState extends State<_NewCategorySheet> {
  final _name = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final trimmed = _name.text.trim();
    if (trimmed.isEmpty) return;
    final appData = AppDataScope.of(context);
    final now = DateTime.now().millisecondsSinceEpoch;
    final model = CategoryModel(
      id: appData.newId(),
      userId: widget.uid,
      name: trimmed,
      iconCodePoint: Icons.category_outlined.codePoint,
      colorValue: Theme.of(context).colorScheme.primary.toARGB32(),
      isBuiltIn: false,
      createdAt: now,
    );
    await appData.categories.add(model);
    if (!mounted) return;
    Navigator.of(context).pop(model);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final canSave = _name.text.trim().isNotEmpty;
    final insets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: insets),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: tokens.cardSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: tokens.bentoBorder,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Text(
                'New Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: tokens.headingText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'CATEGORY NAME',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: tokens.bodyText,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _name,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'e.g. Groceries',
                  hintStyle: TextStyle(color: tokens.inputBorder),
                  prefixIcon: Icon(
                    Icons.label_outline,
                    size: 18,
                    color: tokens.inputBorder,
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 0,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: canSave ? _save : null,
                  child: const Text('Create Category'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
