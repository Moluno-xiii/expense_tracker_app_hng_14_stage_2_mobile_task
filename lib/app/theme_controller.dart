import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

class ThemeController extends ChangeNotifier {
  ThemeController({Box<dynamic>? settingsBox}) : _settingsBox = settingsBox {
    final stored = _settingsBox?.get(_key);
    _isDark = stored == 'dark';
  }

  static const _key = 'theme_mode';
  final Box<dynamic>? _settingsBox;

  bool _isDark = false;

  bool get isDark => _isDark;
  ThemeMode get mode => _isDark ? ThemeMode.dark : ThemeMode.light;

  void setDark(bool value) {
    if (_isDark == value) return;
    _isDark = value;
    notifyListeners();
    unawaited(_settingsBox?.put(_key, value ? 'dark' : 'light'));
  }
}

class ThemeControllerScope extends InheritedNotifier<ThemeController> {
  const ThemeControllerScope({
    required ThemeController super.notifier,
    required super.child,
    super.key,
  });

  static ThemeController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ThemeControllerScope>();
    assert(scope != null, 'ThemeControllerScope not found in tree');
    return scope!.notifier!;
  }
}
