import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class CurrencyPickerScreen extends StatefulWidget {
  const CurrencyPickerScreen({super.key});

  @override
  State<CurrencyPickerScreen> createState() => _CurrencyPickerScreenState();
}

class _CurrencyPickerScreenState extends State<CurrencyPickerScreen> {
  final _query = ValueNotifier<String>('');
  final _selected = ValueNotifier<String>('USD');

  @override
  void dispose() {
    _query.dispose();
    _selected.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _BackPill(onTap: () => Navigator.of(context).pop()),
        leadingWidth: 64,
        title: const Text('Currency'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _SearchField(value: _query),
          const SizedBox(height: 20),
          _SectionLabel(text: 'POPULAR'),
          const SizedBox(height: 8),
          ValueListenableBuilder<String>(
            valueListenable: _selected,
            builder: (_, sel, _) => Column(
              children: [
                for (final c in _popular)
                  _Row(
                    currency: c,
                    selected: sel == c.code,
                    onTap: () => _selected.value = c.code,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel(text: 'ALL CURRENCIES'),
          const SizedBox(height: 8),
          ValueListenableBuilder<String>(
            valueListenable: _selected,
            builder: (_, sel, _) => ValueListenableBuilder<String>(
              valueListenable: _query,
              builder: (_, q, _) {
                final items = _all
                    .where((c) => c.matches(q))
                    .toList(growable: false);
                return Column(
                  children: [
                    for (final c in items)
                      _Row(
                        currency: c,
                        selected: sel == c.code,
                        onTap: () => _selected.value = c.code,
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Currency {
  const _Currency({
    required this.symbol,
    required this.code,
    required this.name,
  });

  final String symbol;
  final String code;
  final String name;

  bool matches(String q) {
    if (q.isEmpty) return true;
    final s = q.toLowerCase();
    return code.toLowerCase().contains(s) ||
        name.toLowerCase().contains(s) ||
        symbol.toLowerCase().contains(s);
  }
}

const _popular = <_Currency>[
  _Currency(symbol: '\$', code: 'USD', name: 'US Dollar'),
  _Currency(symbol: '€', code: 'EUR', name: 'Euro'),
  _Currency(symbol: '£', code: 'GBP', name: 'Pound Sterling'),
  _Currency(symbol: '₦', code: 'NGN', name: 'Nigerian Naira'),
];

const _all = <_Currency>[
  _Currency(symbol: 'A\$', code: 'AUD', name: 'Australian Dollar'),
  _Currency(symbol: 'C\$', code: 'CAD', name: 'Canadian Dollar'),
  _Currency(symbol: 'CHF', code: 'CHF', name: 'Swiss Franc'),
  _Currency(symbol: '¥', code: 'CNY', name: 'Chinese Yuan'),
  _Currency(symbol: '₹', code: 'INR', name: 'Indian Rupee'),
  _Currency(symbol: '¥', code: 'JPY', name: 'Japanese Yen'),
  _Currency(symbol: 'kr', code: 'NOK', name: 'Norwegian Krone'),
  _Currency(symbol: 'kr', code: 'SEK', name: 'Swedish Krona'),
  _Currency(symbol: 'S\$', code: 'SGD', name: 'Singapore Dollar'),
  _Currency(symbol: 'R', code: 'ZAR', name: 'South African Rand'),
];

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

class _SearchField extends StatelessWidget {
  const _SearchField({required this.value});

  final ValueNotifier<String> value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return TextField(
      onChanged: (v) => value.value = v,
      decoration: InputDecoration(
        hintText: 'Search',
        hintStyle: TextStyle(color: tokens.inputBorder),
        prefixIcon: Icon(
          Icons.search,
          size: 20,
          color: tokens.inputBorder,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: context.tokens.bodyText,
        letterSpacing: 1.0,
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.currency,
    required this.selected,
    required this.onTap,
  });

  final _Currency currency;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: Text(
                  currency.symbol,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: tokens.brandDeep,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 52,
                child: Text(
                  currency.code,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: tokens.headingText,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  currency.name,
                  style: TextStyle(
                    fontSize: 13,
                    color: tokens.bodyText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_circle,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
