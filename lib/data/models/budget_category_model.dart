class BudgetCategoryModel {
  const BudgetCategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.categoryId,
    required this.amount,
    required this.createdAt,
    this.isBuiltIn = false,
  });

  final String id;
  final String userId;
  final String name;
  final String categoryId;
  final double amount;
  final bool isBuiltIn;
  final int createdAt;

  BudgetCategoryModel copyWith({
    String? name,
    String? categoryId,
    double? amount,
  }) {
    return BudgetCategoryModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      isBuiltIn: isBuiltIn,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'name': name,
        'categoryId': categoryId,
        'amount': amount,
        'isBuiltIn': isBuiltIn,
        'createdAt': createdAt,
      };

  factory BudgetCategoryModel.fromMap(Map<dynamic, dynamic> m) =>
      BudgetCategoryModel(
        id: m['id'] as String,
        userId: m['userId'] as String,
        name: m['name'] as String,
        categoryId: m['categoryId'] as String,
        amount: (m['amount'] as num).toDouble(),
        isBuiltIn: m['isBuiltIn'] as bool? ?? false,
        createdAt: m['createdAt'] as int,
      );
}
