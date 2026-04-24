import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum ExportFormat { csv, pdf }

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final _range = ValueNotifier<String>('Last 30 days');
  final _format = ValueNotifier<ExportFormat>(ExportFormat.csv);
  final _all = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _range.dispose();
    _format.dispose();
    _all.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _BackPill(onTap: () => Navigator.of(context).pop()),
        leadingWidth: 64,
        title: const Text('Export'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _LabeledSection(
            label: 'DATE RANGE',
            child: _RangePicker(value: _range),
          ),
          const SizedBox(height: 16),
          _LabeledSection(
            label: 'CATEGORIES',
            child: _CategoriesPicker(all: _all),
          ),
          const SizedBox(height: 16),
          _LabeledSection(
            label: 'FORMAT',
            child: _FormatToggle(value: _format),
          ),
          const SizedBox(height: 16),
          const _PreviewCard(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.ios_share, size: 18),
              label: const Text(
                'Export & Share',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
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

class _LabeledSection extends StatelessWidget {
  const _LabeledSection({required this.label, required this.child});

  final String label;
  final Widget child;

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
            fontWeight: FontWeight.w700,
            color: tokens.bodyText,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _RangePicker extends StatelessWidget {
  const _RangePicker({required this.value});

  final ValueNotifier<String> value;

  static const _options = <String>[
    'Last 7 days',
    'Last 30 days',
    'This month',
    'This year',
    'All time',
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ValueListenableBuilder<String>(
      valueListenable: value,
      builder: (_, v, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: tokens.cardSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: tokens.bentoBorder),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: v,
            isExpanded: true,
            icon: Icon(Icons.expand_more, color: tokens.bodyText),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: tokens.headingText,
            ),
            items: [
              for (final o in _options)
                DropdownMenuItem(value: o, child: Text(o)),
            ],
            onChanged: (v) {
              if (v != null) value.value = v;
            },
          ),
        ),
      ),
    );
  }
}

class _CategoriesPicker extends StatelessWidget {
  const _CategoriesPicker({required this.all});

  final ValueNotifier<bool> all;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ValueListenableBuilder<bool>(
      valueListenable: all,
      builder: (_, isAll, _) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _Chip(label: 'All', active: isAll, onTap: () => all.value = true),
          for (final c in const [
            'Utilities',
            'Entertainment',
            'Groceries',
            'Transport',
            'Health',
            'Clothing',
          ])
            _Chip(
              label: c,
              active: false,
              onTap: () => all.value = false,
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
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
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      color: active ? primary : tokens.cardSurface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: active ? primary : tokens.bentoBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : tokens.headingText,
            ),
          ),
        ),
      ),
    );
  }
}

class _FormatToggle extends StatelessWidget {
  const _FormatToggle({required this.value});

  final ValueNotifier<ExportFormat> value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: tokens.softLilacAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ValueListenableBuilder<ExportFormat>(
        valueListenable: value,
        builder: (_, v, _) => Row(
          children: [
            Expanded(
              child: _Seg(
                label: 'CSV',
                active: v == ExportFormat.csv,
                onTap: () => value.value = ExportFormat.csv,
              ),
            ),
            Expanded(
              child: _Seg(
                label: 'PDF',
                active: v == ExportFormat.pdf,
                onTap: () => value.value = ExportFormat.pdf,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  const _Seg({
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
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: active ? tokens.brandDeep : tokens.bodyText,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.bentoBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 16,
                color: tokens.brandDeep,
              ),
              const SizedBox(width: 8),
              Text(
                'PREVIEW',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: tokens.bodyText,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _PreviewRow(
            label: 'Transactions',
            value: '43',
            tokens: tokens,
          ),
          const SizedBox(height: 6),
          _PreviewRow(
            label: 'Total expense',
            value: '\$4,280.00',
            tokens: tokens,
            color: tokens.expenseRed,
          ),
          const SizedBox(height: 6),
          _PreviewRow(
            label: 'Total income',
            value: '\$1,763.24',
            tokens: tokens,
            color: tokens.incomeGreen,
          ),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.label,
    required this.value,
    required this.tokens,
    this.color,
  });

  final String label;
  final String value;
  final MyColors tokens;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: tokens.bodyText),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color ?? tokens.headingText,
          ),
        ),
      ],
    );
  }
}
