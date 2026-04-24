import 'package:flutter/material.dart';

import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../data/hive/hive_service.dart';
import '../features/auth/data/auth_controller.dart';
import '../features/auth/data/liveness_controller.dart';
import 'app_data.dart';
import 'theme_controller.dart';

class ExpenseTrackerApp extends StatefulWidget {
  const ExpenseTrackerApp({super.key});

  @override
  State<ExpenseTrackerApp> createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {
  late final _auth = AuthController();
  late final _liveness = LivenessController(auth: _auth);
  late final _appData =
      AppData(hive: HiveService.instance, auth: _auth);
  late final _router = buildAppRouter(auth: _auth, liveness: _liveness);
  late final _theme = ThemeController(
    settingsBox: HiveService.instance.settings,
  );

  @override
  void dispose() {
    _theme.dispose();
    _appData.dispose();
    _liveness.dispose();
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      notifier: _auth,
      child: LivenessScope(
        notifier: _liveness,
        child: AppDataScope(
          data: _appData,
          child: ThemeControllerScope(
            notifier: _theme,
            child: ListenableBuilder(
              listenable: _theme,
              builder: (_, _) => MaterialApp.router(
                title: 'Sovereign Ledger',
                debugShowCheckedModeBanner: false,
                theme: buildLightTheme(),
                darkTheme: buildDarkTheme(),
                themeMode: _theme.mode,
                routerConfig: _router,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
