import 'package:hive_ce/hive.dart';

import '../models/allocation_model.dart';

class AllocationRepository {
  AllocationRepository(this._box);

  final Box<dynamic> _box;

  List<AllocationModel> forUser(String uid) {
    final result = <AllocationModel>[];
    for (final v in _box.values) {
      if (v is Map) {
        final model = AllocationModel.fromMap(v);
        if (model.userId == uid) result.add(model);
      }
    }
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  Stream<List<AllocationModel>> watchForUser(String uid) async* {
    yield forUser(uid);
    await for (final _ in _box.watch()) {
      yield forUser(uid);
    }
  }

  AllocationModel? byId(String id) {
    final v = _box.get(id);
    if (v is Map) return AllocationModel.fromMap(v);
    return null;
  }

  Future<void> add(AllocationModel a) => _box.put(a.id, a.toMap());

  Future<void> update(AllocationModel a) => _box.put(a.id, a.toMap());

  Future<void> delete(String id) => _box.delete(id);
}
