# BurnRate — GOALS.md
Last scan: 2026-04-01

## Legend
- ⭐ Priority | Effort: S (< 2h) / M (half day) / L (1+ days)
- Status: [ ] pending / [x] done / [~] in progress

---

## 🔴 Critical Fixes

- [x] ⭐ Add unit tests for ViewModels and Services (126→219 total) — PRs #198 #200
- [x] ⭐ Fix SwiftData queries — use #Predicate instead of in-memory filter (#124) — PR #165
- [x] Empty code blocks cleanup — already clean, no empty blocks found
- [ ] ⭐ Fix budget alerts repeated firing (#87) — fires on every refresh instead of threshold crossing — Effort: M
- [ ] ⭐ Fix budget dashboard doesn't refresh on limit edit (#88) — Effort: S
- [ ] Fix avgDailyBurn inflated for current month (#90) — Effort: S
- [ ] Fix custom category display in Budget views/notifications (#197) — Effort: S
- [ ] Fix NotificationManager displayName() missing custom: in notifications (#202) — Effort: S
- [ ] Fix Delta card VoiceOver missing percentage info (#91) — a11y — Effort: S
- [x] Verify Decimal #Predicate correctness in DebtPayoff/SavingsGoals (#166) — PR #224 (switched to in-memory filter)
- [ ] Fix hardcoded dollar sign in OnboardingView (#46) — Effort: S
- [ ] Fix symbolEffect pulse isActive (#50) — Effort: S
- [ ] Fix runway() 999 empty state for new users (#29) — Effort: S
- [ ] Add static DateFormatter cache (#31) — Effort: S
- [ ] Add loop cap to RecurringTransactionService.processDueRules (#52) — Effort: S
- [ ] Add inverse relationship for RecurringRule.account (#53) — Effort: S

---

## 🟠 Refactors (Large Files >300 LOC)

- [x] Refactor CategoryManagementView (496→119 LOC) — PR #171
- [x] Refactor BudgetListView (462→110 LOC) — PR #172
- [x] Refactor DebtPayoffView (459→221 LOC) — PR #175
- [x] Refactor NetWorthView (416→168 LOC) — PR #177
- [x] Refactor MonthlySummaryView (364→67 LOC) — PR #178
- [x] Refactor CashFlowForecastView (361 LOC → sub-views) — PR #199
- [x] Refactor NotificationManager (392→63 LOC → extension files) — PR #201
- [x] Refactor RecurringRulesView (353→133 LOC → sub-views) — PR #203
- [x] Refactor SavingsGoalDetailView (308→147 LOC → sub-views) — PR #204
- [x] Add #Preview macros to all views missing them (#117) — PR #213

---

## 🟡 Open Issues (from GitHub)

- [x] ⭐ Pull-to-refresh + skeleton loading states (#122) — PR #167
- [x] Weekly spending recap notification (#140, weeklyRecapEnabled) — PR #169
- [x] Multi-currency support — Account.currency field exists but unused (#120) — PR #215
- [x] Fix weeklyRecapEnabled default to false (#138) — PR #169
- [x] Service layer consolidation (#123) — PR #217
- [x] Verify HistoryView refactor is complete (#118) — confirmed PR #205 (204 LOC)
- [x] Verify custom category management done (#121) — confirmed PR #205
- [x] Close duplicate AI Spending Coach issues (9 duplicates of #149/#139) — closed via gh CLI
- [x] Fix MonthlyCategoryChart custom category names (#179) — fixed in PR #196
- [x] Add unit tests for new services: BudgetService, CategoryService, RecurringRuleService, PlannedExpenseService — PR #222
- [x] Refactor SettingsView (310→84 LOC → sub-views) — PR #223

---

## 🟢 New Features (from Competitor Research)

- [x] ⭐ Siri & Apple Shortcuts integration — PR #206
- [x] ⭐ Home screen widgets expansion — add budget % and savings goal widgets (beyond runway widget) — PR #210
- [x] Spending insights summary card — weekly/monthly "you spent X% more on dining" (Monarch-style, on-device) — PR #212
- [ ] Zero-based budgeting mode — assign every dollar to a category (YNAB-style) — Effort: L
- [x] Planned/upcoming expenses — add future one-time expenses to cash flow (Simplifi-style) — PR #218
- [ ] App localization — Vietnamese + other languages (hardcoded English strings) — Effort: L
- [ ] iCloud sync — sync data across devices (high retention driver) — Effort: L
- [x] Investment/RSU tracking — manual vest schedule entry, portfolio value — PR #225
- [ ] Shared/collaborative budgets via iCloud — Effort: L

---

## ✅ Recently Completed

- [x] SwiftData #Predicate optimization (PR #165)
- [x] Pull-to-refresh + skeleton loading (PR #167)
- [x] Weekly recap notification + default fix (PR #169)
- [x] CategoryManagementView refactor 496→119 LOC (PR #171)
- [x] BudgetListView refactor 462→110 LOC (PR #172)
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
- [x] Multi-currency display support per account (PR #215)
- [x] Service layer consolidation — BudgetService, RecurringRuleService, CategoryService (PR #217)
- [x] Planned/upcoming expenses with cash flow integration (PR #218)
- [x] Closed 9 duplicate AI Spending Coach issues
- [x] Fix Account.currency SwiftData migration default (PR #219)
- [x] Bulk-closed 46 duplicate/resolved GitHub issues (86→40 open)
- [x] Unit tests for BudgetService, CategoryService, RecurringRuleService, PlannedExpenseService (PR #222)
- [x] SettingsView refactor 310→84 LOC (PR #223)
- [x] Batch chores: Decimal #Predicate fix, objectVersion restore, dark preview (PR #224)
- [x] Investment/RSU tracking — models, service, 4 views (PR #225)
- [x] VestEvent isVested fix + HistoryView filter optimization (PR #227)
- [x] CashFlowForecastEngine tests 15→28 (PR #228)
- [x] InvestmentService tests — 18 tests (PR #229)
- [x] Total test suite: 297 tests passing
