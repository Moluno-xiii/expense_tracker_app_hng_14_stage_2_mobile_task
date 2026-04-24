import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

enum SuggestionTone { highImpact, strategy }

class SmartSuggestionCard extends StatelessWidget {
  const SmartSuggestionCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.tone,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final SuggestionTone tone;

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
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: tokens.softLilacAlt,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: tokens.brandDeep),
              ),
              const Spacer(),
              _ToneChip(tone: tone),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: tokens.headingText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: tokens.bodyText,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                actionLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward,
                size: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToneChip extends StatelessWidget {
  const _ToneChip({required this.tone});

  final SuggestionTone tone;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final high = tone == SuggestionTone.highImpact;
    final color = high ? tokens.incomeGreen : tokens.brandDeep;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        high ? 'HIGH IMPACT' : 'STRATEGY',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
