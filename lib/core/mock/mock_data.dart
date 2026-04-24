import 'package:flutter/material.dart';

class MockCategory {
  const MockCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.spent,
    required this.limit,
  });

  final String id;
  final String name;
  final IconData icon;
  final double spent;
  final double limit;

  double get left => limit - spent;
  bool get overLimit => left < 0;
  double get progress => limit == 0 ? 0 : (spent / limit).clamp(0.0, 1.0);
}

class MockTransaction {
  const MockTransaction({
    required this.id,
    required this.title,
    required this.category,
    required this.time,
    required this.amount,
    required this.isIncome,
    required this.icon,
    required this.dateLabel,
  });

  final String id;
  final String title;
  final String category;
  final String time;
  final double amount;
  final bool isIncome;
  final IconData icon;
  final String dateLabel;
}

class MockData {
  static const balance = 42950.40;
  static const balanceDeltaPct = 12.5;

  static const allocations = <MockCategory>[
    MockCategory(
      id: 'transport',
      name: 'Transport',
      icon: Icons.directions_car_outlined,
      spent: 320,
      limit: 700,
    ),
    MockCategory(
      id: 'dining',
      name: 'Dining Out',
      icon: Icons.restaurant_outlined,
      spent: 485,
      limit: 500,
    ),
    MockCategory(
      id: 'groceries',
      name: 'Groceries',
      icon: Icons.shopping_basket_outlined,
      spent: 250,
      limit: 325,
    ),
    MockCategory(
      id: 'utilities',
      name: 'Utilities',
      icon: Icons.bolt_outlined,
      spent: 150,
      limit: 50,
    ),
    MockCategory(
      id: 'health',
      name: 'Health & Fitness',
      icon: Icons.fitness_center_outlined,
      spent: 120,
      limit: 150,
    ),
    MockCategory(
      id: 'clothing',
      name: 'Clothing',
      icon: Icons.checkroom_outlined,
      spent: 180,
      limit: 240,
    ),
    MockCategory(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie_outlined,
      spent: 200,
      limit: 300,
    ),
    MockCategory(
      id: 'transportation',
      name: 'Transportation',
      icon: Icons.directions_car_outlined,
      spent: 100,
      limit: 50,
    ),
  ];

  static const recent = <MockTransaction>[
    MockTransaction(
      id: '1',
      title: 'Apple Store',
      category: 'TECHNOLOGY',
      time: '2:45 PM',
      amount: 1299.00,
      isIncome: false,
      icon: Icons.shopping_bag_outlined,
      dateLabel: 'OCT 12',
    ),
    MockTransaction(
      id: '2',
      title: 'Dividend Payout',
      category: 'INVESTMENT',
      time: '11:20 AM',
      amount: 450.25,
      isIncome: true,
      icon: Icons.payments_outlined,
      dateLabel: 'OCT 11',
    ),
    MockTransaction(
      id: '3',
      title: 'The Gilded Fork',
      category: 'DINING',
      time: '8:15 PM',
      amount: 240.50,
      isIncome: false,
      icon: Icons.restaurant_outlined,
      dateLabel: 'OCT 10',
    ),
    MockTransaction(
      id: '4',
      title: 'Spotify Premium',
      category: 'SUBSCRIPTION',
      time: '9:00 AM',
      amount: 9.99,
      isIncome: false,
      icon: Icons.music_note_outlined,
      dateLabel: 'OCT 9',
    ),
    MockTransaction(
      id: '5',
      title: 'Electricity Bill',
      category: 'UTILITIES',
      time: '1:30 PM',
      amount: 75.80,
      isIncome: false,
      icon: Icons.bolt_outlined,
      dateLabel: 'OCT 8',
    ),
    MockTransaction(
      id: '6',
      title: 'Amazon Purchase',
      category: 'E-COMMERCE',
      time: '3:00 PM',
      amount: 59.99,
      isIncome: false,
      icon: Icons.shopping_cart_outlined,
      dateLabel: 'OCT 7',
    ),
    MockTransaction(
      id: '7',
      title: 'Gym Membership',
      category: 'HEALTH',
      time: '5:30 PM',
      amount: 45.00,
      isIncome: false,
      icon: Icons.fitness_center_outlined,
      dateLabel: 'OCT 6',
    ),
    MockTransaction(
      id: '8',
      title: 'Book Sale',
      category: 'ENTERTAINMENT',
      time: '12:15 PM',
      amount: 12.99,
      isIncome: true,
      icon: Icons.menu_book_outlined,
      dateLabel: 'OCT 5',
    ),
    MockTransaction(
      id: '9',
      title: 'Design Payment',
      category: 'PAYMENT',
      time: '2:45 PM',
      amount: 1299.00,
      isIncome: true,
      icon: Icons.palette_outlined,
      dateLabel: 'OCT 4',
    ),
    MockTransaction(
      id: '10',
      title: 'Netflix',
      category: 'SUBSCRIPTION',
      time: '2:45 PM',
      amount: 1299.00,
      isIncome: false,
      icon: Icons.movie_outlined,
      dateLabel: 'OCT 3',
    ),
  ];

  static const trendDays = <double>[
    120, 145, 95, 170, 190, 140, 210, 180, 155, 200,
    175, 195, 220, 240, 210,
  ];
}

String formatMoney(double v, {bool withSign = false, bool income = false}) {
  final abs = v.abs();
  final s = abs.toStringAsFixed(2);
  final parts = s.split('.');
  final whole = parts[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
  final body = '\$$whole.${parts[1]}';
  if (!withSign) return body;
  return '${income ? '+' : '-'}$body';
}
