import 'package:flutter/material.dart';

import '../../../../app/app_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/amount_field.dart';
import '../../../../data/models/budget_category_model.dart';
import '../../../../data/models/category_model.dart';

Future<bool?> showAddBudgetSheet(
  BuildContext context, {
  required String uid,
  required List<CategoryModel> categories,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddBudgetCategorySheet(uid: uid, categories: categories),
  );
}

class _AddBudgetCategorySheet extends StatefulWidget {
  const _AddBudgetCategorySheet({required this.uid, required this.categories});

  final String uid;
  final List<CategoryModel> categories;

  @override
  State<_AddBudgetCategorySheet> createState() =>
      _AddBudgetCategorySheetState();
}

class _AddBudgetCategorySheetState extends State<_AddBudgetCategorySheet> {
  final _selectedCategory = ValueNotifier<CategoryModel?>(null);
  final _name = TextEditingController();
  final _amount = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _selectedCategory.addListener(_onChanged);
    _name.addListener(_onChanged);
    _amount.addListener(_onChanged);
  }

  @override
  void dispose() {
    _selectedCategory.removeListener(_onChanged);
    _name.removeListener(_onChanged);
    _amount.removeListener(_onChanged);
    _selectedCategory.dispose();
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  bool get _canSave =>
      _selectedCategory.value != null &&
      _name.text.trim().isNotEmpty &&
      _amount.value > 0;

  Future<void> _save() async {
    final cat = _selectedCategory.value;
    if (cat == null || !_canSave) return;
    final appData = AppDataScope.of(context);
    await appData.budgetCategories.add(
      BudgetCategoryModel(
        id: appData.newId(),
        userId: widget.uid,
        name: _name.text.trim(),
        categoryId: cat.id,
        amount: _amount.value,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final insets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: insets),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.6,
        builder: (_, scroll) => Container(
          decoration: BoxDecoration(
            color: tokens.cardSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 4),
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: tokens.bentoBorder,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'New Budget Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: tokens.headingText,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scroll,
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  children: [
                    _CategoryPickerCard(
                      value: _selectedCategory,
                      options: widget.categories,
                    ),
                    const SizedBox(height: 16),
                    _NameCard(controller: _name),
                    const SizedBox(height: 16),
                    AmountField(
                      label: 'AMOUNT',
                      value: _amount,
                      onChanged: (_) {},
                      primaryLabel: 'Continue',
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _canSave ? _save : null,
                      child: const Text(
                        'Create Budget Category',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryPickerCard extends StatelessWidget {
  const _CategoryPickerCard({required this.value, required this.options});

  final ValueNotifier<CategoryModel?> value;
  final List<CategoryModel> options;

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
            'CATEGORY',
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
            child: ValueListenableBuilder<CategoryModel?>(
              valueListenable: value,
              builder: (_, current, _) => ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: options.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final c = options[i];
                  return _CategoryTile(
                    category: c,
                    active: current?.id == c.id,
                    onTap: () => value.value = c,
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

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.active,
    required this.onTap,
  });

  final CategoryModel category;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      color: active
          ? tokens.softLilacAlt
          : tokens.bentoBorder.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 92,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
        ),
      ),
    );
  }
}

class _NameCard extends StatelessWidget {
  const _NameCard({required this.controller});

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
            'BUDGET CATEGORY NAME',
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
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'e.g. Office commute',
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
