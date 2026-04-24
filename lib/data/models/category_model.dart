import 'package:flutter/material.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    required this.isBuiltIn,
    required this.createdAt,
    this.isIncome = false,
  });

  final String id;
  final String userId;
  final String name;
  final int iconCodePoint;
  final int colorValue;
  final bool isBuiltIn;
  final bool isIncome;
  final int createdAt;

  IconData get icon =>
      IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  Color get color => Color(colorValue);

  CategoryModel copyWith({
    String? name,
    int? iconCodePoint,
    int? colorValue,
    bool? isIncome,
  }) {
    return CategoryModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      isBuiltIn: isBuiltIn,
      isIncome: isIncome ?? this.isIncome,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'name': name,
        'iconCodePoint': iconCodePoint,
        'colorValue': colorValue,
        'isBuiltIn': isBuiltIn,
        'isIncome': isIncome,
        'createdAt': createdAt,
      };

  factory CategoryModel.fromMap(Map<dynamic, dynamic> m) => CategoryModel(
        id: m['id'] as String,
        userId: m['userId'] as String,
        name: m['name'] as String,
        iconCodePoint: m['iconCodePoint'] as int,
        colorValue: m['colorValue'] as int,
        isBuiltIn: m['isBuiltIn'] as bool? ?? false,
        isIncome: m['isIncome'] as bool? ?? false,
        createdAt: m['createdAt'] as int,
      );
}
