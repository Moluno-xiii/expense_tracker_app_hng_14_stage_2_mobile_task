import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AllocationDonutCard extends StatelessWidget {
  const AllocationDonutCard({super.key});

  static const _slices = <_Slice>[
    _Slice('Housing & Utilities', 45, 0),
    _Slice('Investments', 25, 1),
    _Slice('Lifestyle', 15, 2),
    _Slice('Others', 15, 3),
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = <Color>[
      tokens.brandDeep,
      tokens.chartA,
      tokens.incomeGreen,
      tokens.chartE,
    ];
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
                'Allocation',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: tokens.headingText,
                ),
              ),
              Text(
                'View All',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: _Donut(slices: _slices, palette: palette),
              ),
              const SizedBox(width: 20),
              Expanded(child: _Legend(slices: _slices, palette: palette)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Slice {
  const _Slice(this.label, this.pct, this.index);

  final String label;
  final double pct;
  final int index;
}

class _Donut extends StatelessWidget {
  const _Donut({required this.slices, required this.palette});

  final List<_Slice> slices;
  final List<Color> palette;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 44,
            startDegreeOffset: -90,
            sections: [
              for (final s in slices)
                PieChartSectionData(
                  value: s.pct,
                  color: palette[s.index],
                  radius: 18,
                  showTitle: false,
                ),
            ],
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'TOTAL',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: tokens.bodyText,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              '\$14.2k',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: tokens.brandDeep,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.slices, required this.palette});

  final List<_Slice> slices;
  final List<Color> palette;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final s in slices) ...[
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: palette[s.index],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  s.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: tokens.headingText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${s.pct.toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: tokens.bodyText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
