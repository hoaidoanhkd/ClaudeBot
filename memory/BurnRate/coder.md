
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
