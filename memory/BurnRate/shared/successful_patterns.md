
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
