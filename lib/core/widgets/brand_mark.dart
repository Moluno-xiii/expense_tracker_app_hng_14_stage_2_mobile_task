import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.account_balance_outlined,
          size: compact ? 18 : 20,
          color: tokens.brandDeep,
        ),
        const SizedBox(width: 8),
        Text(
          'Surveying Expenses',
          style: TextStyle(
            fontSize: compact ? 16 : 18,
            fontWeight: FontWeight.w700,
            color: tokens.brandDeep,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}
