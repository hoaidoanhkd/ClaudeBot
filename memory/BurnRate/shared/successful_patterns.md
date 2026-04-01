
## Service Layer Consolidation — 2026-04-01
- Pattern: Static-method service struct per model type. CRUD + queries in service, presentation logic in ViewModel. Thin delegation wrappers for backward compatibility.
- Key code: `struct BudgetService { static func create(..., context: ModelContext) -> Budget }` — same pattern as TransactionService
- Files: BudgetService.swift, RecurringRuleService.swift, CategoryService.swift

## Per-entity Currency Formatting — 2026-04-01
- Pattern: Add currency field to model, helper method on model for formatting, Decimal extension with currencyCode parameter. Cache expensive locale lookups.
- Key code: `func formatted(currencyCode: String) -> String` + `CurrencySymbolCache` for symbol lookup
- Files: Account.swift, Decimal+Extensions.swift

## Notification Feature — 2026-03-30
- Pattern: For scheduled notifications that get rescheduled, always clear ALL pending with matching prefix before adding new ones (prevents ghosts from deleted entities)
- Key code: `center.getPendingNotificationRequests { requests in let ghostIds = requests.filter { $0.identifier.hasPrefix("burnrate.bill.") }.map(\.identifier); center.removePendingNotificationRequests(withIdentifiers: ghostIds) }`
- Files: NotificationManager.swift

## AppStorage JSON-encoded Set<String> — 2026-03-30
- Pattern: Persist a `Set<String>` via @AppStorage by JSON-encoding to String
- Key code: `@AppStorage("key") var json: String = "[]"` + computed var decodes + mutating func encodes back
- Files: SubscriptionDetectorView.swift (PR #163)

## SwiftUI Sub-view Extract: let + closure pattern — 2026-03-30
- Pattern: When extracting sub-views from a large view, pass state as `let` value types and mutations as `() -> Void` closures. Never pass viewModel/EnvironmentObject to sub-views unless truly needed.
- Key: mutations stay in parent, passed down as closures — sub-views are pure display
- Files: DashboardBalanceCard, DashboardRecentTransactions (PR #164)

## SwiftData #Predicate Optimization — 2026-03-30
- Pattern: Replace @Query + .filter {} with @Query(filter: #Predicate<Model> { ... }) for stored properties
- Key code: `@Query(filter: #Predicate<CustomCategory> { $0.type == "expense" }, sort: \CustomCategory.createdAt)`
- Limitation: Enum properties crash in #Predicate — keep enum filtering in-memory
- Files: Multiple views using @Query with CustomCategory, Budget, RecurringRule, Account, SavingsGoal

## 2026-03-30 — Split @Query with #Predicate for String/Bool filtering (PR #165)
- Pattern: Replace `@Query var all: [T]` + computed `var filtered` with two typed `@Query(filter: #Predicate {...})` properties
- Example: `@Query(filter: #Predicate<CustomCategory> { $0.type == "expense" }) var expenseCategories`
- Benefit: DB-level filtering, no post-fetch in-memory pass, SwiftUI auto-updates on predicate match changes
- Safe for: String, Bool, Date, Int properties
- Avoid for: Decimal, enum rawValue (known SwiftData crash)

## Pull-to-refresh + Skeleton Loading — 2026-03-30
- Pattern: @State isLoading = true + .task { sleep + withAnimation { isLoading = false } } for skeleton transition
- Key code: `.refreshable { viewModel.refresh(...); try? await Task.sleep(for: .milliseconds(300)) }`
- Shimmer: LinearGradient overlay with repeatForever animation, masked by content shape
- Files: SkeletonView.swift for reusable components

## 2026-03-30 — CategoryPickerOptions enum for shared static option arrays (PR #171)
- Pattern: `enum CategoryPickerOptions { static let icons = [...]; static let colors = [...] }` as a namespace for shared picker data
- Benefit: Single source of truth for icon/color options used by both AddCategoryView and EditCategoryView — eliminates duplication, easy to add new options
- Reuse: Apply this enum-namespace pattern to any shared static data used across multiple sibling views

## View Refactor (DebtPayoffView) — 2026-03-31
- Pattern: Extract types+helpers to Types file, individual rows to RowView, grouped sections to SectionViews file. Keep @State-heavy inputs in orchestrator.
- Key code: Renamed private `abs()` to `debtAbs()` when making internal to avoid stdlib conflict. #Preview with complex setup needs explicit `return`.
- Files: DebtPayoffTypes.swift, DebtRowView.swift, DebtPayoffSectionViews.swift, DebtPayoffView.swift

## 2026-03-31 — PR #174 — NSDecimalNumber .doubleValue pattern
- Pattern: `Int(NSDecimalNumber(decimal: value).doubleValue)` instead of `.intValue`
- Why: .intValue returns 0 for repeating decimals (Foundation bug). Now used consistently in runway() and notification formatting.
- Reuse: Any Decimal→Int conversion in the project should use this pattern.

## Custom Category Threading Pattern — 2026-03-31
- Pattern: Parent views with @Query for CustomCategory pass .map(\.asAppCategory) down to child components via `var customCategories: [AppCategory] = []` parameter
- Key code: `AppCategory.find(id, custom: customCategories)` — always pass custom array
- Files: Category.swift (find overload), all views/components that display categories

## Unit Test Setup Pattern — 2026-03-31
- Pattern: For XCTest in Xcode projects, test files need: PBXFileReference + PBXBuildFile in project.pbxproj, added to test group children and Sources build phase. Scheme TestAction must have Testables with BuildableReference to test target.
- Key setup: GENERATE_INFOPLIST_FILE = YES in test target build settings (both Debug and Release)
- Best targets for testing: Pure logic engines, ViewModels with no ModelContext dependency, model computed properties, date calculations

## 2026-04-01 — PR #198 — Unit Test Design Patterns
- Pattern: ViewModel tests use in-memory data injection (vm.updateTransactions / vm.refresh) rather than @Query — no SwiftData container needed, tests run in 0.15s for 126 cases.
- Pattern: makeTransaction() / makeStatus() / makeRule() private helpers with default params reduce boilerplate while keeping tests readable.
- Pattern: Boundary-condition tests (Jan 31 → Feb 28, Feb 29 leap year, zero limit, zero balance, inactive rules) alongside happy path — good test taxonomy.
- Pattern: test_budget_displayName_withoutCustomFallsBackToOther() explicitly documents known fallback behavior, making future regressions visible.
- Tags: unit-tests, test-helpers, viewmodel, boundary-conditions

## Unit Testing Pure Logic — 2026-04-01
- Pattern: Identify services/engines that accept plain objects (not ModelContext) as ideal test targets
- Key targets: SubscriptionDetectorEngine.detect(from:), TransactionService.adjustBalance(), SavingsGoal computed properties, BudgetSuggestion.roundedAmount
- Key code: `import SwiftUI` needed when testing ViewModel Color properties
- Files: BurnRateTests/SubscriptionDetectorEngineTests.swift, DashboardViewModelTests.swift, TransactionServiceTests.swift, SavingsGoalTests.swift, BudgetSuggestionTests.swift

## Silent catch cleanup — 2026-04-01
- Pattern: Add #if DEBUG print("[ClassName] description: \(error)") #endif to catch blocks that return nil/false
- Key code: `catch { #if DEBUG \n print("[X] msg: \(error)") \n #endif \n return nil }`
- Files: TransactionExporter.swift, NotificationManager.swift, BiometricAuthManager.swift

## AppIntents/Siri Shortcuts — 2026-04-01
- Pattern: Create ModelContainer in perform() method using same schema as app. Use ModelContext to fetch data. Return IntentResult with human-readable string.
- Key code: `let container = try ModelContainer(for: Account.self, Transaction.self, ...)` then `let context = ModelContext(container)` then `try context.fetch(FetchDescriptor<T>())`
- Gotcha: AppShortcut phrase interpolation `\(\.$param)` only works with AppEnum/AppEntity, not String. Use static phrases for String params.
- Files: BurnRate/Intents/*.swift

## WidgetKit Medium Layout — 2026-04-01
- Pattern: HStack with circular progress ring (left) + VStack details (right) for medium widgets
- Key code: Use @Environment(\.widgetFamily) + switch for size-specific layouts. Pass Decimal as String via Codable for App Group UserDefaults.
- Files: BurnRateWidget/SavingsGoalWidget.swift

## WidgetKit Medium Layout — 2026-04-01
- Approach: HStack with circular progress ring (emoji + %) on left, detail VStack on right
- Files: *Widget.swift, WidgetDataStore.swift, BurnRate.xcodeproj/project.pbxproj
- Pattern: Mirror data model fields in widget extension (SavingsWidgetItem). Use diff-before-reload to prevent unnecessary WidgetCenter.reloadTimelines calls. Always check all 4 pbxproj sections when adding new files.

## Spending Insights Engine — 2026-04-01
- Pattern: Month-over-month comparison engine using targeted DB queries (fetchExpenses with from/to dates)
- Key code: Group by category → compute % change → sort by amount → find top insight by max abs change
- Files: SpendingInsightsEngine.swift, SpendingInsightsCard.swift

## 2026-04-01 — PR #212 — SpendingInsightsEngine accessibility
- PATTERN: Full accessibility suite on analytics cards — .accessibilityElement(children: .contain) on container, .accessibilityHidden(true) on all decorative SF Symbols, dedicated categoryAccessibilityLabel() helper that combines name + amount + direction, .accessibilityLabel on footer. This is the gold standard for dashboard card accessibility.
- Tags: accessibility, swiftui, dashboard

## Planned Expenses Feature — 2026-04-01
- Pattern: New SwiftData model + static service + list view with sections + form views + engine integration
- Key code: Default parameter pattern for backward-compatible engine extension; `applyPlannedExpenses` modifies daily impacts array in-place via `inout`
- Files: PlannedExpense.swift, PlannedExpenseService.swift, PlannedExpensesView.swift, PlannedExpenseFormViews.swift

## Service Unit Tests — 2026-04-01
- Pattern: @MainActor test class + in-memory ModelContainer with ALL model types registered (even unrelated ones — SwiftData requires full schema)
- Key code: `let config = ModelConfiguration(isStoredInMemoryOnly: true); container = try! ModelContainer(for: Model1.self, Model2.self, ..., configurations: config)`
- Files: BurnRateTests/*ServiceTests.swift
- Note: pbxproj needs 4 edits per file: PBXBuildFile, PBXFileReference, PBXGroup children, Sources build phase

## 2026-04-01 — PR #222 — SwiftData Service Unit Test Pattern
- Pattern: @MainActor class + ModelConfiguration(isStoredInMemoryOnly:true) + ModelContainer(for: ALL models) + setUp creates context + tearDown deletes context
- Use: For testing any static service (BudgetService, CategoryService, etc.)
- Example: `@MainActor final class BudgetServiceTests: XCTestCase { var context: ModelContext! }`
- Why it works: Full model graph prevents relationship FK errors; in-memory ensures isolation; @MainActor matches SwiftData main-thread requirement

## 2026-04-01 — PR #227 — Filter Pipeline Optimization Pattern
- Pattern: Pre-compute expensive values before filter loop, cache per-element lookups in dictionary, order checks cheapest-first with early exit
- Example: `let fromBound = dateFrom?.startOfDay` outside loop; `categoryNameCache[id] ?? AppCategory.find(...)` inside; type check → date check → text search (costliest last)
- Why: Avoids Calendar.startOfDay per element, avoids O(n×m) category lookups, short-circuits on cheap conditions first
