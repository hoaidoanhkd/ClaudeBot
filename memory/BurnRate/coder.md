
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
