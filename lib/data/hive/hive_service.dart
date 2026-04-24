import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class HiveService {
  HiveService._();

  static final HiveService instance = HiveService._();

  static const _categoriesBox = 'categories';
  static const _budgetCategoriesBox = 'budget_categories';
  static const _allocationsBox = 'allocations';
  static const _transactionsBox = 'transactions';
  static const _settingsBox = 'settings';

  static const _schemaVersion = 2;

  bool _ready = false;

  late Box<dynamic> categories;
  late Box<dynamic> budgetCategories;
  late Box<dynamic> allocations;
  late Box<dynamic> transactions;
  late Box<dynamic> settings;

  Future<void> init() async {
    if (_ready) return;
    await Hive.initFlutter();
    categories = await Hive.openBox<dynamic>(_categoriesBox);
    budgetCategories = await Hive.openBox<dynamic>(_budgetCategoriesBox);
    allocations = await Hive.openBox<dynamic>(_allocationsBox);
    transactions = await Hive.openBox<dynamic>(_transactionsBox);
    settings = await Hive.openBox<dynamic>(_settingsBox);
    await _applyMigrations();
    _ready = true;
  }

  Future<void> _applyMigrations() async {
    final stored = settings.get('schema_version') as int? ?? 1;
    if (stored >= _schemaVersion) return;
    await allocations.clear();
    await transactions.clear();
    await budgetCategories.clear();
    final bootstrapKeys = settings.keys
        .whereType<String>()
        .where((k) => k.startsWith('bootstrapped_'))
        .toList();
    for (final k in bootstrapKeys) {
      await settings.delete(k);
    }
    await settings.put('schema_version', _schemaVersion);
  }
}
