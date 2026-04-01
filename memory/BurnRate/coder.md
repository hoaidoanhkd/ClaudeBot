
## 2026-04-01 — Service Layer Consolidation (#123)
- Approach: Created 3 new services (BudgetService, RecurringRuleService, CategoryService) following existing TransactionService/SavingsGoalService pattern. Moved CRUD from BudgetViewModel + Views into services. Kept ViewModel CRUD methods as thin delegates for backward compatibility.
- Files: 3 new service files, modified BudgetViewModel, CategoryFormViews, CategoryManagementView, RecurringRulesView, AddRecurringRuleView
- Tricky parts: Deciding what to keep in Views vs move to services. OnboardingView and EditBalanceView kept direct saves as they're simple single-property operations. BudgetViewModel kept wrapper methods to avoid breaking existing call sites.
- Lesson: When consolidating a service layer, keep thin delegation wrappers in existing call sites rather than updating all callers at once — reduces diff size and risk. Upgrade `try?` to `do/try/catch` with `#if DEBUG` logging during the migration.

## 2026-04-01 — Multi-currency Display Support (#120)
- Approach: Added `currency` field to Account model, `Decimal.formatted(currencyCode:)` extension, currency picker in EditBalanceView, updated display in SettingsView + NetWorthAccountViews
- Files: Account.swift, Decimal+Extensions.swift, EditBalanceView.swift, SettingsView.swift, NetWorthAccountViews.swift
- Tricky parts: `Locale.currencySymbol` is optional, `.map(\.currencySymbol)` returns `String?` not `String` — needed `.flatMap`. Also iterating all Locale.availableIdentifiers is expensive — added cache.
- Lesson: When mapping optional keypath on optional result from `.first(where:)`, use `.flatMap` not `.map` to avoid double-optional. Cache locale lookups when used in UI that re-renders frequently.

## 2026-03-30 — Fix BurnRateEngine.runway() Decimal Division Bug
- Approach: NSDecimalNumber.intValue returns 0 for repeating decimals (333.333…). Switched to .doubleValue → Int() truncation.
- Files: BurnRate/Services/BurnRateEngine.swift (1 line change)
- Tricky parts: None — root cause was clear once identified. NSDecimalNumber.intValue is a known Foundation bug for repeating decimals.
- Lesson: Never use NSDecimalNumber.intValue for Decimal→Int conversion. Always go through .doubleValue first, then Int(). Add this to the quality checklist.

## 2026-03-30 — Spending Pace Alerts + Ghost Bill Fix
- Approach: Cherry-picked bill reminders from feat/bill-reminders, added ghost fix + pace alerts on top
- Files: NotificationManager.swift, SettingsView.swift, DashboardView.swift
- Tricky parts: Ghost fix uses getPendingNotificationRequests async callback to find all burnrate.bill.* IDs. Pace formula: spendingRatio > expectedPace * 1.2 with dayOfMonth >= 5 guard.
- Lesson: Cherry-picking works well when building on unremerged PRs. Always clear-all-then-reschedule pattern prevents ghost notifications.

## 2026-03-30 — Net Worth Tracker
- Approach: New NetWorthView with summary card, account breakdown, 6-month trend chart via transaction history walkback
- Files: NetWorthView.swift (new), DashboardView.swift, project.pbxproj
- Tricky parts: Adding files to Xcode project.pbxproj programmatically — first attempt corrupted the file (plutil failed). Fixed by using line-by-line insertion after anchor lines instead of regex replacement.
- Lesson: When adding new Swift files to .xcodeproj, use line-insertion approach (append after known anchor line), not regex replace. Always validate with `plutil -lint` before building. Always restore from git if corrupted.

## 2026-03-30 — Debt Payoff Calculator + Net Worth Trend Fix
- Approach: DebtPayoffView with snowball/avalanche strategies, payment inputs, timeline. Fixed #158 net worth trend bias.
- Files: DebtPayoffView.swift (new), NetWorthView.swift (fix + nav link), project.pbxproj
- Tricky parts: Payoff schedule calculation with minimum payments rolling to next debt. Net worth trend fix required careful ordering: record current snapshot, then undo current month txns, then walk backwards.
- Lesson: Historical balance reconstruction must undo transactions in correct order. Always start with live balance, then undo current partial month first.

## 2026-03-30 — Subscription Detector + Snowball Fix
- Approach: Engine groups expenses by normalized note, checks amount ±5% and interval consistency. View with cost summary + dismiss.
- Files: SubscriptionDetectorEngine.swift (new), SubscriptionDetectorView.swift (new), SettingsView.swift, DebtPayoffView.swift
- Tricky parts: Set.insert() returns tuple, not Void — `withAnimation { set.insert(x) }` won't compile; must use `_ = set.insert(x)`.
- Lesson: SwiftUI's withAnimation closure expects Void return. Always discard results of Set/Dictionary mutations inside withAnimation blocks.

## 2026-03-30 — DashboardView Refactor
- Approach: Extracted 4 sub-views (BalanceCard, NavigationCards, BudgetSummary, RecentTransactions) into Components/
- Files: DashboardView.swift (620→259 LOC), 4 new component files, project.pbxproj
- Tricky parts: Navigation cards deduped with shared navCard() helper. Kept chart sections inline since they're thin viewModel wrappers. Undo helper stays in Dashboard (tightly coupled).
- Lesson: Use closures for actions, let for read-only data in extracted sub-views. Keep notification/onChange wiring in the orchestrator.

## 2026-03-30 — SwiftData #Predicate Optimization (#124)
- Approach: Replaced in-memory .filter {} on @Query results with #Predicate macros across 8 files. Split single queries into multiple filtered queries (expense/income, active/inactive).
- Files: CategoryManagementView, AddTransactionView, BudgetListView, RecurringRulesView, DebtPayoffView, SavingsGoalsView, TransactionService, BudgetViewModel
- Tricky parts: Transaction.type (enum) cannot be used in #Predicate — SwiftData crashes with enum rawValue. SavingsGoal.isComplete is computed, so used underlying expression (currentAmount >= targetAmount) in predicate. When splitting @Query, must update ALL references to old variable name.
- Lesson: SwiftData #Predicate works well with stored String/Bool/Decimal properties but NOT with enum types. When splitting a single @Query into multiple filtered queries, grep ALL usages of the old variable name — easy to miss .onChange, .isEmpty checks, and function arguments.

## 2026-03-30 — Pull-to-refresh + Skeleton Loading (#122)
- Approach: Created reusable SkeletonView.swift with shimmer modifier + placeholder components. Added .refreshable to HistoryView, BudgetListView, SavingsGoalsView. Added isLoading state with .task sleep for skeleton-to-content transition.
- Files: SkeletonView.swift (new), DashboardView, HistoryView, BudgetListView, SavingsGoalsView, project.pbxproj
- Tricky parts: SwiftData @Query auto-refreshes on pull-to-refresh without explicit reload — just need brief sleep for UX. Skeleton needs if/else wrapping around existing content blocks.
- Lesson: For SwiftData views, .refreshable just needs a brief delay — the @Query properties auto-update. Use .task { sleep + withAnimation } for skeleton-to-content transitions. Keep skeleton components reusable and under 200 LOC.

## 2026-03-30 — Weekly Recap Notification (#138 #140)
- Approach: Fixed weeklyRecapEnabled default to false. Enhanced notification with category breakdown (top spend, count). Changed schedule to Sunday 8PM.
- Files: NotificationManager.swift, DashboardView.swift, SettingsView.swift
- Tricky parts: Passing category data through — used tuple array (name: String, amount: Decimal) to avoid coupling NotificationManager to CategorySpend model. Pre-compute body before scheduling.
- Lesson: For notifications with dynamic content, pre-compute the body string as value types, then schedule. Keep the notification manager decoupled from view models using simple tuple/struct parameters.

## 2026-03-30 — Refactor CategoryManagementView (496→119 LOC)
- Approach: Extracted 3 sub-view files: CategoryPickerComponents (shared icon/color pickers), CategorySectionView (section + empty state), CategoryFormViews (Add + Edit sheets). Deduplicated ~120 LOC of icon/color picker code.
- Files: CategoryManagementView.swift (rewritten), 3 new component files, project.pbxproj
- Tricky parts: AddCategoryView and EditCategoryView had identical icon/color picker grids — extracted to shared components with @Binding. Kept delete/transaction reassignment logic in orchestrator.
- Lesson: When Add and Edit forms share identical sub-views (pickers, grids), extract as shared component with @Binding. This deduplication is the biggest LOC win in refactors.

## 2026-03-31 — Refactor BudgetListView (462→110 LOC)
- Approach: Extracted 3 sub-view files: BudgetRowView (active + inactive rows), BudgetSectionView (sections + empty state + suggestions banner), BudgetFormViews (Add + Edit sheets). Added #Preview blocks to all new files.
- Files: BudgetListView.swift (rewritten), 3 new component files, project.pbxproj
- Tricky parts: Swipe actions (edit/pause/delete) need closures from orchestrator to keep SwiftData mutations centralized. InactiveBudgetsSection onResume closure passes Budget back to orchestrator.
- Lesson: Always add #Preview blocks to new component files (reviewer feedback from PR #171). For sections with swipe actions, pass individual action closures rather than a single "action" enum to keep the API clear.

## 2026-03-31 — Fix Double Shimmer + Custom Category Names (#168 #170)
- Approach: Removed top-level .shimmer() from DashboardSkeleton, added per-element shimmer to raw placeholders. Added @Query CustomCategory to DashboardView, used AppCategory.find(_:custom:) for recap.
- Files: SkeletonView.swift, DashboardView.swift
- Tricky parts: Balance card skeleton uses raw RoundedRectangles (no built-in shimmer) — needed individual .shimmer() after removing parent-level one.
- Lesson: When composing skeleton views, apply .shimmer() at leaf level only. When using AppCategory.find(), always check if custom categories are needed — the no-arg version only searches built-in categories.

## 2026-03-31 — Refactor DebtPayoffView 459→221 LOC
- Approach: Extracted 3 component files: DebtPayoffTypes (enum, struct, helpers), DebtRowView (row+progress bar), DebtPayoffSectionViews (4 section views). Kept payment input in orchestrator (needs @State bindings).
- Files: DebtPayoffView.swift (refactored), DebtPayoffTypes.swift (new), DebtRowView.swift (new), DebtPayoffSectionViews.swift (new), project.pbxproj
- Tricky parts: Private `abs()` helper renamed to `debtAbs()` to avoid stdlib conflict when made internal. #Preview with multi-line setup needs explicit `return` for type inference. Committed to main by mistake — used `git branch -f` + `git reset --hard` to move commit to feature branch.
- Lesson: Always verify `git branch` before committing. When creating feature branch, immediately switch to it before making changes. Private helpers renamed to internal need unique names to avoid stdlib clashes.

## 2026-03-31 — Pull-to-refresh on SettingsView
- Approach: Added .refreshable with 300ms delay, matching existing pattern in 4 other views
- Files: SettingsView.swift (4 lines added)
- Tricky parts: None — straightforward addition. iPhone 16 Pro simulator not available, used iPhone 17 Pro.
- Lesson: Check available simulator names before building. Project now uses iOS 26.2 simulators (iPhone 17 series).

## 2026-03-31 — Refactor NetWorthView 416→168 LOC
- Approach: Extracted 3 component files: NetWorthSummaryCard, NetWorthAccountViews (4 views), NetWorthTrendChart + NetWorthSnapshot type. Removed custom abs() (stdlib works for Decimal).
- Files: NetWorthView.swift (refactored), NetWorthSummaryCard.swift (new), NetWorthAccountViews.swift (new), NetWorthTrendChart.swift (new), project.pbxproj
- Tricky parts: Committed to main AGAIN — must always verify git branch before committing. #Preview with container.mainContext.insert() needs explicit `return` before the View expression. Missing `import SwiftData` in files using ModelConfiguration in previews.
- Lesson: ALWAYS run `git branch` before committing to verify on feature branch. For #Preview with multi-line setup (let + insert), always use explicit `return` before the View. Always add `import SwiftData` when previews use ModelConfiguration/ModelContainer.

## 2026-03-31 — Refactor MonthlySummaryView 364→67 LOC
- Approach: Extracted 2 files: ChartViews (spending+category charts, chart mode enum) and SectionViews (empty state, month selector, delta section, comparison table). Build passed first try.
- Files: MonthlySummaryView.swift (refactored), MonthlySummaryChartViews.swift (new), MonthlySummarySectionViews.swift (new), project.pbxproj
- Tricky parts: None — clean extraction. Remembered to verify branch before committing this time.
- Lesson: When a view has charts + non-chart sections, split into ChartViews + SectionViews files. Nested enums (like ChartMode) must be extracted to standalone when used across files.

## 2026-03-31 — Fix AppCategory.find() missing custom: parameter (#179)
- Approach: Swept entire codebase for AppCategory.find() without custom: parameter. Fixed 19 files: views, services, models. Converted Budget computed properties to methods with default param. Threaded customCategories from parent @Query views down through component hierarchy.
- Files: 19 files modified across Models, Services, ViewModels, Components, Screens
- Tricky parts: Budget.swift had computed properties (displayName, icon, colorHex) that needed conversion to methods — cascaded to 18+ callers. Used `= []` default parameter to avoid breaking callsites that don't have custom categories.
- Lesson: When fixing a pattern bug (missing parameter), always do a codebase-wide sweep. Use `var customCategories: [AppCategory] = []` as default on child views for backward compatibility. Converting computed properties to methods with defaults is the cleanest way to add parameters to model properties.

## 2026-03-31 — Add unit tests for ViewModels and Services
- Approach: Created 6 new test files covering CashFlowForecastEngine, MonthlySummaryViewModel, HistoryViewModel, TransactionViewModel, BudgetStatus, RecurringFrequency, and AppCategory. 102 new tests, 126 total.
- Files: 6 new test files in BurnRateTests/, updated project.pbxproj and BurnRate.xcscheme
- Tricky parts: (1) BurnRate scheme had empty TestAction — had to add BurnRateTests testable reference. (2) Test target missing GENERATE_INFOPLIST_FILE=YES in build settings. (3) MonthlySummaryViewModel.refresh() returns 6 months even with empty transactions — test assumption was wrong initially.
- Lesson: Always check that the scheme's TestAction includes the test target. Test target needs GENERATE_INFOPLIST_FILE=YES. BurnRateEngine.monthlyAggregates generates calendar-based months regardless of transaction count. Focus tests on pure-logic code (engines, ViewModels with no DB dependency) for highest value without SwiftData setup complexity.

## 2026-04-01 — Refactor CashFlowForecastView 361→106 LOC
- Approach: Split into CashFlowForecastChartView (chart + helpers) and CashFlowForecastSectionViews (empty state, warning banner, milestones). Used @ChartContentBuilder for chart mark extraction.
- Files: CashFlowForecastView.swift (refactored), CashFlowForecastChartView.swift (new), CashFlowForecastSectionViews.swift (new), project.pbxproj
- Tricky parts: None — clean extraction. Chart components extracted using @ChartContentBuilder private computed properties.
- Lesson: @ChartContentBuilder works great for decomposing large Chart bodies into named components. Keep chart helpers (gradients, formatters, minBalance) co-located with the chart view.

## 2026-04-01 — Add 83 unit tests (126→209 total)
- Approach: Identified untested pure-logic code: SubscriptionDetectorEngine, DashboardViewModel computed properties, TransactionService.adjustBalance, SavingsGoal model, BudgetSuggestion. Wrote tests without SwiftData.
- Files: 5 new test files in BurnRateTests/, updated project.pbxproj
- Tricky parts: DashboardViewModelTests needed `import SwiftUI` for Color comparison. Build failed first time without it.
- Lesson: When testing SwiftUI ViewModel with Color properties, must import SwiftUI in the test file. Focus on pure-logic testable code first — SubscriptionDetectorEngine.detect(from:) and TransactionService.adjustBalance are ideal because they take plain objects, no ModelContext needed.

## 2026-04-01 — Refactor NotificationManager 392→63 LOC
- Approach: Split using Swift extensions into 4 files by concern: core, runway alerts, budget alerts, scheduling
- Files: NotificationManager.swift (modified), +RunwayAlerts.swift, +BudgetAlerts.swift, +Scheduling.swift (new), project.pbxproj
- Tricky parts: Had to change private → internal for properties/enum accessed by extensions. Added isNotificationsEnabled convenience property.
- Lesson: For service classes (not views), Swift extensions in separate files are the cleanest split pattern. No #Preview needed. Must open up private access for cross-file extensions.

## 2026-04-01 — Refactor RecurringRulesView 353→133 LOC
- Approach: Extracted RecurringRuleRow (pure display), RecurringRuleSectionViews (empty state with onAdd closure), AddRecurringRuleView (self-contained form). Kept mutations in orchestrator.
- Files: RecurringRulesView.swift (modified), RecurringRuleRow.swift, RecurringRuleSectionViews.swift, AddRecurringRuleView.swift (new), project.pbxproj
- Tricky parts: Preview macros with multi-statement setup need `import SwiftData` and `return` keyword before the view. First build failed due to missing SwiftData import in extracted file.
- Lesson: Always add `import SwiftData` when extracting views that use ModelConfiguration/ModelContainer in #Preview. The `return` keyword is required in multi-statement #Preview blocks.

## 2026-04-01 — Refactor SavingsGoalDetailView
- Approach: Split 308 LOC into orchestrator (147) + SavingsGoalProgressView (133) + SavingsGoalDetailSections (154, contains 3 sub-views)
- Files: SavingsGoalDetailView.swift, SavingsGoalProgressView.swift, SavingsGoalDetailSections.swift
- Tricky parts: Account lookup needed a computed property (linkedAccount) in orchestrator since sub-views don't have @Query
- Lesson: When sub-view needs data from @Query, resolve it in orchestrator and pass as let. Group related small sections (actions, details, danger) into one file with multiple structs rather than 3 separate files.

## 2026-04-01 — Empty code blocks cleanup + verify issues #118 #121
- Approach: Searched all .swift files for empty catch blocks, empty functions, no-op stubs. Found 4 silent catch blocks swallowing errors. Added #if DEBUG print logging. Verified HistoryView (204 LOC) and CategoryManagementView (119 LOC) exist.
- Files: TransactionExporter.swift, NotificationManager.swift, BiometricAuthManager.swift
- Tricky parts: Most "empty blocks" were actually valid patterns (preview closures, protocol stubs, @unknown default:break). Real issues were silent error swallowing.
- Lesson: For "empty block cleanup" tasks, focus on silent catch blocks that swallow errors — preview closures with {} are normal. Use python3 script to analyze AST-like patterns when grep isn't specific enough.

## 2026-04-01 — Siri & Apple Shortcuts Integration
- Approach: Created 4 files in BurnRate/Intents/ using AppIntents framework. 3 read-only intents + AppShortcutsProvider.
- Files: BurnRateShortcuts.swift, CheckBudgetIntent.swift, GetSpendingIntent.swift, GetRunwayIntent.swift, project.pbxproj
- Tricky parts: AppShortcut phrases with `\(\.$param)` syntax require the parameter to be AppEnum or AppEntity type — plain String won't work. Had to remove parameterized phrase and use static phrases instead.
- Lesson: For AppIntents with dynamic/user-created categories, avoid `\(\.$param)` in AppShortcut phrases unless you define an AppEnum. String parameters work fine for the intent itself but NOT for Siri phrase interpolation.

## 2026-04-01 — Home Screen Widgets Expansion (Budget + Savings Goal)
- Approach: Widgets were already scaffolded from prior commit. Added .systemMedium support to SavingsGoalWidget (was missing — only had .systemSmall). Added deadline + remaining fields to SavingsWidgetItem for richer medium layout.
- Files: BurnRateWidget/SavingsGoalWidget.swift, BurnRate/Services/WidgetDataStore.swift
- Tricky parts: The widgets were already partially built but SavingsGoalWidget was missing medium size. Had to add new fields (deadline, remaining) to both the widget-side and app-side Codable models to keep them in sync.
- Lesson: When expanding widgets, always check both widget target AND main app WidgetDataStore models are in sync. Also verify all widget sizes listed in requirements match .supportedFamilies().

## 2026-04-01 — Spending Insights Summary Card (Monarch-style)
- Approach: Created SpendingInsightsEngine (on-device, DB queries for current + previous month), SpendingInsightsCard (dashboard component), wired into DashboardViewModel + DashboardView. Added 10 unit tests.
- Files: SpendingInsightsEngine.swift, SpendingInsightsCard.swift, DashboardViewModel.swift, DashboardView.swift, SpendingInsightsEngineTests.swift, project.pbxproj
- Tricky parts: xcodegen regenerated project.pbxproj and wiped signing + scheme config. Had to restore original pbxproj and use Ruby xcodeproj gem to add files properly. Don't use xcodegen on this project — it loses custom settings.
- Lesson: NEVER use xcodegen to add files to this project — it resets signing and scheme configs. Use Ruby xcodeproj gem instead: `require 'xcodeproj'; project.targets.find{}.source_build_phase.add_file_reference(group.new_file('name.swift'))`. Also when engine needs ModelContext, test the pure computation helpers separately.

## 2026-04-01 — Planned/Upcoming Expenses (#193)
- Approach: Created PlannedExpense model, service, views (list + forms), integrated with CashFlowForecastEngine
- Files: PlannedExpense.swift, PlannedExpenseService.swift, PlannedExpensesView.swift, PlannedExpenseFormViews.swift, CashFlowForecastEngine.swift, CashFlowForecastView.swift, SettingsView.swift
- Tricky parts: CashFlowForecastEngine integration needed two helpers (applyPlannedExpenses for daily impacts, accumulatePlannedExpenses for milestones). Default parameters maintain backward compatibility.
- Lesson: Use default parameters (plannedExpenses: [PlannedExpense] = []) when extending existing engine functions to avoid breaking existing callers.

## 2026-04-01 — Unit Tests for New Services
- Approach: Wrote 47 unit tests for BudgetService, CategoryService, RecurringRuleService, PlannedExpenseService using @MainActor + in-memory ModelContainer
- Files: BurnRateTests/{BudgetServiceTests,CategoryServiceTests,RecurringRuleServiceTests,PlannedExpenseServiceTests}.swift, project.pbxproj
- Tricky parts: pbxproj registration (4 sections: PBXBuildFile, PBXFileReference, PBXGroup, Sources build phase). One unused variable warning caught on build.
- Lesson: Always use `_ =` for discardable results in tests where the object is only needed for side effects. Total test count went from 219→266.

## 2026-04-01 — CashFlowForecastEngine Unit Tests
- Approach: Extended existing test file with 13 new tests covering planned expenses integration and edge cases
- Files: BurnRateTests/CashFlowForecastEngineTests.swift (modified, 189→413 LOC)
- Tricky parts: Off-by-one in forecast engine — dailyImpacts[i] is applied at dayOffset=i+1 (points[i+1]). Initial test assertions assumed same-day application. Required 3 assertion fixes after first test run.
- Lesson: Always verify timing/indexing behavior of the engine before writing exact-value assertions. The engine's impact array is 0-indexed but applied starting at dayOffset=1.
