import 'package:hive_ce/hive.dart';

import '../models/transaction_model.dart';

class TransactionRepository {
  TransactionRepository(this._box);

  final Box<dynamic> _box;

  List<TransactionModel> forUser(String uid) {
    final result = <TransactionModel>[];
    for (final v in _box.values) {
      if (v is Map) {
        final model = TransactionModel.fromMap(v);
        if (model.userId == uid) result.add(model);
      }
    }
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  List<TransactionModel> forAllocation({
    required String uid,
    required String allocationId,
  }) {
    return forUser(uid)
        .where((t) => t.allocationId == allocationId)
        .toList();
  }

  Stream<List<TransactionModel>> watchForUser(String uid) async* {
    yield forUser(uid);
    await for (final _ in _box.watch()) {
      yield forUser(uid);
    }
  }

  Stream<List<TransactionModel>> watchForAllocation({
    required String uid,
    required String allocationId,
  }) async* {
    List<TransactionModel> snapshot() =>
        forAllocation(uid: uid, allocationId: allocationId);
    yield snapshot();
    await for (final _ in _box.watch()) {
      yield snapshot();
    }
  }

  double balanceFor(String uid) {
    double balance = 0;
    for (final tx in forUser(uid)) {
      if (tx.isIncome) {
        balance += tx.amount;
      } else {
        balance -= tx.amount;
      }
    }
    return balance;
  }

  Stream<double> watchBalance(String uid) async* {
    yield balanceFor(uid);
    await for (final _ in _box.watch()) {
      yield balanceFor(uid);
    }
  }

  TransactionModel? byId(String id) {
    final v = _box.get(id);
    if (v is Map) return TransactionModel.fromMap(v);
    return null;
  }

  Future<void> add(TransactionModel t) => _box.put(t.id, t.toMap());

  Future<void> update(TransactionModel t) => _box.put(t.id, t.toMap());

  Future<void> delete(String id) => _box.delete(id);
}
