import 'package:flutter/material.dart';

import 'allocation_model.dart';
import 'category_model.dart';
import 'transaction_model.dart';

class LedgerEntry {
  const LedgerEntry({
    required this.id,
    required this.title,
    required this.allocationName,
    required this.categoryName,
    required this.icon,
    required this.amount,
    required this.isIncome,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String allocationName;
  final String categoryName;
  final IconData icon;
  final double amount;
  final bool isIncome;
  final int createdAt;

  factory LedgerEntry.fromTransaction(
    TransactionModel t,
    AllocationModel a,
    CategoryModel c,
  ) {
    return LedgerEntry(
      id: 't-${t.id}',
      title: t.description,
      allocationName: a.name,
      categoryName: c.name,
      icon: t.overrideIcon ?? c.icon,
      amount: t.amount,
      isIncome: t.isIncome,
      createdAt: t.createdAt,
    );
  }
}
