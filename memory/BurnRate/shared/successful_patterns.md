
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
