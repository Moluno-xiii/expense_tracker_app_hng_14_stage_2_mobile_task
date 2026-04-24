import 'package:flutter/material.dart';

@immutable
class MyColors extends ThemeExtension<MyColors> {
  const MyColors({
    required this.incomeGreen,
    required this.expenseRed,
    required this.warningAmber,
    required this.successGreen,
    required this.brandDeep,
    required this.cardSurface,
    required this.bentoBorder,
    required this.dividerSoft,
    required this.softLilac,
    required this.softLilacAlt,
    required this.inputFill,
    required this.inputBorder,
    required this.bodyText,
    required this.headingText,
    required this.chartA,
    required this.chartB,
    required this.chartC,
    required this.chartD,
    required this.chartE,
  });

  final Color incomeGreen;
  final Color expenseRed;
  final Color warningAmber;
  final Color successGreen;
  final Color brandDeep;
  final Color cardSurface;
  final Color bentoBorder;
  final Color dividerSoft;
  final Color softLilac;
  final Color softLilacAlt;
  final Color inputFill;
  final Color inputBorder;
  final Color bodyText;
  final Color headingText;
  final Color chartA;
  final Color chartB;
  final Color chartC;
  final Color chartD;
  final Color chartE;

  static MyColors light() => const MyColors(
        incomeGreen: Color(0xFF16A34A),
        expenseRed: Color(0xFFDC2626),
        warningAmber: Color(0xFFF59E0B),
        successGreen: Color(0xFF10B981),
        brandDeep: Color(0xFF1B365D),
        cardSurface: Color(0xFFFFFFFF),
        bentoBorder: Color(0xFFE2E8F0),
        dividerSoft: Color(0xFFE2E8F0),
        softLilac: Color(0xFFEEF2FF),
        softLilacAlt: Color(0xFFE6ECFF),
        inputFill: Color(0xFFF8F9FF),
        inputBorder: Color(0xFFC4C6CF),
        bodyText: Color(0xFF44474E),
        headingText: Color(0xFF0B1C30),
        chartA: Color(0xFF0051D5),
        chartB: Color(0xFF6366F1),
        chartC: Color(0xFF10B981),
        chartD: Color(0xFFF59E0B),
        chartE: Color(0xFF6B7280),
      );

  static MyColors dark() => const MyColors(
        incomeGreen: Color(0xFF22C55E),
        expenseRed: Color(0xFFF87171),
        warningAmber: Color(0xFFFBBF24),
        successGreen: Color(0xFF34D399),
        brandDeep: Color(0xFF93C5FD),
        cardSurface: Color(0xFF1E293B),
        bentoBorder: Color(0xFF334155),
        dividerSoft: Color(0xFF334155),
        softLilac: Color(0xFF1E2A4A),
        softLilacAlt: Color(0xFF1E293B),
        inputFill: Color(0xFF0F172A),
        inputBorder: Color(0xFF475569),
        bodyText: Color(0xFFCBD5E1),
        headingText: Color(0xFFF1F5F9),
        chartA: Color(0xFF3B82F6),
        chartB: Color(0xFF818CF8),
        chartC: Color(0xFF34D399),
        chartD: Color(0xFFFBBF24),
        chartE: Color(0xFF94A3B8),
      );

  @override
  MyColors copyWith({
    Color? incomeGreen,
    Color? expenseRed,
    Color? warningAmber,
    Color? successGreen,
    Color? brandDeep,
    Color? cardSurface,
    Color? bentoBorder,
    Color? dividerSoft,
    Color? softLilac,
    Color? softLilacAlt,
    Color? inputFill,
    Color? inputBorder,
    Color? bodyText,
    Color? headingText,
    Color? chartA,
    Color? chartB,
    Color? chartC,
    Color? chartD,
    Color? chartE,
  }) =>
      MyColors(
        incomeGreen: incomeGreen ?? this.incomeGreen,
        expenseRed: expenseRed ?? this.expenseRed,
        warningAmber: warningAmber ?? this.warningAmber,
        successGreen: successGreen ?? this.successGreen,
        brandDeep: brandDeep ?? this.brandDeep,
        cardSurface: cardSurface ?? this.cardSurface,
        bentoBorder: bentoBorder ?? this.bentoBorder,
        dividerSoft: dividerSoft ?? this.dividerSoft,
        softLilac: softLilac ?? this.softLilac,
        softLilacAlt: softLilacAlt ?? this.softLilacAlt,
        inputFill: inputFill ?? this.inputFill,
        inputBorder: inputBorder ?? this.inputBorder,
        bodyText: bodyText ?? this.bodyText,
        headingText: headingText ?? this.headingText,
        chartA: chartA ?? this.chartA,
        chartB: chartB ?? this.chartB,
        chartC: chartC ?? this.chartC,
        chartD: chartD ?? this.chartD,
        chartE: chartE ?? this.chartE,
      );

  @override
  MyColors lerp(ThemeExtension<MyColors>? other, double t) {
    if (other is! MyColors) return this;
    return MyColors(
      incomeGreen: Color.lerp(incomeGreen, other.incomeGreen, t)!,
      expenseRed: Color.lerp(expenseRed, other.expenseRed, t)!,
      warningAmber: Color.lerp(warningAmber, other.warningAmber, t)!,
      successGreen: Color.lerp(successGreen, other.successGreen, t)!,
      brandDeep: Color.lerp(brandDeep, other.brandDeep, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      bentoBorder: Color.lerp(bentoBorder, other.bentoBorder, t)!,
      dividerSoft: Color.lerp(dividerSoft, other.dividerSoft, t)!,
      softLilac: Color.lerp(softLilac, other.softLilac, t)!,
      softLilacAlt: Color.lerp(softLilacAlt, other.softLilacAlt, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      bodyText: Color.lerp(bodyText, other.bodyText, t)!,
      headingText: Color.lerp(headingText, other.headingText, t)!,
      chartA: Color.lerp(chartA, other.chartA, t)!,
      chartB: Color.lerp(chartB, other.chartB, t)!,
      chartC: Color.lerp(chartC, other.chartC, t)!,
      chartD: Color.lerp(chartD, other.chartD, t)!,
      chartE: Color.lerp(chartE, other.chartE, t)!,
    );
  }
}

extension MyColorsX on BuildContext {
  MyColors get tokens => Theme.of(this).extension<MyColors>()!;
}
