# Repo Map — BurnRate
Generated: 2026-03-31 06:15

## Overview
- swift: 74 files

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
BurnRateTests/BurnRateEngineTests.swift
BurnRateWidget/BurnRateWidget.swift
```

## Key Files (by size)
- BurnRate/Views/Screens/NetWorthView.swift (416 lines)
- BurnRate/Services/NotificationManager.swift (391 lines)
- BurnRate/Views/Screens/MonthlySummaryView.swift (364 lines)
- BurnRate/Views/Screens/CashFlowForecastView.swift (361 lines)
- BurnRate/Views/Screens/RecurringRulesView.swift (358 lines)
- BurnRate/Views/Screens/SavingsGoalDetailView.swift (308 lines)
- BurnRate/Views/Screens/SubscriptionDetectorView.swift (290 lines)
- BurnRate/Views/Screens/SettingsView.swift (290 lines)
- BurnRate/Views/Screens/DashboardView.swift (276 lines)
- BurnRate/Services/TransactionExporter.swift (259 lines)
- BurnRate/Views/Screens/SmartBudgetSuggestionsView.swift (238 lines)
- BurnRate/Services/TransactionService.swift (233 lines)
- BurnRate/Views/Screens/SavingsGoalsView.swift (232 lines)
- BurnRate/Views/Screens/OnboardingView.swift (228 lines)
- BurnRate/Views/Screens/DebtPayoffView.swift (221 lines)
- BurnRate/Views/Components/BudgetFormViews.swift (212 lines)
- BurnRate/Services/BurnRateEngine.swift (206 lines)
- BurnRate/Views/Sheets/AddSavingsGoalView.swift (203 lines)
- BurnRate/Views/Screens/HistoryView.swift (202 lines)
- BurnRateWidget/BurnRateWidget.swift (197 lines)

## Definitions (Swift)
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
### BurnRate/Models/Transaction.swift
  - 4:enum TransactionType: String, Codable {
  - 9:@Model
### BurnRate/Models/Account.swift
  - 4:@Model
### BurnRate/Models/CustomCategory.swift
  - 5:@Model
