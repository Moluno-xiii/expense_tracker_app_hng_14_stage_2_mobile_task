import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../budgets/presentation/widgets/allocation_card.dart';

class CategoriesListScreen extends StatelessWidget {
  const CategoriesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _BackPill(onTap: () => Navigator.of(context).pop()),
        leadingWidth: 64,
        title: const Text('Categories'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          for (final c in MockData.allocations) ...[
            AllocationListTile(
              category: c,
              onTap: () => context.push('/budgets/${c.id}'),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          _CreateCard(
            onTap: () => context.push(Routes.budgetsCategoriesNew),
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
            child: Icon(
              Icons.arrow_back,
              size: 18,
              color: tokens.brandDeep,
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateCard extends StatelessWidget {
  const _CreateCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return DottedCard(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tokens.softLilacAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.add_card_outlined,
              size: 22,
              color: tokens.brandDeep,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Create New Category',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: tokens.headingText,
            ),
          ),
        ],
      ),
    );
  }
}

class DottedCard extends StatelessWidget {
  const DottedCard({required this.child, this.onTap, super.key});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Material(
      color: tokens.cardSurface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: tokens.inputBorder,
              width: 1.2,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
