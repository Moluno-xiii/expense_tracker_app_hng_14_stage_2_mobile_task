import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/amount_field.dart';

class EditRuleScreen extends StatefulWidget {
  const EditRuleScreen({super.key});

  @override
  State<EditRuleScreen> createState() => _EditRuleScreenState();
}

class _EditRuleScreenState extends State<EditRuleScreen> {
  final _side = ValueNotifier<String>('Expense');
  final _amount = ValueNotifier<double>(0);
  final _category = ValueNotifier<String>('Salary');
  final _frequency = ValueNotifier<String>('Monthly');
  final _interval = ValueNotifier<int>(1);
  final _notes = TextEditingController();

  @override
  void dispose() {
    _side.dispose();
    _amount.dispose();
    _category.dispose();
    _frequency.dispose();
    _interval.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _BackPill(onTap: () => Navigator.of(context).pop()),
        leadingWidth: 64,
        title: const Text('New Rule'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _SideToggle(value: _side),
          const SizedBox(height: 16),
          AmountField(
            label: 'AMOUNT',
            value: _amount,
            onChanged: (_) {},
            primaryLabel: 'Continue',
          ),
          const SizedBox(height: 16),
          _CategoryRow(value: _category),
          const SizedBox(height: 16),
          _ScheduleCard(frequency: _frequency, interval: _interval),
          const SizedBox(height: 16),
          _NotesField(controller: _notes),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Save Rule',
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

class _SideToggle extends StatelessWidget {
  const _SideToggle({required this.value});

  final ValueNotifier<String> value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: tokens.softLilacAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ValueListenableBuilder<String>(
        valueListenable: value,
        builder: (_, v, _) => Row(
          children: [
            Expanded(
              child: _Seg(
                label: 'Income',
                active: v == 'Income',
                onTap: () => value.value = 'Income',
              ),
            ),
            Expanded(
              child: _Seg(
                label: 'Expense',
                active: v == 'Expense',
                onTap: () => value.value = 'Expense',
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

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.value});

  final ValueNotifier<String> value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tokens.bentoBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tokens.softLilacAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.folder_outlined,
                size: 18, color: tokens.brandDeep),
          ),
          const SizedBox(width: 12),
          Text(
            'Category',
            style: TextStyle(
              fontSize: 13,
              color: tokens.bodyText,
            ),
          ),
          const Spacer(),
          ValueListenableBuilder<String>(
            valueListenable: value,
            builder: (_, v, _) => Text(
              v,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: tokens.headingText,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.expand_more, size: 20, color: tokens.bodyText),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.frequency,
    required this.interval,
  });

  final ValueNotifier<String> frequency;
  final ValueNotifier<int> interval;

  static const _freq = <String>['Daily', 'Weekly', 'Biweekly', 'Monthly'];

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
          Text(
            'SCHEDULE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: tokens.bodyText,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in _freq)
                ValueListenableBuilder<String>(
                  valueListenable: frequency,
                  builder: (_, v, _) => _FreqChip(
                    label: f,
                    active: v == f,
                    onTap: () => frequency.value = f,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Every',
                style: TextStyle(fontSize: 13, color: tokens.bodyText),
              ),
              const SizedBox(width: 12),
              _Stepper(value: interval),
              const SizedBox(width: 12),
              ValueListenableBuilder<String>(
                valueListenable: frequency,
                builder: (_, f, _) => Text(
                  _period(f),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: tokens.headingText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: tokens.dividerSoft, height: 1),
          const SizedBox(height: 16),
          _DatePickRow(
            label: 'Start',
            value: '11/24/2023',
            tokens: tokens,
          ),
          const SizedBox(height: 10),
          _DatePickRow(
            label: 'End',
            value: 'Optional',
            tokens: tokens,
          ),
        ],
      ),
    );
  }

  String _period(String f) {
    switch (f) {
      case 'Daily':
        return 'day(s)';
      case 'Weekly':
        return 'week(s)';
      case 'Biweekly':
        return 'bi-week(s)';
      default:
        return 'month(s)';
    }
  }
}

class _FreqChip extends StatelessWidget {
  const _FreqChip({
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

class _Stepper extends StatelessWidget {
  const _Stepper({required this.value});

  final ValueNotifier<int> value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      decoration: BoxDecoration(
        color: tokens.softLilacAlt.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () =>
                value.value = value.value > 1 ? value.value - 1 : 1,
            icon: Icon(Icons.remove, size: 16, color: tokens.brandDeep),
          ),
          ValueListenableBuilder<int>(
            valueListenable: value,
            builder: (_, v, _) => SizedBox(
              width: 24,
              child: Center(
                child: Text(
                  '$v',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: tokens.headingText,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => value.value = value.value + 1,
            icon: Icon(Icons.add, size: 16, color: tokens.brandDeep),
          ),
        ],
      ),
    );
  }
}

class _DatePickRow extends StatelessWidget {
  const _DatePickRow({
    required this.label,
    required this.value,
    required this.tokens,
  });

  final String label;
  final String value;
  final MyColors tokens;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.calendar_today_outlined, size: 18, color: tokens.brandDeep),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: tokens.bodyText,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: tokens.headingText,
          ),
        ),
      ],
    );
  }
}

class _NotesField extends StatelessWidget {
  const _NotesField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.bentoBorder),
      ),
      child: TextField(
        controller: controller,
        minLines: 2,
        maxLines: 4,
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          isDense: true,
          hintText: 'Notes (optional)',
          hintStyle: TextStyle(color: tokens.inputBorder),
        ),
      ),
    );
  }
}
