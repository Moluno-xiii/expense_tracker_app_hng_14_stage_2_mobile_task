# Sovereign Ledger

A local-first Flutter expense tracker with Firebase authentication and facial-liveness access control. Built as the HNG 14 — Stage 2 Mobile deliverable.

Sovereign Ledger treats your money the way a real ledger would: a four-level hierarchy that separates high-level **categories** (e.g. Food) from **budget categories** you actually plan against (e.g. "September Groceries"), from **allocations** that live inside them, down to the individual **transactions** that move money. Every screen reacts to those boxes in real time.

---

## Highlights

- **Email + password sign-up** via Firebase Auth, with email verification enforced by the router.
- **Facial liveness gate** using `facial_liveness_verification` — blink / nod / turn challenges — before the app unlocks for a user. State is pinned per-UID in `flutter_secure_storage`.
- **Offline-first data layer** on Hive CE — categories, budget categories, allocations and transactions are persisted locally and streamed into every screen.
- **Four-level finance model** (Category → Budget Category → Allocation → Transaction) with cascade delete semantics: remove a budget category and every allocation and transaction underneath it goes with it — the balance re-derives naturally from Σincome − Σexpense.
- **Reactive UI** — `StreamBuilder` + `Box.watch()` everywhere, no pull-to-refresh needed.
- **Four-tab shell** (Overview / Budgets / Insights / Settings) backed by `go_router`'s `StatefulShellRoute.indexedStack`.
- **Material 3** with a seeded color scheme, `MyColors` `ThemeExtension` tokens, Manrope via `google_fonts`, and a live light/dark toggle.
- **Curated 13-category seed** (Food, Travel, Salary, Shopping, Home, Transportation, …) auto-planted on first sign-in, plus a built-in **Account** category whose Deposit / Withdrawal allocations power the balance bar.
- **Charts-ready Insights** screen built on `fl_chart` — velocity card, monthly overview, donut of spend share, smart-suggestion cards.

---

## Screens

### Auth / Enrollment

- Onboarding carousel (3 slides)
- Create Account
- Verify Email (Firebase verification link)
- Identity Verification (liveness capture)
- Verification Successful
- Log In (return-visit entry)

### Main shell

- **Overview** — balance card, spending-trend card, 10-allocation scroller, recent ledgers (10).
- **Budgets** — "Monthly Burn" card (live balance + limit + percent + left), a horizontal pill row of categories with a `+ New` tile, and a Budget Categories section with a blue **Add New Budget Category** CTA.
- **Insights** — performance analytics, daily/weekly/monthly toggle, velocity, monthly overview, total spent, allocation donut, smart suggestions.
- **Settings** — profile card, biometrics toggle, dark-mode switch, currency, language, recurring rules, categories, export, change password, sign out.

### Sub-routes

- Transactions list (Recent Ledgers), Add / Edit Transaction, Captured Data placeholder, Allocations list, New Allocation, Allocation detail, All Budget Categories, Categories list, New Category, Change Password, Currency picker, Profile, Export, Recurring rules list and editor.

---

## Data model

```
Category              ─ a high-level bucket (Food, Travel, Salary, …)
  └── BudgetCategory  ─ a budgeted instance of a category with an amount
        └── Allocation ─ a named slice inside a budget category
              └── Transaction ─ income / expense, sign comes from `type`
```

- **Category** is the seeded taxonomy. Built-in categories (Account) can't be removed.
- **BudgetCategory** is the first-class budgeting entity — a user may create multiple budget categories under one category (e.g. "Groceries — September" and "Groceries — Q4 bulk").
- **Allocation** attaches to exactly one budget category. The built-in Account budget category owns the auto-created **Deposit** and **Withdrawal** allocations the balance bar relies on.
- **Transaction** references an allocation. Income adds, expense subtracts. Balance is always recomputed as `Σincome − Σexpense`, so cascade deletes return money naturally with no bookkeeping.

Schema upgrades are handled by a tiny migration pass in `HiveService` keyed on `schema_version` in the settings box.

---

## Architecture

- **Feature-first layout** under `lib/features/<feature>/presentation/…`.
- **State management:** `ChangeNotifier` + `ListenableBuilder`, `ValueNotifier` for local widget state. No third-party state package.
- **Dependency injection:** three `InheritedNotifier` / `InheritedWidget` scopes — `AuthScope`, `LivenessScope`, `AppDataScope` — wrap the `MaterialApp.router`. Child widgets pull what they need via `Scope.of(context)`.
- **Routing:** `go_router` with a single central `refreshListenable: Listenable.merge([auth, liveness])`. `_authRedirect` decides whether to hold the splash, push to the onboarding flow, force email verification, force liveness, or land on `/`.
- **Persistence:** Hive CE boxes for categories, budget categories, allocations, transactions, settings. Each repo exposes `forUser(uid)` for sync reads plus a broadcast `Stream` on top of `Box.watch()`. `AppData.watchLedger(uid)` joins transactions → allocations → budget categories → categories into a single `LedgerEntry` stream.

---

## Tech stack

| Layer         | Package                                                                                 |
| ------------- | --------------------------------------------------------------------------------------- |
| Navigation    | `go_router: ^17.2.2`                                                                    |
| Auth          | `firebase_core: ^4.7.0`, `firebase_auth: ^6.4.0`                                        |
| Liveness      | `facial_liveness_verification: ^2.1.0` (wraps `camera` + `google_mlkit_face_detection`) |
| Local storage | `hive_ce: ^2.19.3`, `hive_ce_flutter: ^2.3.4`                                           |
| Secure flags  | `flutter_secure_storage: ^10.0.0`                                                       |
| Charts        | `fl_chart: ^1.2.0`                                                                      |
| Typography    | `google_fonts: ^8.0.2` (Manrope)                                                        |
| IDs           | `uuid: ^4.5.3`                                                                          |
| Dart SDK      | `^3.11.3`                                                                               |

---

## Project layout

```
lib/
  main.dart                              runApp(ExpenseTrackerApp())
  firebase_options.dart                  Firebase CLI output
  app/
    app.dart                             MaterialApp.router + scopes
    app_data.dart                        AppData + AppDataScope + seeding
    theme_controller.dart                light/dark toggle
    splash_screen.dart                   splash while controllers hydrate
  core/
    router/{app_router,routes}.dart
    theme/{app_theme,app_colors}.dart
    widgets/                             BentoCard, AmountField, TxRow, FabSpeedDial, …
    mock/mock_data.dart                  formatMoney + legacy mock helpers
  data/
    hive/hive_service.dart               boxes + schema migrations
    models/                              Category, BudgetCategory, Allocation, Transaction, LedgerEntry
    repositories/                        one repo per collection
    seed/default_categories.dart         13 seeded categories
  features/
    onboarding/
    auth/
      data/{auth_controller,liveness_controller,auth_exception}.dart
      enrollment/presentation/           create account, verify email, liveness, all set, login
    shell/presentation/main_shell.dart   4-tab NavigationBar
    transactions/presentation/           overview, transactions list, add/edit, captured data
    budgets/presentation/                budgets, category budgets, allocations list/detail/new, add-budget sheet
    categories/presentation/             categories list, new category
    analytics/presentation/              insights, velocity, donut, suggestions
    recurring/presentation/              rule list, edit rule
    settings/presentation/               settings, currency, profile, password, export
    export/presentation/
```

---

## Getting started

### Prerequisites

- Flutter SDK matching Dart `^3.11.3` (tested on Flutter stable).
- A configured Firebase project. `lib/firebase_options.dart` and `firebase.json` are already checked in — regenerate them with the FlutterFire CLI if you're targeting your own project:

  ```bash
  dart pub global activate flutterfire_cli
  flutterfire configure
  ```

- On Android the camera permission is already declared in `android/app/src/main/AndroidManifest.xml`; on iOS add an `NSCameraUsageDescription` entry to `ios/Runner/Info.plist` before building.

### Install and run

```bash
flutter pub get
flutter run
```

### Build a release APK

`IconData` instances are built from Hive-stored runtime codepoints, which Flutter's default tree-shaker rejects. Pass the opt-out flag:

```bash
flutter build apk --release --no-tree-shake-icons
```

### Run on appetize

[appetize link](https://appetize.io/app/b_vwfj3gjxweo3mma25w4snz2ogq)

---

## First-run flow

1. **Splash** — holds while `AuthController` restores the Firebase session and `LivenessController` reads its secure-storage flag.
2. **Onboarding** — 3 slides introducing the app.
3. **Create Account** — name, email, password → Firebase sign-up → email verification link sent.
4. **Verify Email** — tap the link, return to the app, poll refreshes the user until `emailVerified`.
5. **Identity Verification** — blink / nod / turn challenges. On success the liveness flag is stored in `flutter_secure_storage` keyed by UID, and the router lets you through.
6. **All Set** → Overview. 13 default categories plus the built-in Account category are seeded on first unlock, along with the Deposit / Withdrawal allocations that power the balance bar.

Subsequent cold starts skip onboarding and the enrollment flow — the router lands on Overview as long as auth + liveness are both green.

## Acknowledgements

- UI inspired by the [Expense tracker app (Community)](https://www.figma.com/design/LqD0C80AD9j4gdOa9uab60/Expense-tracker-app--Community-) Figma file, with additional screens (onboarding, recurring rules, export, currency picker, profile) designed to match the system.
- Liveness challenges powered by the [facial_liveness_verification](https://pub.dev/packages/facial_liveness_verification) package on top of Google ML Kit's face detection.
- Built for the **HNG 14 — Stage 2 Mobile** track.
