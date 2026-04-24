import 'package:flutter/material.dart';

enum TxType { income, expense }

TxType _txTypeFromString(String s) =>
    s == 'income' ? TxType.income : TxType.expense;

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.userId,
    required this.allocationId,
    required this.amount,
    required this.type,
    required this.date,
    required this.description,
    required this.createdAt,
    this.note,
    this.iconCodePoint,
  });

  final String id;
  final String userId;
  final String allocationId;
  final double amount;
  final TxType type;
  final int date;
  final String description;
  final String? note;
  final int? iconCodePoint;
  final int createdAt;

  bool get isIncome => type == TxType.income;

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(date);

  IconData? get overrideIcon => iconCodePoint == null
      ? null
      : IconData(iconCodePoint!, fontFamily: 'MaterialIcons');

  TransactionModel copyWith({
    String? allocationId,
    double? amount,
    TxType? type,
    int? date,
    String? description,
    String? note,
    int? iconCodePoint,
    bool clearNote = false,
    bool clearIcon = false,
  }) {
    return TransactionModel(
      id: id,
      userId: userId,
      allocationId: allocationId ?? this.allocationId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      description: description ?? this.description,
      note: clearNote ? null : (note ?? this.note),
      iconCodePoint:
          clearIcon ? null : (iconCodePoint ?? this.iconCodePoint),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'allocationId': allocationId,
        'amount': amount,
        'type': type.name,
        'date': date,
        'description': description,
        'note': note,
        'iconCodePoint': iconCodePoint,
        'createdAt': createdAt,
      };

  factory TransactionModel.fromMap(Map<dynamic, dynamic> m) =>
      TransactionModel(
        id: m['id'] as String,
        userId: m['userId'] as String,
        allocationId: m['allocationId'] as String,
        amount: (m['amount'] as num).toDouble(),
        type: _txTypeFromString(m['type'] as String),
        date: m['date'] as int,
        description: m['description'] as String,
        note: m['note'] as String?,
        iconCodePoint: m['iconCodePoint'] as int?,
        createdAt: m['createdAt'] as int,
      );
}
