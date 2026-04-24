import 'package:flutter/material.dart';

import '../mock/mock_data.dart';
import '../theme/app_colors.dart';
import 'numeric_keypad_sheet.dart';

class AmountField extends StatelessWidget {
  const AmountField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.showSideToggle = false,
    this.primaryLabel = 'Continue',
    super.key,
  });

  final String label;
  final ValueNotifier<double> value;
  final ValueChanged<double> onChanged;
  final bool showSideToggle;
  final String primaryLabel;

  Future<void> _openKeypad(BuildContext ctx) async {
    final res = await showAmountKeypad(
      ctx,
      initial: value.value,
      showSideToggle: showSideToggle,
      primaryLabel: primaryLabel,
    );
    if (res != null) {
      value.value = res.amount;
      onChanged(res.amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Material(
      color: tokens.cardSurface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => _openKeypad(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
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
                    label,
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
              ValueListenableBuilder<double>(
                valueListenable: value,
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
                        v == 0
                            ? '0.00'
                            : formatMoney(v).replaceAll('\$', ''),
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
        ),
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
