# BurnRate — GOALS.md
Last scan: 2026-03-30

## Legend
- ⭐ Priority | Effort: S (< 2h) / M (half day) / L (1+ days)
- Status: [ ] pending / [x] done / [~] in progress

---

## 🔴 Critical Fixes

- [ ] ⭐ Add unit tests for ViewModels and Services — coverage is at 1% (62 files, 1 test) — Effort: M
- [ ] ⭐ Fix SwiftData queries — use #Predicate instead of in-memory filter (#124) — Effort: S
- [ ] Empty code blocks cleanup (5 remaining) — Effort: S

---

## 🟠 Refactors (Large Files >300 LOC)

- [ ] Refactor CategoryManagementView (496 LOC → sub-views) — Effort: S
- [ ] Refactor BudgetListView (462 LOC → sub-views) — Effort: S
- [ ] Refactor DebtPayoffView (459 LOC → sub-views) — Effort: S
- [ ] Refactor NetWorthView (416 LOC → sub-views) — Effort: S
- [ ] Refactor MonthlySummaryView (364 LOC → sub-views) — Effort: S
- [ ] Refactor CashFlowForecastView (361 LOC → sub-views) — Effort: S
- [ ] Refactor NotificationManager (354 LOC → split concerns) — Effort: S
- [ ] Refactor RecurringRulesView (353 LOC → sub-views) — Effort: S
- [ ] Refactor SavingsGoalDetailView (308 LOC → sub-views) — Effort: S
- [ ] Add #Preview macros to all views missing them (#117) — Effort: S

---

## 🟡 Open Issues (from GitHub)

- [ ] ⭐ Pull-to-refresh + skeleton loading states (#122) — Effort: S
- [ ] Weekly spending recap notification (#140, weeklyRecapEnabled) — Effort: S
- [ ] Multi-currency support — Account.currency field exists but unused (#120) — Effort: M
- [ ] Fix weeklyRecapEnabled default to false (#138) — Effort: S
- [ ] Service layer consolidation (#123) — Effort: M
- [ ] Verify HistoryView refactor is complete (#118 — was 333→187 LOC) — Effort: S
- [ ] Verify custom category management done (#121 — CategoryManagementView exists) — Effort: S
- [ ] Close duplicate AI Spending Coach issues (8 duplicates of #149/#139) — Effort: S

---

## 🟢 New Features (from Competitor Research)

- [ ] ⭐ Siri & Apple Shortcuts integration — ask "What's my groceries balance?" (YNAB has this, high demand) — Effort: M
- [ ] ⭐ Home screen widgets expansion — add budget % and savings goal widgets (beyond runway widget) — Effort: M
- [ ] Spending insights summary card — weekly/monthly "you spent X% more on dining" (Monarch-style, on-device) — Effort: M
- [ ] Zero-based budgeting mode — assign every dollar to a category (YNAB-style) — Effort: L
- [ ] Planned/upcoming expenses — add future one-time expenses to cash flow (Simplifi-style) — Effort: M
- [ ] App localization — Vietnamese + other languages (hardcoded English strings) — Effort: L
- [ ] iCloud sync — sync data across devices (high retention driver) — Effort: L

---

## ✅ Recently Completed

- [x] DashboardView refactor 620→259 LOC (PR #164)
- [x] P1 UX fixes: subscription persist, debt validation, nav link (PR #163)
- [x] Locale-safe Decimal parsing + intValue fixes (PR #162)
- [x] Subscription detector auto-detect (PR #161)
- [x] Debt payoff snowball/avalanche cascade fix (PR #161)
- [x] Net Worth tracker + trend chart (PR #157)
- [x] Debt Payoff Calculator (PR #159)
- [x] Spending Pace Alerts (PR #154)
- [x] Bill reminders (PR #152)
- [x] Async race fix in notifications (PR #156)
