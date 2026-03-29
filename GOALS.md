# Project Goals — BurnRate

## 🔴 Critical (P1 — Score > 4)
- [ ] Fix 9 empty function bodies — Severity:COMPLETENESS, Score:4.5 — Effort:S Impact:Medium

## 🟡 Code Quality (tests, accessibility, debt)
- [ ] Test coverage — increase from 1% to 40%+ (1 test file, 54 source files) — Effort:L Impact:High
- [ ] Localization — externalize 78 hardcoded strings — Effort:L Impact:Medium
- [ ] Refactor 7 large views (>300 LOC): DashboardView(577), CategoryManagementView(496), BudgetListView(462), MonthlySummaryView(364), CashFlowForecastView(361), RecurringRulesView(353), SavingsGoalDetailView(308) — Effort:M Impact:High
- [x] ~~Dead code: Account.currency and Account.sortOrder fields never read anywhere~~ — done (PR #103)
- [x] ~~Dead code: SettingsView @AppStorage("currency")~~ — NOT dead code, actively used by Currency Picker (PR #103 verified)
- [x] ~~Performance: HistoryView O(n) computed filter with no debounce, no ViewModel caching~~ — done (PR #105)
- [x] ~~Missing #Preview macros on major views~~ — done (PR #104)
- [x] ~~HistoryView 333 LOC — needs refactor/decomposition~~ — done (PR #108)

## 🟢 New Features
- [x] ~~📊 Monthly Budget with Alerts~~ — already implemented (PR #86)
- [x] ~~🔄 Recurring Transactions~~ — already implemented (PR #51)
- [x] ~~📤 CSV/PDF Export~~ — done (PR #43)
- [x] ~~📈 Monthly Summary / Trends~~ — already implemented (PR #89)
- [x] ~~🔔 Push Notifications~~ — done (PR #109)
- [ ] 💱 Multi-currency support — Account.currency field exists but unused — Effort:L Impact:Medium
- [x] ~~🏷️ Custom Category Management~~ — done (PR #110, #112)
- [ ] 💡 Spending Insights Engine — auto-detect patterns, alerts for unusual spending — Effort:L Impact:High
- [x] ~~⚡ Quick Income Swipe~~ — done (PR #49)
- [ ] ☁️ iCloud/CloudKit Sync — cross-device data sync — Effort:L Impact:High
- [ ] 🤖 AI Spending Coach — natural language Q&A ("Can I afford X?", "How long will savings last?"), powered by Claude API — Effort:L Impact:High ⭐ Priority
- [x] ~~🎯 Savings Goals Tracker~~ — done (PR #141, #143)
- [x] ~~📈 Cash Flow Forecasting~~ — done (PR #144)
- [x] ~~📊 Weekly Spending Recap~~ — done (PR #137)
- [x] ~~💡 Smart Budget Suggestions~~ — done (PR #145, #147)
- [x] ~~🔐 Biometric Lock~~ — done (PR #47)
- [ ] 🔔 Bill Reminders — alert X days before upcoming recurring bills — Effort:S Impact:Medium
- [ ] ⚡ Spending Pace Alerts — mid-month warning "on track to exceed [Category] budget by X" — Effort:S Impact:Medium
- [ ] 📊 Net Worth Tracker — assets + liabilities dashboard — Effort:M Impact:High
- [ ] 💳 Debt Payoff Calculator — snowball/avalanche payoff planner — Effort:M Impact:Medium
- [ ] 🔄 Subscription Detector — auto-flag recurring charges from transaction history — Effort:M Impact:Medium

## 🔵 UX/UI Improvements
- [x] ~~Empty State + Onboarding Flow~~ — done (PR #45)
- [x] ~~runway() 999 → ∞ symbol + "No expenses yet"~~ — done (PR #45)
- [x] ~~Pull-to-Refresh~~ — done (PR #102). Skeleton loading still TODO — Effort:S Impact:Low

## ⚪ Architecture/Performance
- [x] ~~Extract Service Layer~~ — done (PR #113, TransactionService with static methods, scored 10/10)
- [ ] Increase Test Coverage — TransactionViewModel, DashboardViewModel, Service layer tests — Effort:L Impact:High
- [x] ~~Optimize SwiftData Queries~~ — done (PR #114, #Predicate-based filtering)

## ✅ Completed
- [x] Fix Widget real data — App Group integration live
- [x] Category Breakdown UI — pie chart + legend implemented
- [x] Fix misleading comment in dailyBurnRate — now says "simple average"
- [x] Implement Edit Balance — EditBalanceView.swift (92 lines)
- [x] Search & Filter History — .searchable(), type/date/category filters, accessibility labels
- [x] Widget data write+read — WidgetDataStore.write() called from DashboardViewModel, getTimeline() reads from App Group
- [x] Remove stale TODO comments — cleaned (confirmed 0 TODOs)
- [x] Accessibility — added .accessibilityLabel() to all Views (2/12 → 12/12), 63 modifiers, reviewed 9/10
- [x] Static DateFormatter Cache — 6 formatters cached (Date+Extensions, BurnRateEngine, Decimal+Extensions, Widget), reviewed 9/10
- [x] Date Picker + Edit Transaction — DatePicker in AddTransactionView, tap-to-edit in History/Dashboard (PR #36)
- [x] DashboardView triple-refresh debounce — scheduleRefresh() with Task-based 100ms debounce (PR #37)
- [x] Decimal.formatted2 hardcodes USD — currency-aware formatting with Settings picker (PR #38)
- [x] Haptic Feedback + Micro-animations — sensoryFeedback, numericText, pie chart animation (PR #39)
- [x] Transaction Confirmation + Undo — toast overlay with undo for add/delete (PR #40)
- [x] CSV/PDF Export — ShareLink + date range from HistoryView (PR #43)
- [x] Empty State + Onboarding Flow — 3-page walkthrough, ∞ gauge, improved empty states (PR #45)
- [x] Biometric Lock — Face ID/Touch ID with lock screen overlay (PR #47)
- [x] Quick Income Swipe — shortcut on balance card with half-sheet (PR #49)
- [x] Fix BurnRateEngine.runway() Decimal division bug — PR #150

## Scan Metadata
- Last scan: 2026-03-30 (goal-discovery + competitor research)
- Total Swift files: 54
- Total LOC: ~4500
- Force unwraps: 0
- fatalError: 0
- Empty blocks: 9
- Large files (>300 LOC): 7
- Current test coverage: ~1% (1 test file / 54 source files)

## Periodic Tasks (Coordinator should check these)
- Every session: run tests, report if any fail
- After code changes: trigger review
- Weekly: code quality check on all ViewModels
