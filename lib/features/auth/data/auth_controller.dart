import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

import 'auth_exception.dart';

class AuthController extends ChangeNotifier {
  AuthController({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance {
    _sub = _auth.authStateChanges().listen((u) {
      _user = u;
      _initialized = true;
      notifyListeners();
    });
  }

  final FirebaseAuth _auth;
  late final StreamSubscription<User?> _sub;

  User? _user;
  bool _busy = false;
  bool _initialized = false;
  String? _error;

  User? get user => _user;
  bool get busy => _busy;
  String? get error => _error;
  bool get isSignedIn => _user != null;
  bool get emailVerified => _user?.emailVerified ?? false;

  bool get initialized => _initialized;

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    return _run(() async {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final u = cred.user!;
      await u.updateDisplayName(fullName.trim());
      await u.sendEmailVerification();
      _user = u;
    });
  }

  Future<bool> signIn({required String email, required String password}) async {
    return _run(() async {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _user = cred.user;
    });
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<bool> resendVerificationEmail() async {
    return _run(() async {
      await _user?.sendEmailVerification();
    });
  }

  Future<bool> refreshUser() async {
    final u = _auth.currentUser;
    if (u == null) return false;
    await u.reload();
    _user = _auth.currentUser;
    notifyListeners();
    return _user?.emailVerified ?? false;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return _run(() async {
      final u = _auth.currentUser;
      final email = u?.email;
      if (u == null || email == null) {
        throw const AuthException('No signed-in user.');
      }
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await u.reauthenticateWithCredential(credential);
      await u.updatePassword(newPassword);
    });
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      _busy = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      _busy = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = AuthException.fromFirebase(e).message;
      _busy = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class AuthScope extends InheritedNotifier<AuthController> {
  const AuthScope({
    required AuthController super.notifier,
    required super.child,
    super.key,
  });

  static AuthController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope not found in tree');
    return scope!.notifier!;
  }
}
