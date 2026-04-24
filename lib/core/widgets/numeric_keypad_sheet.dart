import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum AmountSide { expense, income }

class KeypadResult {
  const KeypadResult({required this.amount, this.side, this.description});

  final double amount;
  final AmountSide? side;
  final String? description;
}

Future<KeypadResult?> showAmountKeypad(
  BuildContext context, {
  double initial = 0,
  bool showSideToggle = false,
  String primaryLabel = 'Save Transaction',
  bool showDescription = false,
  bool descriptionRequired = false,
  String descriptionHint = 'Description',
}) {
  return showModalBottomSheet<KeypadResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => NumericKeypadSheet(
      initial: initial,
      showSideToggle: showSideToggle,
      primaryLabel: primaryLabel,
      showDescription: showDescription,
      descriptionRequired: descriptionRequired,
      descriptionHint: descriptionHint,
    ),
  );
}

class NumericKeypadSheet extends StatefulWidget {
  const NumericKeypadSheet({
    this.initial = 0,
    this.showSideToggle = false,
    this.primaryLabel = 'Save Transaction',
    this.showDescription = false,
    this.descriptionRequired = false,
    this.descriptionHint = 'Description',
    super.key,
  });

  final double initial;
  final bool showSideToggle;
  final String primaryLabel;
  final bool showDescription;
  final bool descriptionRequired;
  final String descriptionHint;

  @override
  State<NumericKeypadSheet> createState() => _NumericKeypadSheetState();
}

class _NumericKeypadSheetState extends State<NumericKeypadSheet> {
  late final ValueNotifier<String> _input;
  final _side = ValueNotifier<AmountSide>(AmountSide.expense);
  final _description = TextEditingController();

  @override
  void initState() {
    super.initState();
    final s = widget.initial == 0 ? '' : widget.initial.toStringAsFixed(2);
    _input = ValueNotifier<String>(s);
    _description.addListener(_notifyValidityChanged);
    _input.addListener(_notifyValidityChanged);
  }

  @override
  void dispose() {
    _description.removeListener(_notifyValidityChanged);
    _input.removeListener(_notifyValidityChanged);
    _input.dispose();
    _side.dispose();
    _description.dispose();
    super.dispose();
  }

  void _notifyValidityChanged() {
    if (mounted) setState(() {});
  }

  bool get _canSubmit {
    if (_amount() <= 0) return false;
    if (widget.descriptionRequired &&
        _description.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  String _formatted(String raw) {
    if (raw.isEmpty) return '0.00';
    if (!raw.contains('.')) return raw;
    final parts = raw.split('.');
    final dec = parts[1].length > 2 ? parts[1].substring(0, 2) : parts[1];
    return '${parts[0]}.$dec';
  }

  void _type(String k) {
    final cur = _input.value;
    if (k == '.' && cur.contains('.')) return;
    if (k == '.' && cur.isEmpty) {
      _input.value = '0.';
      return;
    }
    if (cur.contains('.') && cur.split('.')[1].length >= 2) return;
    _input.value = cur + k;
  }

  void _backspace() {
    final cur = _input.value;
    if (cur.isEmpty) return;
    _input.value = cur.substring(0, cur.length - 1);
  }

  double _amount() => double.tryParse(_input.value) ?? 0;

  void _submit() {
    if (!_canSubmit) return;
    final desc = _description.text.trim();
    Navigator.of(context).pop(
      KeypadResult(
        amount: _amount(),
        side: _side.value,
        description:
            widget.showDescription && desc.isNotEmpty ? desc : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      expand: false,
      builder: (_, scroll) => Container(
        decoration: BoxDecoration(
          color: tokens.cardSurface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const _Grabber(),
            if (widget.showSideToggle) const SizedBox(height: 12),
            if (widget.showSideToggle)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SideToggle(side: _side),
              ),
            if (widget.showDescription) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _DescriptionField(
                  controller: _description,
                  hint: widget.descriptionHint,
                  required: widget.descriptionRequired,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _AmountDisplay(input: _input, formatter: _formatted),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _KeypadGrid(
                onType: _type,
                onBackspace: _backspace,
                scrollController: scroll,
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canSubmit ? _submit : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 18),
                        const SizedBox(width: 8),
                        Text(widget.primaryLabel),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Grabber extends StatelessWidget {
  const _Grabber();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: tokens.bentoBorder,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _SideToggle extends StatelessWidget {
  const _SideToggle({required this.side});

  final ValueNotifier<AmountSide> side;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: tokens.softLilacAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ValueListenableBuilder<AmountSide>(
        valueListenable: side,
        builder: (_, s, _) => Row(
          children: [
            Expanded(
              child: _SegButton(
                label: 'Expense',
                active: s == AmountSide.expense,
                onTap: () => side.value = AmountSide.expense,
              ),
            ),
            Expanded(
              child: _SegButton(
                label: 'Income',
                active: s == AmountSide.income,
                onTap: () => side.value = AmountSide.income,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegButton extends StatelessWidget {
  const _SegButton({
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
    return Material(
      color: active ? tokens.cardSurface : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: active ? tokens.brandDeep : tokens.bodyText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AmountDisplay extends StatelessWidget {
  const _AmountDisplay({required this.input, required this.formatter});

  final ValueNotifier<String> input;
  final String Function(String) formatter;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AMOUNT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: tokens.bodyText,
                  letterSpacing: 1.0,
                ),
              ),
              _UsdChip(),
            ],
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<String>(
            valueListenable: input,
            builder: (_, v, _) => Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: tokens.inputBorder,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    formatter(v),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: tokens.brandDeep,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UsdChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tokens.brandDeep,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'USD',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _KeypadGrid extends StatelessWidget {
  const _KeypadGrid({
    required this.onType,
    required this.onBackspace,
    required this.scrollController,
  });

  final ValueChanged<String> onType;
  final VoidCallback onBackspace;
  final ScrollController scrollController;

  static const _keys = <String>['1', '2', '3', '4', '5', '6', '7', '8', '9',
      '.', '0', '⌫'];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.8,
      ),
      itemCount: _keys.length,
      itemBuilder: (_, i) {
        final k = _keys[i];
        return _Key(
          label: k,
          onTap: () => k == '⌫' ? onBackspace() : onType(k),
        );
      },
    );
  }
}

class _DescriptionField extends StatelessWidget {
  const _DescriptionField({
    required this.controller,
    required this.hint,
    required this.required,
  });

  final TextEditingController controller;
  final String hint;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        hintText: required ? '$hint (required)' : hint,
        hintStyle: TextStyle(color: tokens.inputBorder),
        filled: true,
        fillColor: tokens.cardSurface,
        prefixIcon: Icon(
          Icons.notes_outlined,
          size: 18,
          color: tokens.inputBorder,
        ),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 44, minHeight: 0),
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isBack = label == '⌫';
    return Material(
      color: tokens.softLilacAlt.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Center(
          child: isBack
              ? Icon(
                  Icons.backspace_outlined,
                  size: 22,
                  color: tokens.headingText,
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: tokens.headingText,
                  ),
                ),
        ),
      ),
    );
  }
}
