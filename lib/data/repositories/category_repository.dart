import 'package:hive_ce/hive.dart';

import '../models/category_model.dart';

class CategoryRepository {
  CategoryRepository(this._box);

  final Box<dynamic> _box;

  List<CategoryModel> forUser(String uid) {
    final result = <CategoryModel>[];
    for (final v in _box.values) {
      if (v is Map) {
        final model = CategoryModel.fromMap(v);
        if (model.userId == uid) result.add(model);
      }
    }
    result.sort((a, b) => a.name.compareTo(b.name));
    return result;
  }

  Stream<List<CategoryModel>> watchForUser(String uid) async* {
    yield forUser(uid);
    await for (final _ in _box.watch()) {
      yield forUser(uid);
    }
  }

  CategoryModel? byId(String id) {
    final v = _box.get(id);
    if (v is Map) return CategoryModel.fromMap(v);
    return null;
  }

  Future<void> add(CategoryModel c) => _box.put(c.id, c.toMap());

  Future<void> update(CategoryModel c) => _box.put(c.id, c.toMap());

  Future<void> delete(String id) => _box.delete(id);
}
