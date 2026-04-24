import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_controller.dart';

class LivenessController extends ChangeNotifier {
  LivenessController({
    required AuthController auth,
    FlutterSecureStorage? storage,
  })  : _auth = auth,
        _storage = storage ?? const FlutterSecureStorage() {
    _auth.addListener(_onAuth);
    _syncForUid(_auth.user?.uid);
  }

  static const _keyPrefix = 'liveness_verified_';

  final AuthController _auth;
  final FlutterSecureStorage _storage;

  bool _verified = false;
  bool _loading = true;
  String? _uidInFlag;

  bool get isVerified => _verified;
  bool get isLoading => _loading;

  String _key(String uid) => '$_keyPrefix$uid';

  Future<void> _onAuth() async {
    final uid = _auth.user?.uid;
    if (uid == null && _uidInFlag != null) {
      await _storage.delete(key: _key(_uidInFlag!));
      _verified = false;
      _loading = false;
      _uidInFlag = null;
      notifyListeners();
      return;
    }
    await _syncForUid(uid);
  }

  Future<void> _syncForUid(String? uid) async {
    if (uid == null) {
      _verified = false;
      _loading = false;
      _uidInFlag = null;
      notifyListeners();
      return;
    }
    if (_uidInFlag == uid && !_loading) return;
    _loading = true;
    notifyListeners();
    final v = await _storage.read(key: _key(uid));
    _verified = v == 'true';
    _uidInFlag = uid;
    _loading = false;
    notifyListeners();
  }

  Future<void> markVerified() async {
    final uid = _auth.user?.uid;
    if (uid == null) return;
    await _storage.write(key: _key(uid), value: 'true');
    _verified = true;
    _uidInFlag = uid;
    notifyListeners();
  }

  Future<void> clearForCurrentUser() async {
    final uid = _auth.user?.uid ?? _uidInFlag;
    if (uid != null) {
      await _storage.delete(key: _key(uid));
    }
    _verified = false;
    _uidInFlag = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuth);
    super.dispose();
  }
}

class LivenessScope extends InheritedNotifier<LivenessController> {
  const LivenessScope({
    required LivenessController super.notifier,
    required super.child,
    super.key,
  });

  static LivenessController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<LivenessScope>();
    assert(scope != null, 'LivenessScope not found in tree');
    return scope!.notifier!;
  }
}
