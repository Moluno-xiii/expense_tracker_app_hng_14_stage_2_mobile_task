class AllocationModel {
  const AllocationModel({
    required this.id,
    required this.userId,
    required this.budgetCategoryId,
    required this.name,
    required this.createdAt,
    this.amount,
    this.notes,
    this.isBuiltIn = false,
  });

  final String id;
  final String userId;
  final String budgetCategoryId;
  final String name;
  final double? amount;
  final String? notes;
  final bool isBuiltIn;
  final int createdAt;

  DateTime get createdDateTime =>
      DateTime.fromMillisecondsSinceEpoch(createdAt);

  AllocationModel copyWith({
    String? budgetCategoryId,
    String? name,
    double? amount,
    String? notes,
    bool clearAmount = false,
    bool clearNotes = false,
  }) {
    return AllocationModel(
      id: id,
      userId: userId,
      budgetCategoryId: budgetCategoryId ?? this.budgetCategoryId,
      name: name ?? this.name,
      amount: clearAmount ? null : (amount ?? this.amount),
      notes: clearNotes ? null : (notes ?? this.notes),
      isBuiltIn: isBuiltIn,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'budgetCategoryId': budgetCategoryId,
        'name': name,
        'amount': amount,
        'notes': notes,
        'isBuiltIn': isBuiltIn,
        'createdAt': createdAt,
      };

  factory AllocationModel.fromMap(Map<dynamic, dynamic> m) => AllocationModel(
        id: m['id'] as String,
        userId: m['userId'] as String,
        budgetCategoryId: m['budgetCategoryId'] as String,
        name: m['name'] as String? ?? '',
        amount: (m['amount'] as num?)?.toDouble(),
        notes: m['notes'] as String?,
        isBuiltIn: m['isBuiltIn'] as bool? ?? false,
        createdAt: m['createdAt'] as int,
      );
}
