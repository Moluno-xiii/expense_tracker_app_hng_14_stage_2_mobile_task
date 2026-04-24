import 'package:flutter/material.dart';

class CategorySeed {
  const CategorySeed({
    required this.name,
    required this.icon,
    required this.color,
    this.isBuiltIn = false,
    this.isIncome = false,
  });

  final String name;
  final IconData icon;
  final Color color;
  final bool isBuiltIn;
  final bool isIncome;
}

const String accountCategoryName = 'Account';

const String depositAllocationName = 'Deposit';
const String withdrawalAllocationName = 'Withdrawal';

final List<CategorySeed> defaultCategorySeeds = <CategorySeed>[
  const CategorySeed(
    name: 'Food',
    icon: Icons.restaurant_outlined,
    color: Color(0xFFF59E0B),
  ),
  const CategorySeed(
    name: 'Travel',
    icon: Icons.flight_outlined,
    color: Color(0xFF0EA5E9),
  ),
  const CategorySeed(
    name: 'Salary',
    icon: Icons.work_outline,
    color: Color(0xFF10B981),
    isIncome: true,
  ),
  const CategorySeed(
    name: 'Shopping',
    icon: Icons.shopping_bag_outlined,
    color: Color(0xFFEC4899),
  ),
  const CategorySeed(
    name: 'Home',
    icon: Icons.home_outlined,
    color: Color(0xFF6366F1),
  ),
  const CategorySeed(
    name: 'Transportation',
    icon: Icons.directions_car_outlined,
    color: Color(0xFF3B82F6),
  ),
  const CategorySeed(
    name: 'Entertainment',
    icon: Icons.movie_outlined,
    color: Color(0xFF8B5CF6),
  ),
  const CategorySeed(
    name: 'Clothing',
    icon: Icons.checkroom_outlined,
    color: Color(0xFFF472B6),
  ),
  const CategorySeed(
    name: 'Health & Fitness',
    icon: Icons.fitness_center_outlined,
    color: Color(0xFFEF4444),
  ),
  const CategorySeed(
    name: 'Utilities',
    icon: Icons.bolt_outlined,
    color: Color(0xFFFACC15),
  ),
  const CategorySeed(
    name: 'Groceries',
    icon: Icons.shopping_basket_outlined,
    color: Color(0xFF22C55E),
  ),
  const CategorySeed(
    name: 'Dining Out',
    icon: Icons.wine_bar_outlined,
    color: Color(0xFFDC2626),
  ),
  const CategorySeed(
    name: accountCategoryName,
    icon: Icons.account_balance_outlined,
    color: Color(0xFF0B1C30),
    isBuiltIn: true,
  ),
];
