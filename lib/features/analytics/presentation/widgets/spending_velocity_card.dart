import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SpendingVelocityCard extends StatelessWidget {
  const SpendingVelocityCard({super.key});

  static const _baseline = <double>[8, 11, 7, 4, 10, 13, 14];
  static const _current = <double>[5, 9, 12, 3, 14, 15, 14];
  static const _labels = <String>['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spending Velocity',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: tokens.headingText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Trend relative to baseline',
                    style: TextStyle(
                      fontSize: 12,
                      color: tokens.bodyText,
                    ),
                  ),
                ],
              ),
              const _DeltaChip(value: -12.4),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: _BarChart(
              baseline: _baseline,
              current: _current,
              labels: _labels,
            ),
          ),
          const SizedBox(height: 16),
          const _RemainingPill(),
        ],
      ),
    );
  }
}

class _DeltaChip extends StatelessWidget {
  const _DeltaChip({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final down = value < 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tokens.softLilacAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            down ? Icons.trending_down : Icons.trending_up,
            size: 14,
            color: tokens.brandDeep,
          ),
          const SizedBox(width: 4),
          Text(
            '${value.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: tokens.brandDeep,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({
    required this.baseline,
    required this.current,
    required this.labels,
  });

  final List<double> baseline;
  final List<double> current;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final tokens = context.tokens;
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 20,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 10,
                      color: tokens.bodyText,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < current.length; i++)
            BarChartGroupData(
              x: i,
              barsSpace: 4,
              barRods: [
                BarChartRodData(
                  toY: baseline[i],
                  color: primary.withValues(alpha: 0.22),
                  width: 8,
                  borderRadius: BorderRadius.circular(3),
                ),
                BarChartRodData(
                  toY: current[i],
                  color: primary,
                  width: 8,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _RemainingPill extends StatelessWidget {
  const _RemainingPill();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: tokens.softLilacAlt.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(
            Icons.donut_small_outlined,
            size: 16,
            color: tokens.brandDeep,
          ),
          const SizedBox(width: 8),
          Text(
            'Budget Remaining',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: tokens.headingText,
            ),
          ),
          const Spacer(),
          Text(
            '\$1,240.00',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: tokens.incomeGreen,
            ),
          ),
        ],
      ),
    );
  }
}
