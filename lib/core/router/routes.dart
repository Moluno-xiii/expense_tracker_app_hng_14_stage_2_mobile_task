class Routes {
  const Routes._();

  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const enroll = '/enroll';
  static const enrollVerifyEmail = '/enroll/verify-email';
  static const enrollLiveness = '/enroll/liveness';
  static const enrollDone = '/enroll/done';

  static const login = '/login';

  static const gate = '/gate';
  static const gateVerify = '/gate/verify';

  static const overview = '/';
  static const transactions = '/transactions';
  static const transactionsNew = '/transactions/new';
  static const transactionsCaptured = '/transactions/captured';
  static const allocations = '/allocations';
  static const allocationsNew = '/allocations/new';

  static const budgets = '/budgets';
  static const budgetsCategories = '/budgets/categories';
  static const budgetsCategoriesNew = '/budgets/categories/new';
  static const budgetsList = '/budgets/list';
  static const budgetById = '/budgets/:id';

  static const insights = '/insights';

  static const settings = '/settings';
  static const settingsCurrency = '/settings/currency';
  static const settingsExport = '/settings/export';
  static const settingsProfile = '/settings/profile';
  static const settingsPassword = '/settings/password';
  static const settingsRecurring = '/settings/recurring';
  static const settingsRecurringNew = '/settings/recurring/new';
  static const settingsCategories = '/settings/categories';
}
