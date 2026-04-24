import 'package:hive_ce/hive.dart';

import '../models/budget_category_model.dart';

class BudgetCategoryRepository {
  BudgetCategoryRepository(this._box);

  final Box<dynamic> _box;

  List<BudgetCategoryModel> forUser(String uid) {
    final result = <BudgetCategoryModel>[];
    for (final v in _box.values) {
      if (v is Map) {
        final model = BudgetCategoryModel.fromMap(v);
        if (model.userId == uid) result.add(model);
      }
    }
    result.sort((a, b) => a.name.compareTo(b.name));
    return result;
  }

  Stream<List<BudgetCategoryModel>> watchForUser(String uid) async* {
    yield forUser(uid);
    await for (final _ in _box.watch()) {
      yield forUser(uid);
    }
  }

  BudgetCategoryModel? byId(String id) {
    final v = _box.get(id);
    if (v is Map) return BudgetCategoryModel.fromMap(v);
    return null;
  }

  Future<void> add(BudgetCategoryModel b) => _box.put(b.id, b.toMap());

  Future<void> update(BudgetCategoryModel b) => _box.put(b.id, b.toMap());

  Future<void> delete(String id) => _box.delete(id);
}
