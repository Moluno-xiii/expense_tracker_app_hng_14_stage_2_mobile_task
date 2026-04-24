import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/brand_mark.dart';

class EnrollmentScaffold extends StatelessWidget {
  const EnrollmentScaffold({
    required this.child,
    this.showBack = false,
    this.onBack,
    this.centerBrand = false,
    super.key,
  });

  final Widget child;
  final bool showBack;
  final VoidCallback? onBack;
  final bool centerBrand;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              showBack: showBack,
              onBack: onBack,
              centerBrand: centerBrand,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.showBack,
    required this.onBack,
    required this.centerBrand,
  });

  final bool showBack;
  final VoidCallback? onBack;
  final bool centerBrand;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: tokens.cardSurface,
        border: Border(bottom: BorderSide(color: tokens.dividerSoft)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (showBack)
            _BackPill(onPressed: onBack ?? () => Navigator.of(context).pop()),
          if (showBack) const SizedBox(width: 12),
          if (centerBrand) const Spacer(),
          const BrandMark(),
          if (centerBrand) const Spacer(),
        ],
      ),
    );
  }
}

class _BackPill extends StatelessWidget {
  const _BackPill({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Material(
      color: tokens.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: tokens.bentoBorder),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            Icons.arrow_back,
            size: 20,
            color: tokens.headingText,
          ),
        ),
      ),
    );
  }
}
