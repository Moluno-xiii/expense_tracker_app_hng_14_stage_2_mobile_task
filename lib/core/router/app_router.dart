import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/splash_screen.dart';
import '../../features/analytics/presentation/insights_screen.dart';
import '../../features/auth/data/auth_controller.dart';
import '../../features/auth/data/liveness_controller.dart';
import '../../features/auth/enrollment/presentation/create_account_screen.dart';
import '../../features/auth/enrollment/presentation/identity_verification_screen.dart';
import '../../features/auth/enrollment/presentation/log_in_screen.dart';
import '../../features/auth/enrollment/presentation/verification_successful_screen.dart';
import '../../features/auth/enrollment/presentation/verify_email_screen.dart';
import '../../features/budgets/presentation/allocation_detail_screen.dart';
import '../../features/budgets/presentation/allocation_ledger_screen.dart';
import '../../features/budgets/presentation/allocations_screen.dart';
import '../../features/budgets/presentation/budgets_screen.dart';
import '../../features/budgets/presentation/category_budgets_screen.dart';
import '../../features/budgets/presentation/new_allocation_screen.dart';
import '../../features/categories/presentation/categories_list_screen.dart';
import '../../features/categories/presentation/new_category_screen.dart';
import '../../features/export/presentation/export_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/recurring/presentation/edit_rule_screen.dart';
import '../../features/recurring/presentation/recurring_list_screen.dart';
import '../../features/settings/presentation/change_password_screen.dart';
import '../../features/settings/presentation/currency_picker_screen.dart';
import '../../features/settings/presentation/profile_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/presentation/main_shell.dart';
import '../../features/transactions/presentation/add_transaction_screen.dart';
import '../../features/transactions/presentation/captured_data_screen.dart';
import '../../features/transactions/presentation/overview_screen.dart';
import '../../features/transactions/presentation/transactions_list_screen.dart';
import 'routes.dart';

final GlobalKey<NavigatorState> _rootKey = GlobalKey<NavigatorState>();

AddTxTab _parseTab(String? raw) {
  switch (raw) {
    case 'capture':
      return AddTxTab.capture;
    case 'upload':
      return AddTxTab.upload;
    default:
      return AddTxTab.manual;
  }
}

GoRouter buildAppRouter({
  required AuthController auth,
  required LivenessController liveness,
}) =>
    GoRouter(
      navigatorKey: _rootKey,
      initialLocation: Routes.splash,
      refreshListenable: Listenable.merge([auth, liveness]),
      redirect: (ctx, state) => _authRedirect(ctx, state, auth, liveness),
      routes: [
        GoRoute(
          path: Routes.splash,
          builder: (_, _) => const SplashScreen(),
        ),
        ..._authRoutes(),
        _shellRoute(),
      ],
    );

const _publicPaths = <String>{
  Routes.onboarding,
  Routes.enroll,
  Routes.login,
};

String? _authRedirect(
  BuildContext ctx,
  GoRouterState state,
  AuthController auth,
  LivenessController liveness,
) {
  final path = state.matchedLocation;

  // Hold on splash until both controllers have loaded their initial
  // state. Otherwise we'd flash `/enroll/liveness` on cold start while
  // Firebase is still restoring the user and secure storage is still
  // reading the liveness flag.
  if (!auth.initialized || liveness.isLoading) {
    return path == Routes.splash ? null : Routes.splash;
  }

  final signedIn = auth.isSignedIn;
  final emailVerified = auth.emailVerified;
  final livenessOk = liveness.isVerified;

  // Not signed in → keep them on auth screens.
  if (!signedIn) {
    if (_publicPaths.contains(path)) return null;
    return Routes.onboarding;
  }

  // Signed in but email not verified → force verify-email.
  if (!emailVerified) {
    if (path == Routes.enrollVerifyEmail) return null;
    return Routes.enrollVerifyEmail;
  }

  // Email verified but liveness not done → force liveness.
  if (!livenessOk) {
    if (path == Routes.enrollLiveness) return null;
    return Routes.enrollLiveness;
  }

  // Fully authenticated: keep them away from pre-auth screens and the
  // now-stale splash route.
  // `/enroll/done` is intentionally allowed — it's the success landing.
  if (_publicPaths.contains(path) ||
      path == Routes.splash ||
      path == Routes.enrollVerifyEmail ||
      path == Routes.enrollLiveness) {
    return Routes.overview;
  }

  return null;
}

List<RouteBase> _authRoutes() => [
      GoRoute(
        path: Routes.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.enroll,
        builder: (_, _) => const CreateAccountScreen(),
        routes: [
          GoRoute(
            path: 'verify-email',
            builder: (_, _) => const VerifyEmailScreen(),
          ),
          GoRoute(
            path: 'liveness',
            builder: (_, _) => const IdentityVerificationScreen(),
          ),
          GoRoute(
            path: 'done',
            builder: (_, _) => const VerificationSuccessfulScreen(),
          ),
        ],
      ),
      GoRoute(
        path: Routes.login,
        builder: (_, _) => const LogInScreen(),
      ),
    ];

StatefulShellRoute _shellRoute() => StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => MainShell(navigationShell: shell),
      branches: [
        _overviewBranch(),
        _budgetsBranch(),
        _insightsBranch(),
        _settingsBranch(),
      ],
    );

StatefulShellBranch _overviewBranch() => StatefulShellBranch(
      routes: [
        GoRoute(
          path: Routes.overview,
          builder: (_, _) => const OverviewScreen(),
          routes: [
            GoRoute(
              path: 'transactions',
              builder: (_, _) => const TransactionsListScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (_, s) {
                    final tab = s.uri.queryParameters['tab'];
                    return AddTransactionScreen(
                      initialTab: _parseTab(tab),
                    );
                  },
                ),
                GoRoute(
                  path: 'captured',
                  builder: (_, _) => const CapturedDataScreen(),
                ),
              ],
            ),
            GoRoute(
              path: 'allocations',
              builder: (_, _) => const AllocationsScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (_, _) => const NewAllocationScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (_, s) => AllocationDetailScreen(
                    allocationId: s.pathParameters['id'] ?? '',
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );

StatefulShellBranch _budgetsBranch() => StatefulShellBranch(
      routes: [
        GoRoute(
          path: Routes.budgets,
          builder: (_, _) => const BudgetsScreen(),
          routes: [
            GoRoute(
              path: 'list',
              builder: (_, _) => const CategoryBudgetsScreen(),
            ),
            GoRoute(
              path: 'categories',
              builder: (_, _) => const CategoriesListScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (_, _) => const NewCategoryScreen(),
                ),
              ],
            ),
            GoRoute(
              path: ':id',
              builder: (_, s) => AllocationLedgerScreen(
                categoryId: s.pathParameters['id'] ?? '',
              ),
            ),
          ],
        ),
      ],
    );

StatefulShellBranch _insightsBranch() => StatefulShellBranch(
      routes: [
        GoRoute(
          path: Routes.insights,
          builder: (_, _) => const InsightsScreen(),
        ),
      ],
    );

StatefulShellBranch _settingsBranch() => StatefulShellBranch(
      routes: [
        GoRoute(
          path: Routes.settings,
          builder: (_, _) => const SettingsScreen(),
          routes: [
            GoRoute(
              path: 'currency',
              builder: (_, _) => const CurrencyPickerScreen(),
            ),
            GoRoute(
              path: 'export',
              builder: (_, _) => const ExportScreen(),
            ),
            GoRoute(
              path: 'profile',
              builder: (_, _) => const ProfileScreen(),
            ),
            GoRoute(
              path: 'password',
              builder: (_, _) => const ChangePasswordScreen(),
            ),
            GoRoute(
              path: 'recurring',
              builder: (_, _) => const RecurringListScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (_, _) => const EditRuleScreen(),
                ),
              ],
            ),
            GoRoute(
              path: 'categories',
              builder: (_, _) => const CategoriesListScreen(),
            ),
          ],
        ),
      ],
    );
