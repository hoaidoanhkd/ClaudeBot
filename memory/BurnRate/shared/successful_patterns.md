
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
