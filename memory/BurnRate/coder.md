
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
