import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import '../data/hive/hive_service.dart';
import '../data/models/allocation_model.dart';
import '../data/models/budget_category_model.dart';
import '../data/models/category_model.dart';
import '../data/models/ledger_entry.dart';
import '../data/repositories/allocation_repository.dart';
import '../data/repositories/budget_category_repository.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/transaction_repository.dart';
import '../data/seed/default_categories.dart';
import '../features/auth/data/auth_controller.dart';

class AppData {
  AppData({required HiveService hive, required this.auth})
    : _hive = hive,
      categories = CategoryRepository(hive.categories),
      budgetCategories = BudgetCategoryRepository(hive.budgetCategories),
      allocations = AllocationRepository(hive.allocations),
      transactions = TransactionRepository(hive.transactions) {
    auth.addListener(_onAuthChange);
    _onAuthChange();
  }

  final HiveService _hive;
  final AuthController auth;
  final CategoryRepository categories;
  final BudgetCategoryRepository budgetCategories;
  final AllocationRepository allocations;
  final TransactionRepository transactions;

  final _uuid = const Uuid();
  String? _seededForUid;
  bool _seeding = false;

  void _onAuthChange() {
    final uid = auth.user?.uid;
    if (uid == null) return;
    if (_seededForUid == uid || _seeding) return;
    unawaited(_ensureSeeded(uid));
  }

  Future<void> _ensureSeeded(String uid) async {
    _seeding = true;
    try {
      final key = 'bootstrapped_$uid';
      if (_hive.settings.get(key) != true) {
        await _seedDefaultCategories(uid);
        await _hive.settings.put(key, true);
      }
      await _ensureBuiltInAccount(uid);
      _seededForUid = uid;
    } finally {
      _seeding = false;
    }
  }

  Future<void> _seedDefaultCategories(String uid) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final seed in defaultCategorySeeds) {
      await categories.add(
        CategoryModel(
          id: _uuid.v4(),
          userId: uid,
          name: seed.name,
          iconCodePoint: seed.icon.codePoint,
          colorValue: seed.color.toARGB32(),
          isBuiltIn: seed.isBuiltIn,
          isIncome: seed.isIncome,
          createdAt: now,
        ),
      );
    }
  }

  Future<void> _ensureBuiltInAccount(String uid) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    var account = categories
        .forUser(uid)
        .where((c) => c.isBuiltIn && c.name == accountCategoryName)
        .firstOrNull;
    if (account == null) {
      account = CategoryModel(
        id: _uuid.v4(),
        userId: uid,
        name: accountCategoryName,
        iconCodePoint: 0xe84f,
        colorValue: 0xFF0B1C30,
        isBuiltIn: true,
        createdAt: now,
      );
      await categories.add(account);
    }
    var accountBc = budgetCategories
        .forUser(uid)
        .where((b) => b.isBuiltIn && b.categoryId == account!.id)
        .firstOrNull;
    if (accountBc == null) {
      accountBc = BudgetCategoryModel(
        id: _uuid.v4(),
        userId: uid,
        name: accountCategoryName,
        categoryId: account.id,
        amount: 0,
        isBuiltIn: true,
        createdAt: now,
      );
      await budgetCategories.add(accountBc);
    }
    final existingBuiltIns = allocations.forUser(uid).where((a) => a.isBuiltIn);
    final hasDeposit = existingBuiltIns.any(
      (a) => a.name == depositAllocationName,
    );
    final hasWithdrawal = existingBuiltIns.any(
      (a) => a.name == withdrawalAllocationName,
    );
    if (!hasDeposit) {
      await allocations.add(
        AllocationModel(
          id: _uuid.v4(),
          userId: uid,
          budgetCategoryId: accountBc.id,
          name: depositAllocationName,
          isBuiltIn: true,
          createdAt: now,
        ),
      );
    }
    if (!hasWithdrawal) {
      await allocations.add(
        AllocationModel(
          id: _uuid.v4(),
          userId: uid,
          budgetCategoryId: accountBc.id,
          name: withdrawalAllocationName,
          isBuiltIn: true,
          createdAt: now,
        ),
      );
    }
  }

  Future<AllocationModel?> depositAllocation() =>
      _builtInAllocation(depositAllocationName);

  Future<AllocationModel?> withdrawalAllocation() =>
      _builtInAllocation(withdrawalAllocationName);

  Future<AllocationModel?> _builtInAllocation(String name) async {
    final uid = auth.user?.uid;
    if (uid == null) return null;
    for (final a in allocations.forUser(uid)) {
      if (a.isBuiltIn && a.name == name) return a;
    }
    await _ensureBuiltInAccount(uid);
    for (final a in allocations.forUser(uid)) {
      if (a.isBuiltIn && a.name == name) return a;
    }
    return null;
  }

  double balanceFor(String uid) {
    double sum = 0;
    for (final t in transactions.forUser(uid)) {
      if (t.isIncome) {
        sum += t.amount;
      } else {
        sum -= t.amount;
      }
    }
    return sum;
  }

  Stream<double> watchBalance(String uid) {
    late StreamSubscription<dynamic> sub;
    final ctrl = StreamController<double>.broadcast();
    ctrl.onListen = () {
      ctrl.add(balanceFor(uid));
      sub = _hive.transactions.watch().listen((_) => ctrl.add(balanceFor(uid)));
    };
    ctrl.onCancel = () async {
      await sub.cancel();
    };
    return ctrl.stream;
  }

  List<LedgerEntry> ledgerFor(String uid) {
    final catMap = {for (final c in categories.forUser(uid)) c.id: c};
    final bcMap = {for (final b in budgetCategories.forUser(uid)) b.id: b};
    final allocMap = {for (final a in allocations.forUser(uid)) a.id: a};
    final entries = <LedgerEntry>[];
    for (final t in transactions.forUser(uid)) {
      final alloc = allocMap[t.allocationId];
      if (alloc == null) continue;
      final bc = bcMap[alloc.budgetCategoryId];
      if (bc == null) continue;
      final cat = catMap[bc.categoryId];
      if (cat == null) continue;
      entries.add(LedgerEntry.fromTransaction(t, alloc, cat));
    }
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  Stream<List<LedgerEntry>> watchLedger(String uid) {
    late StreamSubscription<dynamic> tSub;
    late StreamSubscription<dynamic> aSub;
    late StreamSubscription<dynamic> bSub;
    late StreamSubscription<dynamic> cSub;
    final ctrl = StreamController<List<LedgerEntry>>.broadcast();
    ctrl.onListen = () {
      ctrl.add(ledgerFor(uid));
      tSub = _hive.transactions.watch().listen((_) => ctrl.add(ledgerFor(uid)));
      aSub = _hive.allocations.watch().listen((_) => ctrl.add(ledgerFor(uid)));
      bSub = _hive.budgetCategories.watch().listen(
        (_) => ctrl.add(ledgerFor(uid)),
      );
      cSub = _hive.categories.watch().listen((_) => ctrl.add(ledgerFor(uid)));
    };
    ctrl.onCancel = () async {
      await tSub.cancel();
      await aSub.cancel();
      await bSub.cancel();
      await cSub.cancel();
    };
    return ctrl.stream;
  }

  Future<void> removeBudgetCategoryCascading(BudgetCategoryModel bc) async {
    if (bc.isBuiltIn) return;
    final uid = bc.userId;
    final allocs = allocations
        .forUser(uid)
        .where((a) => a.budgetCategoryId == bc.id)
        .toList();
    for (final a in allocs) {
      final txs = transactions.forAllocation(uid: uid, allocationId: a.id);
      for (final t in txs) {
        await transactions.delete(t.id);
      }
      await allocations.delete(a.id);
    }
    await budgetCategories.delete(bc.id);
  }

  String newId() => _uuid.v4();

  void dispose() {
    auth.removeListener(_onAuthChange);
  }
}

class AppDataScope extends InheritedWidget {
  const AppDataScope({required this.data, required super.child, super.key});

  final AppData data;

  static AppData of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppDataScope>();
    assert(scope != null, 'AppDataScope not found in tree');
    return scope!.data;
  }

  @override
  bool updateShouldNotify(covariant AppDataScope oldWidget) =>
      data != oldWidget.data;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
