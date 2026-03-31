# BurnRate Memory Index
# Format: [topic-id] STATUS Summary → path
# STATUS: STABLE (tested, reliable) | WIP (active work) | REF (reference only)

# Topics
[swiftdata] STABLE SwiftData patterns: #Predicate, delete guards, Decimal gotchas → topics/swiftdata.md
[refactoring] STABLE Sub-view extraction: let+closure, file splitting, 200 LOC target → topics/refactoring.md
[testing] WIP Unit test patterns: MVVM injection, XCTest setup, 209 tests → topics/testing.md
[ui-patterns] STABLE Pull-to-refresh, skeleton loading, shimmer, widgets → topics/ui-patterns.md
[notifications] STABLE UNNotification scheduling, remove-then-reschedule, Siri shortcuts → topics/notifications.md
[locale-decimal] STABLE Decimal(string:) locale, NSDecimalNumber.intValue bug, formatting → topics/locale-decimal.md
[conventions] REF Git workflow, PR format, pbxproj registration, code quality → topics/conventions.md
[insights] WIP SpendingInsightsEngine, weekly recap, category analysis → topics/insights.md

# Recent decisions (last 5)
[2026-04-01] Spending insights uses on-device computation, no API calls
[2026-04-01] WidgetKit: medium widget with 3-metric layout, timeline refresh 15min
[2026-04-01] Siri Shortcuts: 5 AppIntents, @Parameter for user input
[2026-04-01] CI disabled (billing) — local build verify only
[2026-03-31] Refactor target: all views >300 LOC → sub-views (batch complete)

# Active tasks (from GOALS.md)
[TASK] HIGH Add unit tests — coverage at 1% (209 tests, need more)
[TASK] MED Multi-currency support — Account.currency field exists but unused
[TASK] MED Service layer consolidation
