# Repo Map — BurnRate
Generated: 2026-04-01 05:10

## Overview
- swift: 99 files

## File Tree
```
BurnRate/App/BurnRateApp.swift
BurnRate/App/ContentView.swift
BurnRate/Extensions/Color+Hex.swift
BurnRate/Extensions/Date+Extensions.swift
BurnRate/Extensions/Decimal+Extensions.swift
BurnRate/Models/Account.swift
BurnRate/Models/Budget.swift
BurnRate/Models/Category.swift
BurnRate/Models/CustomCategory.swift
BurnRate/Models/RecurringRule.swift
BurnRate/Models/SavingsGoal.swift
BurnRate/Models/Transaction.swift
BurnRate/Services/BiometricAuthManager.swift
BurnRate/Services/BurnRateEngine.swift
BurnRate/Services/CashFlowForecastEngine.swift
BurnRate/Services/NotificationManager.swift
BurnRate/Services/NotificationManager+BudgetAlerts.swift
BurnRate/Services/NotificationManager+RunwayAlerts.swift
BurnRate/Services/NotificationManager+Scheduling.swift
BurnRate/Services/RecurringTransactionService.swift
BurnRate/Services/SavingsGoalService.swift
BurnRate/Services/SmartBudgetSuggestionEngine.swift
BurnRate/Services/SubscriptionDetectorEngine.swift
BurnRate/Services/TransactionExporter.swift
BurnRate/Services/TransactionService.swift
BurnRate/Services/WidgetDataStore.swift
BurnRate/ViewModels/BudgetViewModel.swift
BurnRate/ViewModels/DashboardViewModel.swift
BurnRate/ViewModels/HistoryViewModel.swift
BurnRate/ViewModels/MonthlySummaryViewModel.swift
BurnRate/ViewModels/TransactionViewModel.swift
BurnRateTests/BudgetStatusTests.swift
BurnRateTests/BudgetSuggestionTests.swift
BurnRateTests/BurnRateEngineTests.swift
BurnRateTests/CashFlowForecastEngineTests.swift
BurnRateTests/DashboardViewModelTests.swift
BurnRateTests/HistoryViewModelTests.swift
BurnRateTests/MonthlySummaryViewModelTests.swift
BurnRateTests/RecurringFrequencyTests.swift
BurnRateTests/SavingsGoalTests.swift
BurnRateTests/SubscriptionDetectorEngineTests.swift
BurnRateTests/TransactionServiceTests.swift
BurnRateTests/TransactionViewModelTests.swift
BurnRateWidget/BurnRateWidget.swift
```

## Key Files (by size)
- BurnRate/Views/Screens/SubscriptionDetectorView.swift (290 lines)
- BurnRate/Views/Screens/SettingsView.swift (290 lines)
- BurnRate/Views/Screens/DashboardView.swift (277 lines)
- BurnRate/Services/TransactionExporter.swift (259 lines)
- BurnRate/Views/Screens/SmartBudgetSuggestionsView.swift (241 lines)
- BurnRate/Services/TransactionService.swift (233 lines)
- BurnRate/Views/Screens/SavingsGoalsView.swift (232 lines)
- BurnRate/Views/Components/MonthlySummarySectionViews.swift (230 lines)
- BurnRate/Views/Screens/OnboardingView.swift (228 lines)
- BurnRateTests/HistoryViewModelTests.swift (224 lines)
- BurnRate/Views/Screens/DebtPayoffView.swift (221 lines)
- BurnRate/Views/Components/BudgetFormViews.swift (212 lines)
- BurnRateTests/SubscriptionDetectorEngineTests.swift (207 lines)
- BurnRate/Services/BurnRateEngine.swift (206 lines)
- BurnRate/Views/Screens/HistoryView.swift (204 lines)
- BurnRate/Views/Sheets/AddSavingsGoalView.swift (203 lines)
- BurnRateWidget/BurnRateWidget.swift (197 lines)
- BurnRate/Views/Components/SkeletonView.swift (189 lines)
- BurnRateTests/CashFlowForecastEngineTests.swift (188 lines)
- BurnRateTests/BurnRateEngineTests.swift (187 lines)

## Definitions (Swift)
### BurnRateTests/DashboardViewModelTests.swift
  - 9:    func test_runwayColor_greenWhenOver60Days() {
  - 15:    func test_runwayColor_greenWhenExactly61Days() {
  - 21:    func test_runwayColor_yellowWhenBetween31And60() {
  - 27:    func test_runwayColor_yellowWhenExactly60() {
  - 33:    func test_runwayColor_orangeWhenBetween15And30() {
  - 39:    func test_runwayColor_orangeWhenExactly30() {
  - 45:    func test_runwayColor_redWhenUnder15() {
  - 51:    func test_runwayColor_redWhenExactly14() {
  - 57:    func test_runwayColor_redWhenZero() {
  - 65:    func test_runwayProgress_normalCase() {
### BurnRateTests/SavingsGoalTests.swift
  - 8:    func test_progress_normalCase() {
  - 13:    func test_progress_zeroTarget_returnsZero() {
  - 18:    func test_progress_zeroSaved_returnsZero() {
  - 23:    func test_progress_complete_returnsOne() {
  - 28:    func test_progress_overFunded_cappedAtOne() {
  - 33:    func test_progress_smallAmounts() {
  - 40:    func test_percentComplete_halfWay() {
  - 45:    func test_percentComplete_zero() {
  - 50:    func test_percentComplete_full() {
  - 55:    func test_percentComplete_roundsCorrectly() {
### BurnRateTests/RecurringFrequencyTests.swift
  - 21:    func test_daily_advancesOneDay() {
  - 29:    func test_daily_crossesMonthBoundary() {
  - 39:    func test_weekly_advances7Days() {
  - 48:    func test_biweekly_advances14Days() {
  - 57:    func test_monthly_advancesOneMonth() {
  - 65:    func test_monthly_handlesEndOfMonth() {
  - 75:    func test_monthly_crossesYearBoundary() {
  - 85:    func test_yearly_advancesOneYear() {
  - 94:    func test_yearly_leapDayHandling() {
  - 106:    func test_displayName_allCases() {
### BurnRateTests/BudgetStatusTests.swift
  - 19:    func test_remaining_normalCase() {
  - 24:    func test_remaining_overBudget_returnsZero() {
  - 29:    func test_remaining_exactlyAtLimit() {
  - 34:    func test_remaining_nothingSpent() {
  - 41:    func test_percentage_normalCase() {
  - 46:    func test_percentage_zeroLimit_returnsZero() {
  - 51:    func test_percentage_overBudget_cappedAt2() {
  - 56:    func test_percentage_nothingSpent_returnsZero() {
  - 61:    func test_percentage_exactlyAtLimit() {
  - 68:    func test_statusLabel_overBudget() {
### BurnRateTests/CashFlowForecastEngineTests.swift
  - 27:    func test_forecast_noRules_balanceStaysFlat() {
  - 38:    func test_forecast_includesDay0AsTodayWithStartingBalance() {
  - 48:    func test_forecast_milestoneAt30Days() {
  - 60:    func test_forecast_milestoneAt60And90Days() {
  - 72:    func test_forecast_dailyExpenseReducesBalance() {
  - 84:    func test_forecast_incomeRuleIncreasesBalance() {
  - 95:    func test_forecast_inactiveRulesIgnored() {
  - 109:    func test_milestoneSummaries_returnsThreeMilestones() {
  - 120:    func test_milestoneSummaries_noRules_balanceUnchanged() {
  - 133:    func test_milestoneSummaries_isNegativeWhenBalanceDropsBelowZero() {
### BurnRateTests/TransactionViewModelTests.swift
  - 8:    func test_amount_validDecimal_parsesCorrectly() {
  - 14:    func test_amount_emptyString_returnsNil() {
  - 20:    func test_amount_invalidString_returnsNil() {
  - 26:    func test_amount_wholeNumber_parsesCorrectly() {
  - 34:    func test_isValid_validAmount_returnsTrue() {
  - 40:    func test_isValid_zeroAmount_returnsFalse() {
  - 46:    func test_isValid_negativeAmount_returnsFalse() {
  - 52:    func test_isValid_emptyAmount_returnsFalse() {
  - 58:    func test_isValid_invalidText_returnsFalse() {
  - 66:    func test_isEditing_initiallyFalse() {
### BurnRateTests/SubscriptionDetectorEngineTests.swift
  - 24:    func test_detect_monthlySubscription_twoOccurrences() {
  - 37:    func test_detect_monthlySubscription_threeOccurrences() {
  - 49:    func test_detect_multipleSubscriptions_sortedByMonthlyCost() {
  - 65:    func test_detect_weeklySubscription() {
  - 78:    func test_detect_yearlySubscription() {
  - 92:    func test_detect_ignoresIncomeTransactions() {
  - 101:    func test_detect_requiresAtLeastTwoOccurrences() {
  - 109:    func test_detect_inconsistentAmounts_notDetected() {
  - 118:    func test_detect_irregularIntervals_notDetected() {
  - 128:    func test_detect_emptyTransactions_returnsEmpty() {
### BurnRateTests/MonthlySummaryViewModelTests.swift
  - 20:    func test_refresh_noTransactions_returns6EmptyMonths() {
  - 28:    func test_refresh_withTransactions_returns6Months() {
  - 39:    func test_refresh_selectedMonthIndex_defaultsToLastMonth() {
  - 47:    func test_currentMonth_isSelectedMonth() {
  - 53:    func test_currentMonth_nil_whenNoData() {
  - 60:    func test_previousMonth_nil_whenFirstMonthSelected() {
  - 67:    func test_previousMonth_exists_whenLaterMonthSelected() {
  - 79:    func test_expenseDelta_nil_whenNoPreviousMonth() {
  - 86:    func test_expenseDelta_nil_whenPreviousExpensesZero() {
  - 97:    func test_expenseDelta_positive_whenCurrentHigherThanPrevious() {
### BurnRateTests/BudgetSuggestionTests.swift
  - 8:    func test_roundedAmount_roundsUpToNearest10() {
  - 13:    func test_roundedAmount_alreadyRound() {
  - 18:    func test_roundedAmount_justOverRound() {
  - 23:    func test_roundedAmount_smallAmount() {
  - 28:    func test_roundedAmount_largeAmount() {
  - 33:    func test_roundedAmount_zeroAmount() {
  - 40:    func test_budgetAlert_hasUniqueId() {
  - 46:    func test_budgetAlert_overLimit() {
  - 53:    func test_budgetAlert_warningRange() {
  - 61:    func test_transaction_signedAmount_expense_isNegative() {
### BurnRateTests/BurnRateEngineTests.swift
  - 20:    func test_dailyBurnRate_noTransactions_returnsZero() {
  - 25:    func test_dailyBurnRate_onlyIncome_returnsZero() {
  - 31:    func test_dailyBurnRate_singleExpense_calculatesCorrectly() {
  - 38:    func test_dailyBurnRate_multipleExpenses_sumsCorrectly() {
  - 50:    func test_dailyBurnRate_ignoresExpensesOutsideWindow() {
  - 59:    func test_dailyBurnRate_ignoresIncomeTransactions() {
  - 69:    func test_runway_zeroBurnRate_returns999() {
  - 74:    func test_runway_zeroBalance_returnsZero() {
  - 79:    func test_runway_negativeBalance_returnsZero() {
  - 84:    func test_runway_normalCase_calculatesCorrectly() {
### BurnRateTests/TransactionServiceTests.swift
  - 8:    func test_adjustBalance_addExpense_subtractsFromAccount() {
  - 14:    func test_adjustBalance_removeExpense_addsBackToAccount() {
  - 22:    func test_adjustBalance_addIncome_addsToAccount() {
  - 28:    func test_adjustBalance_removeIncome_subtractsFromAccount() {
  - 36:    func test_adjustBalance_nilAccount_noOp() {
  - 44:    func test_adjustBalance_zeroAmount_noChange() {
  - 52:    func test_adjustBalance_largeExpense_canGoNegative() {
  - 60:    func test_adjustBalance_multipleOperations_correctBalance() {
  - 71:    func test_adjustBalance_decimalPrecision() {
### BurnRateTests/HistoryViewModelTests.swift
  - 27:    func test_updateTransactions_setsFilteredTransactions() {
  - 33:    func test_updateTransactions_emptyList() {
  - 39:    func test_updateTransactions_computesAvailableCategories() {
  - 53:    func test_typeFilter_expense_onlyShowsExpenses() {
  - 65:    func test_typeFilter_income_onlyShowsIncome() {
  - 76:    func test_typeFilter_all_showsEverything() {
  - 88:    func test_categoryFilter_filtersByCategory() {
  - 100:    func test_categoryFilter_nil_showsAll() {
  - 112:    func test_dateFilter_fromDate_excludesOlderTransactions() {
  - 123:    func test_dateFilter_toDate_excludesFutureTransactions() {
### BurnRateWidget/BurnRateWidget.swift
  - 69:struct RunwayEntry: TimelineEntry {
  - 78:struct RunwayWidgetProvider: TimelineProvider {
  - 79:    func placeholder(in context: Context) -> RunwayEntry {
  - 83:    func getSnapshot(in context: Context, completion: @escaping (RunwayEntry) -> Void) {
  - 87:    func getTimeline(in context: Context, completion: @escaping (Timeline<RunwayEntry>) -> Void) {
  - 106:struct RunwayWidgetView: View {
  - 180:struct BurnRateWidgetBundle: WidgetBundle {
  - 186:struct RunwayWidget: Widget {
### BurnRate/ViewModels/BudgetViewModel.swift
  - 6:struct BudgetStatus: Identifiable {
  - 35:struct BudgetAlert: Identifiable {
  - 42:@Observable
  - 48:    func refresh(budgets: [Budget], context: ModelContext) {
### BurnRate/ViewModels/HistoryViewModel.swift
  - 4:@Observable
  - 50:    func updateTransactions(_ transactions: [Transaction]) {
  - 57:    func clearFilters() {
### BurnRate/ViewModels/TransactionViewModel.swift
  - 5:@Observable
  - 38:    func load(from transaction: Transaction) {
  - 47:    func save(context: ModelContext, account: Account) {
  - 63:    func update(context: ModelContext) {
  - 78:    func reset() {
### BurnRate/ViewModels/MonthlySummaryViewModel.swift
  - 4:@Observable
  - 38:    func refresh(transactions: [Transaction]) {
### BurnRate/ViewModels/DashboardViewModel.swift
  - 5:@Observable
  - 24:    func processRecurringRules(rules: [RecurringRule], modelContext: ModelContext) {
  - 34:    func scheduleRefresh(accounts: [Account], transactions: [Transaction], context: ModelContext) {
  - 45:    func pullToRefresh(accounts: [Account], transactions: [Transaction], rules: [RecurringRule], budgets: [Budget], modelContext: ModelContext) async {
  - 55:    func setBudgets(_ budgets: [Budget]) {
### BurnRate/App/BurnRateApp.swift
  - 5:struct BurnRateApp: App {
### BurnRate/App/ContentView.swift
  - 4:struct ContentView: View {
### BurnRate/Models/RecurringRule.swift
  - 4:enum RecurringFrequency: String, Codable, CaseIterable {
  - 32:    func nextDate(after date: Date) -> Date {
  - 49:@Model
### BurnRate/Models/SavingsGoal.swift
  - 4:@Model
### BurnRate/Models/Category.swift
  - 4:struct AppCategory: Identifiable, Hashable {
### BurnRate/Models/Budget.swift
  - 4:@Model
  - 26:    func displayName(custom: [AppCategory] = []) -> String {
  - 34:    func icon(custom: [AppCategory] = []) -> String {
  - 42:    func colorHex(custom: [AppCategory] = []) -> String {
### BurnRate/Models/Transaction.swift
  - 4:enum TransactionType: String, Codable {
  - 9:@Model
### BurnRate/Models/Account.swift
  - 4:@Model
### BurnRate/Models/CustomCategory.swift
  - 5:@Model
