
## 2026-03-30 — PR #2 (ClaudeBot) — Evolution Cycle 2: SwiftData/Decimal Rules
- Decision: MERGE
- Score: 9/10
- Issues found: GitHub blocked self-approval (expected for owner PRs) — merged directly. No content blockers.
- Coder patterns: Excellent rule quality. All 4 new coder.md rules are precise, actionable, derived from real PRs #143-#148. anti_patterns.md canonical entries well-structured (Problem/Fix/Rule/Tags). evolution_log.md clean. Deduplication effective.

## 2026-03-30 — PR #150 — Fix runway() Decimal division repeating decimals
- Decision: MERGE
- Score: 10/10
- Issues found: none
- Coder patterns: Perfect 1-line fix with explanatory comment citing the known Foundation bug. NSDecimalNumber.intValue → .doubleValue + Int() is correct and safe: (1) Int() truncates toward zero = floor for positive values ✓ (2) Double precision (15-16 sig digits) far exceeds realistic personal finance values ✓ (3) max(0,...) guard handles negative balance edge case ✓ (4) Fixes pre-existing failing test (24/24 now pass).

## 2026-03-30 — PR #151 — Annotate 7 intentional empty blocks with no-op comments
- Decision: MERGE
- Score: 10/10
- Issues found: none. 23/24 test confirmed pre-existing runway() failure (PR #150 not yet in branch) — irrelevant, #150 already merged to main.
- Coder patterns: Clean cosmetic-only PR. Correct comment text for each context: "dismisses alert" for Cancel buttons, "required protocol stub" for UIViewControllerRepresentable, "preview no-op" for Preview closures. No functional changes, exactly 7 additions = 7 deletions (pure substitution).

## 2026-03-30 — PR #3 (ClaudeBot) — Evolution Cycle #3: 5 new rules
- Decision: MERGE
- Score: 9/10
- Issues found: Merge conflict in coder.md (PR #2 rules + PR #3 rules both inserted after same anchor). Resolved by keeping both sets — no content loss. Rebased branch, force-pushed, then merged cleanly.
- Coder patterns: All 5 rules clear and actionable. Auto-approve tmux rule is safe in controlled agent context. /scan cooldown deduplication is logical. Simulator query rule prevents "iPhone 16 not found" errors. git reset --hard CRITICAL warning protects untracked memory files. NSDecimalNumber.intValue forbidden rule correctly derived from PR #150 fix.

## 2026-03-30 — PR #152 — Add Bill Reminders (local push notifications)
- Decision: MERGE + follow-up issue #153
- Score: 8/10
- Issues found: Ghost notification after rule deletion — removePendingBillReminders only called when billRemindersEnabled=false; deleted rule IDs never purged. Fix: remove all burnrate.bill.* pending notifications at start of scheduleBillReminders before re-adding. Issue #153 created.
- Coder patterns: Excellent overall. Triple-guard (isAuthorized && notificationsEnabled && billRemindersEnabled) is correct. Opt-in default false per anti-pattern rule. Static ID per rule (burnrate.bill.{uuid}) for deduplication. Past-date guard correct. 9AM UNCalendarNotificationTrigger correct. Static DateFormatter. Full accessibility (accessibilityLabel + adaptive accessibilityHint + .disabled(!notificationsEnabled)). onAppear rescheduling mitigates property-mutation gap.

## 2026-03-30 — PR #154 — Spending Pace Alerts + Fix Ghost Bill Notifications (#153)
- Decision: MERGE + follow-up issue #155
- Score: 9/10
- Issues found: Async race in ghost cleanup — getPendingNotificationRequests is async; scheduling loop runs synchronously after, so daemon could return snapshot including newly-added notifications if there's XPC lag, causing removal to wipe valid bill reminders. Low practical risk (daemon FIFO), but non-deterministic. Fix: put scheduling loop inside callback. Issue #155 filed.
- Coder patterns: Excellent feature. Pace formula correct (spentRatio > expectedPace * 1.2). BudgetStatus.percentage confirmed 0.0-2.0 range (capped). Guard spendingRatio < 1.0 correctly excludes budget-exceeded (handled by checkBudgets). Min 5 days guard sensible. Per-day dedup key (categoryName-dayOfMonth) in-memory consistent with existing budget threshold pattern. resetMonthlyTracking extended correctly. Opt-in false. Accessibility complete. Needed rebase (branch predated PR #152/150 merges) — resolved cleanly.

## 2026-03-30 — PR #156 — Fix async race in scheduleBillReminders (closes #155)
- Decision: MERGE
- Score: 10/10
- Issues found: none
- Coder patterns: Perfect targeted fix. rulesToSchedule pre-filtered outside callback (value-type capture, safe). Scheduling loop inside getPendingNotificationRequests callback guarantees remove-then-add ordering on UNC's internal serial queue. No functional logic changes — same filter/content/trigger/identifier. Exactly matches recommended fix from issue #155.

## 2026-03-30 — PR #157 — Add Net Worth Tracker (assets/liabilities + 6-month trend)
- Decision: MERGE + follow-up issue #158
- Score: 8/10
- Issues found: Historical trend bias — monthlySnapshots starts from live netWorth (includes current month's transactions) but never undoes current month before stepping backwards. All historical points (i>=1) are biased by current month's net delta. Fix: undo current month's transactions from currentNetWorth before the i=0 snapshot. Issue #158 filed.
- Coder patterns: Good overall structure. assets/liabilities/netWorth computed properties correct. assetAccounts >= 0 includes zero-balance (minor). singleAccountHint condition correct (shows for 0-1 accounts with no liabilities). NSDecimalNumber(..).doubleValue used correctly for chart (not .intValue). All display uses .formatted2. Accessibility thorough: accessibilityElement(children: .combine), adaptive accessibilityLabel, icons hidden. pbxproj entries correct (PBXBuildFile + PBXFileReference + Sources). abs() Decimal helper clean.

## 2026-03-30 — PR #159 — Debt Payoff Calculator + Fix Net Worth Trend (#158)
- Decision: MERGE + follow-up issue #160
- Score: 8/10
- Issues found: Snowball/avalanche cascade broken for debts[1..n] — `payment = minPay + (i == 0 ? extra : 0)` only gives extra to debt[0]. `totalMonthsElapsed` and `extra` only updated when i==0. All subsequent debts get only minPay. Correct fix: cumulativeExtra rolls to each debt, totalMonthsElapsed updates every iteration. Issue #160 filed.
- Coder patterns: Decimal locale correct (both text fields use en_US_POSIX). payoffMonths uses .doubleValue not .intValue (anti-pattern learned). .rounded(.up) correct for ceiling. payment > 0 guard returns 999 cleanly. payoffDateLabel handles 999→"N/A" and pluralization. NetWorthView fix (#158) correct — undoes currentMonth transactions before snapshot loop, chart gets 6 proper points (1 live + 5 month-starts). Accessibility thorough. pbxproj entries correct.

## 2026-03-30 — PR #161 — Subscription Detector + Fix Snowball Cascade (#160)
- Decision: MERGE
- Score: 9/10
- Issues found: none blocking. 3 nice-to-haves: (1) force unwrap Decimal(string:"0.05",locale:POSIX)! — safe but stylistic; (2) dismissedNames @State not persisted — session-only dismiss; (3) view normalize() simpler than engine's (no regex whitespace collapse) — potential mismatch for multi-space notes.
- Coder patterns: Cascade fix correct — cumulativeExtra += minPay is equivalent to cumulativeExtra = previous_payment, correctly models freed minimum rolling to next debt. totalMonthsElapsed accumulates per debt for correct absolute payoff dates. Engine edge cases clean: 2+ occurrence guard, medianAmount > 0, allSatisfy tolerance, integer avg interval fine for ±5d ranges, non-overlapping frequency ranges. Decimal locale correct on engine: NSDecimalNumber for conversion (not intValue). Accessibility thorough. pbxproj entries (2 files) correct.

## 2026-03-30 — PR #162 — Fix locale-unsafe Decimal parsing + intValue (7 fixes, 6 files)
- Decision: MERGE
- Score: 10/10
- Issues found: none
- Coder patterns: Perfect sweep. All 6 Decimal(string:) calls on user input now use en_US_POSIX locale. NSDecimalNumber.intValue in weeklyRecapBody correctly fixed to Int(.doubleValue) — change = repeating decimal likely (thisWeek/lastWeek ratio * 100). Mechanical, comprehensive, no scope creep.

## 2026-03-30 — PR #163 — Fix 3 P1 UX issues (subscription persistence, debt validation, net worth nav)
- Decision: MERGE
- Score: 10/10
- Issues found: none
- Coder patterns: (1) AppStorage JSON encode/decode for Set<String> is correct — Set<String> is natively Codable, default "[]" decodes to empty set, try? on both sides handles failure gracefully, no concurrent write risk (dismiss only on user tap). (2) Debt validation: hasEditedPayment gate correctly suppresses error on initial load, only shows after first onChange. Red border + label + error text all correct. (3) NetWorthView hint → NavigationLink(SettingsView) clean: clear affordance label, accessible hint.

## 2026-03-30 — PR #164 — Refactor DashboardView 620→259 LOC (extract 4 sub-views)
- Decision: MERGE
- Score: 10/10
- Issues found: none
- Coder patterns: Excellent refactoring. All 4 sub-views use pure let values + closures — no @Query, no @EnvironmentObject, no @Bindable leakage. All mutations (viewModel.autoGeneratedCount=0, editingTransaction=$0, viewModel.showAddTransaction=true) stay in DashboardView passed as closures. burnRateChartSection/categoryBreakdownSection kept inline (use viewModel directly) — correct design decision. DashboardMonthlyTrendsLink separate struct for conditional hasTransactions display. All 4 files have #Preview. pbxproj all 4 entries correct (PBXBuildFile + PBXFileReference + group + Sources).

## 2026-03-30 — PR #165 — #Predicate migration (8 files, in-memory → DB-level filtering)
- Decision: MERGE
- Score: 8/10
- Issues found: 🟡 Decimal in #Predicate — DebtPayoffView `$0.balance < 0` and SavingsGoalsView `$0.currentAmount < $0.targetAmount` use Decimal at SQLite level; SwiftData stores Decimal as TEXT, string comparison may differ from numeric. Small datasets so low impact. Tracked in issue #166.
- Coder patterns: Clean predicate migration. String/Bool/Date predicates all correct. Enum rawValue workaround properly documented. TransactionService 4-branch logic correct (if-let guards ensure category is non-nil when used in predicate). BudgetViewModel filter redundancy correctly removed. onChange sum trick (expenseCount + incomeCount) valid since categories don't change type.

## 2026-03-30 — PR #167 — Skeleton loading + pull-to-refresh (6 files, SkeletonView new)
- Decision: MERGE
- Score: 8/10
- Issues found: 🟡 Double shimmer — DashboardSkeleton applies .shimmer() at top level while its child SkeletonCard/SkeletonRow also each call .shimmer(); produces double gradient overlay with competing phase animations. Tracked #168. 🟢 ShimmerModifier renders content twice via .mask(content). 🟢 DashboardView else-block indentation cosmetic.
- Coder patterns: Pull-to-refresh correctly triggers ViewModel refresh (HistoryView + BudgetListView) or relies on @Query auto-update (SavingsGoalsView with comment explaining why). Accessibility labels on skeleton components correct (.accessibilityElement + .accessibilityLabel). isLoading time-based pattern (300-400ms) is pragmatic for SwiftData on-device load. pbxproj entries present for new file (non-standard IDs but build passes).

## 2026-03-30 — PR #169 — weeklyRecapEnabled default fix + rich recap notification (3 files)
- Decision: MERGE
- Score: 8/10
- Issues found: 🟡 AppCategory.find($0.categoryId) without custom: array → custom categories fall back to all.last! (last built-in). Notification shows wrong name for users with custom expense categories as top spend. Tracked #170. 🟢 Comment "inside completion handler" is stale/misleading (code correct, no handler used). 🟢 changeInt != 0 silently omits comparison for <1% changes.
- Coder patterns: NSDecimalNumber(.doubleValue) + Int() correctly avoids .intValue repeating-decimal bug (lesson from PR #162). Default false for weeklyRecapEnabled clean fix. Remove-then-add for notification replacement is correct (removePending is sync). categoryBreakdown parameter has default [] for backward compat. guard thisWeek > 0 zero-spend path correct.

## 2026-03-30 — PR #171 — CategoryManagementView refactor 496→119 LOC (3 new files)
- Decision: MERGE
- Score: 9/10
- Issues found: none blocking. 🟢 No #Preview blocks on 3 new files. 🟢 CategoryIconPicker accessibility label uses raw SF Symbol name ("tag.fill") not human name. 🟢 CategoryColorPicker uses hex string ("#FF6B6B") as accessibility label.
- Coder patterns: Excellent. Pure let + closure pattern (proven in PR #164) correctly applied — CustomCategorySection/BuiltInCategorySection take only let values. @Binding used only for picker selection state (correct). onEdit/onDelete closures keep mutations in orchestrator. CategoryPickerOptions enum cleanly deduplicates icon/color arrays. pbxproj complete for all 3 files (PBXBuildFile + PBXFileReference + group + Sources). EditCategoryView correctly uses .onAppear to seed @State from model; save() directly mutates reference-type model. Type not editable in EditCategoryView — correct design.

## 2026-03-31 — PR #172 — BudgetListView refactor 462→110 LOC (3 new files)
- Decision: MERGE
- Score: 9/10
- Issues found: none. BudgetFormViews.swift at 212 LOC (slightly over 200 target) acceptable.
- Coder patterns: Addressed PR #171 feedback — all 3 new files have #Preview blocks. Pure let + closure pattern correct throughout (ActiveBudgetsSection, InactiveBudgetsSection, BudgetSuggestionsBanner, BudgetEmptyState). BudgetViewModel mutations (toggleActive, delete, create, update) all called via closures in orchestrator. Decimal(string:locale:en_US_POSIX) locale-safe in both Add/Edit forms. "\(budget.monthlyLimit)" seed is safe — Decimal.description is locale-independent. pbxproj complete all 3 files.

## 2026-03-31 — PR #173 — Fix double shimmer (#168) + custom category recap names (#170) (2 files, +5/-2)
- Decision: MERGE
- Score: 10/10
- Issues found: none. Minor: let custom computed inside map closure (negligible O(n*m) at small scale).
- Coder patterns: Perfect surgical fixes. Both follow-up issues resolved exactly as suggested. Balance card gets .shimmer() at VStack level (raw shapes only — correct). Title RoundedRectangle in recent-transactions section gets own .shimmer(). Outer VStack .shimmer() removed. @Query customCategories (no filter needed — find uses all types). AppCategory.find(_:custom:) overload used correctly.

## 2026-03-31 — PR #174 — Fix runway() Decimal division returning 0
- Decision: MERGE
- Score: 10/10
- Issues found: none. Perfect surgical 1-line fix.
- Coder patterns: Correctly reused NSDecimalNumber(.doubleValue)+Int() pattern from PR #162. Comment explains the Foundation bug clearly. No scope creep.

## 2026-03-31 — PR #175 — DebtPayoffView refactor 459→221 LOC (3 new files)
- Decision: MERGE
- Score: 9/10
- Issues found: none. 🟢 debtAbs() free function redundant with abs(Decimal) (SignedNumeric). 🟢 payoffMonths/payoffDateLabel/debtAbs are bare module-level free functions rather than namespaced.
- Coder patterns: Cascade logic fully preserved (cumulativeExtra += minPay, totalMonthsElapsed += months). NSDecimalNumber(decimal:).doubleValue.rounded(.up) correctly used in payoffMonths. PayoffStrategy promoted from private to internal scope correctly for cross-file access. All sub-views pure let. #Preview on all 3 files. pbxproj 12 entries complete.

## 2026-03-31 — PR #176 — Add pull-to-refresh on SettingsView
- Decision: MERGE
- Score: 10/10
- Issues found: none
- Coder patterns: Clean minimal PR. Exact match to SavingsGoalsView pattern (@Query auto-refresh + 300ms Task.sleep UX delay). Comment style consistent. Placement after .navigationTitle correct. All 5 main views now have .refreshable.

## 2026-03-31 — PR #177 — NetWorthView refactor 416→168 LOC (3 new files)
- Decision: MERGE
- Score: 9/10
- Issues found: none. 🟢 Decimal(doubleVal).formatted2 in chart Y-axis labels — Double→Decimal micro imprecision (negligible for personal finance).
- Coder patterns: Applied PR #175 lesson — no custom abs(), uses stdlib. All sub-views pure let. #Preview on all 3 files. pbxproj 12 entries complete. Bug fix bonus: original breakdownSection used .padding(.top, liabilityAccounts.isEmpty ? 0 : 8) inside if !liabilityAccounts.isEmpty — always 8 (dead condition). New AccountBreakdownSection correctly uses assetAccounts.isEmpty ? 0 : 8. import Charts cleanly moved to NetWorthTrendChart.swift. NSDecimalNumber(decimal:).doubleValue locale-safe for Charts conversion.

## 2026-03-31 — PR #178 — MonthlySummaryView refactor 364→67 LOC (2 new files)
- Decision: MERGE
- Score: 9/10
- Issues found: 🟢 Pre-existing bug preserved: MonthlyCategoryChart uses AppCategory.find(catId) without custom: — custom categories show as "Other Expense" in chart legend. Tracked #179 (same root cause as #170).
- Coder patterns: Clean. 7 sub-views all pure let. MonthSelectorView onSelect closure wires to viewModel.selectedMonthIndex in orchestrator. ChartMode→MonthlyChartMode rename good for collision avoidance. import Charts moved to chart file. NSDecimalNumber(decimal:).doubleValue locale-safe on all 3 chart value conversions. ForEach(monthlyData.reversed()) valid with Identifiable. pbxproj 8 entries complete.

## 2026-03-31 — PR #196 — Fix AppCategory.find() missing custom: parameter
- Decision: MERGE
- Score: 8/10
- Issues found: 🟡 DashboardBudgetSummary not passed customCategories from DashboardView. 🟡 BudgetRowView/BudgetFormViews/InactiveBudgetRow no custom threading from parent screens. 🟡 BudgetViewModel.checkBudgetAlerts() + NotificationManager call displayName() with empty default. All 3 are pre-existing, not regressions. Created follow-up #197.
- Coder patterns: Comprehensive 19-file fix. customCategories.map(\.asAppCategory) threading pattern at screen level is clean and consistent. @Query added correctly in 4 screen views. Default [] parameter for backward compat is good. HistoryFilterSection correctly uses viewModel.customAppCategories. PR claims "all" calls fixed but misses budget display layer.

## 2026-04-01 — PR #198 — Add 102 unit tests for ViewModels and Services
- Decision: MERGE
- Score: 10/10
- Issues found: 🟢 Two if-let delta tests without XCTFail fallback (silent no-op risk). 🟢 test_daysUntilNegative_zeroBalance_withExpense_returnsDay1 mildly timing-sensitive.
- Coder patterns: Excellent test design — no SwiftData dependencies in unit tests, fast (0.15s/126 tests), full edge coverage (leap year, month boundary, div-by-zero protection, zero balance, inactive rules). Documents #179 fallback behavior in BudgetStatusTests. All 126 tests pass locally and post-merge. Infrastructure fix (scheme + GENERATE_INFOPLIST_FILE) minimal and correct.

## 2026-04-01 — PR #199 — CashFlowForecastView refactor 361→106 LOC (2 new files)
- Decision: MERGE
- Score: 9/10
- Issues found: 🟢 Decimal(amount) in Y-axis chart labels (Double→Decimal micro imprecision, same as #177, negligible). 🟢 negativeZoneFill uses first-ever-negative-point as start X (same as original, not a regression).
- Coder patterns: Clean. Faithful to #177/#178 pattern. Dead state (selectedPoint) correctly removed. @ChartContentBuilder used idiomatically. static let DateFormatters in chart file. warningBanner simplified from @ViewBuilder to plain if let. pbxproj 8 entries complete. import Charts moved to chart file. NSDecimalNumber(decimal:).doubleValue locale-safe. #Preview on all 3 files. Accessibility improved (full context in milestone row labels).

## 2026-04-01 — PR #200 — Add 83 unit tests (126→209 total), 5 new test files
- Decision: MERGE
- Score: 9/10
- Issues found: 🟢 test_topAlertBudgets_emptyWhenNoBudgets is trivially weak (just checks budgetStatuses.isEmpty, not the computed topAlertBudgets property). All others are meaningful.
- Coder patterns: Excellent edge coverage — frequency boundary values, normalization (case + whitespace), over-funded savings, nil account no-op, decimal precision. No SwiftData. NSDecimalNumber.intValue not used. pbxproj 20 entries (4×5 files) complete.

## 2026-04-01 — PR #201 — NotificationManager 392→63 LOC with 3 extension files
- Decision: MERGE
- Score: 9/10
- Issues found: 🟢 displayName() without custom: in notification bodies — pre-existing issue from #197 follow-up, not a regression. 🟢 scheduleWeeklyRecap comment references "completion handler" but uses direct synchronous remove — misleading comment, correct behavior.
- Coder patterns: Swift extension refactor for service class correct — private→internal widening necessary. isNotificationsEnabled computed property is a good DRY improvement. scheduleBillReminders loop correctly inside getPendingNotificationRequests callback. NSDecimalNumber.doubleValue used (not .intValue). pbxproj 12 entries (4×3 files) complete.

## 2026-04-01 — PR #203 — RecurringRulesView 353→133 LOC (3 new files)
- Decision: MERGE
- Score: 9/10
- Issues found: 🟢 try? modelContext.save() silently swallows errors — pre-existing, not a regression.
- Coder patterns: Correct placement — RecurringRuleRow + RecurringRuleSectionViews in Components group, AddRecurringRuleView in Sheets group. AppCategory.find() with custom: verified in orchestrator (@Query customCategories → .map(\.asAppCategory) threaded correctly to both active and paused rows). AddRecurringRuleView self-contained with own @Query — appropriate for feature sheet. #Preview on all 4 files. pbxproj 12 entries (4×3). LOC counts 133/99/45/149 verified.

## 2026-04-01 — PR #204 — SavingsGoalDetailView 308→147 LOC (2 new component files)
- Decision: MERGE
- Score: 9/10
- Issues found: 🟢 none. CI failure was billing/spending limit (not code). Post-merge local build clean.
- Coder patterns: Clean. SavingsGoalProgressView and SavingsGoalDetailSections (3 sub-views) all pure let. linkedAccount computed property correctly extracted to orchestrator. daysUntilDeadline/deadlineColor/progressColor helpers co-located with consuming views. Emoji unicode escapes cleaned to literals — nice touch. 8 #Preview variants (claimed 7). pbxproj 8 entries (4×2) complete.

## 2026-04-01 — PR #205 — Silent catch blocks debug logging (4 locations)
- Decision: MERGE
- Pass 1 (Spec): ✅ OK — all 4 catch blocks patched, HistoryView 204 LOC ✅, CategoryManagementView 119 LOC ✅
- Pass 2 (Quality): Score 10/10
- Issues found: none
- Coder patterns: Minimal, focused change. Consistent use of existing `#if DEBUG print(...)` pattern (matches EditBalanceView:96, WidgetDataStore:21). Class-prefix log format [ClassName] good. No pbxproj changes needed — no new files. Closed 4 issues cleanly.

## 2026-04-01 — PR #206 — Siri & Apple Shortcuts integration (AppIntents)
- Decision: MERGE
- Pass 1 (Spec): ✅ OK — 3 intents (CheckBudget, GetSpending, GetRunway), AppShortcutsProvider, read-only, ModelContainer in perform()
- Pass 2 (Quality): Score 10/10
- Issues found: none
- Coder patterns: Correct NSDecimalNumber.doubleValue.rounded() → Int() for percentage. CategorySpend.percentage is Double so direct Int() wrapping safe. AppCategory.find and allWith both include custom: param. BurnRateEngine.runway returns Int — integer division correct. No bare Decimal(string:). pbxproj 4×4 sections complete. Graceful empty-data guards in all 3 intents.

## 2026-04-01 — PR #210 — Budget + SavingsGoal home screen widgets (small+medium)
- Decision: MERGE
- Pass 1 (Spec): ✅ OK — Both BudgetWidget and SavingsGoalWidget added (small+medium). deadline+remaining fields present. Coordinator description was partial (said only systemMedium for Savings, but PR added Budget widget too — within spec #190).
- Pass 2 (Quality): Score 8/10
- Issues found: 🟡 objectVersion downgrade 77→63 in pbxproj (preferredProjectObjectVersion removed). 🟡 Two target DevelopmentTeam TargetAttributes removed (compensated in build settings). Follow-up issue #211 created.
- Coder patterns: Correct WidgetKit data model mirrors per extension. diff-before-reload pattern in WidgetDataStore ✅. containerBackground API correct. .policy(.never) push-driven correct. 4-section pbxproj entries complete. String-based onChange for savingsGoals (functional but slightly heavy).

## 2026-04-01 — PR #212 — SpendingInsightsEngine + SpendingInsightsCard (Monarch-style)
- Decision: MERGE
- Pass 1 (Spec): ✅ OK — Engine, Card, DashboardView wiring, 10 tests all present. Closes #191 and #22.
- Pass 2 (Quality): Score 9/10
- Issues found: 🟢 Categories with zero current spend appear in list (sorted last, minor UX). No test for compute() itself (acceptable — needs SwiftData container). 
- Coder patterns: Excellent. Proper NSDecimalNumber.doubleValue for Decimal→Double conversion. Guard for division-by-zero (previous > 0). nil percentChange for new categories. top insight filters on currentAmount > 0. Superb accessibility: .accessibilityHidden(true) on decorative icons, categoryAccessibilityLabel helper, .accessibilityLabel on footer. 10 deterministic unit tests covering all text-generation branches. pbxproj: 4 sections correct, SpendingInsightsEngine+Card in main app target (not widget) ✅.

## 2026-04-01 — PR #213 — Add #Preview macros to 7 SwiftUI views
- Decision: MERGE
- Pass 1 (Spec): ✅ OK (6/7 dark mode; HistoryExportMenu missing dark → Important not blocker)
- Pass 2 (Quality): Score 9/10
- Issues found: HistoryExportMenu missing dark mode preview (#214 filed); ContentView no inMemory flag (🟢)
- Coder patterns: Good data seeding (real amounts/icons), correct inMemory usage on all SwiftData views, import SwiftData added correctly

## 2026-04-01 — PR #215 — Multi-currency Display Support
- Decision: MERGE
- Pass 1 (Spec): ✅ OK — Account.currency field, picker, badges, NetWorth formatting, Decimal extension all present. Closes #120.
- Pass 2 (Quality): Score 8/10
- Issues found: 🟡 var currency: String no property-level default → existing accounts get currency="" after SwiftData auto-migration (display breaks, picker blank). Follow-up #216. 🟢 formatted(currencyCode:) allocates new NumberFormatter per call. 🟢 nonisolated(unsafe) on CurrencySymbolCache. 🟢 No unit tests for new extensions.
- Coder patterns: Good abstraction layer — formattedBalance/formatted(_:) on model is clean. CurrencySettings.code used correctly in init. currencySymbol(for:) lazy locale search with cache is correct. Accessibility updated across all 3 views.

## 2026-04-01 — PR #217 — Service Layer Consolidation
- Decision: MERGE
- Pass 1 (Spec): ✅ OK — 3 new services, static-method pattern, zero remaining direct modelContext.insert/delete in ViewModels/Views (grep confirmed), error handling upgraded, pbxproj 12 entries complete. Closes #123.
- Pass 2 (Quality): Score 9/10
- Issues found: 🟢 BudgetViewModel thin passthrough methods (preserved call-site compat). 🟢 fetchActive/fetchInactive currently unused by callers. 🟢 SavingsGoalService still uses try? on mutations (inconsistency with new services).
- Coder patterns: Perfect pattern match to existing services. Deliberate distinction: mutations→do/try/catch, queries→try?. grep-verified clean sweep.

## 2026-04-01 — PR #218 — Planned/Upcoming Expenses
- Decision: MERGE
- Pass 1 (Spec): ✅ OK — PlannedExpense model, PlannedExpenseService, PlannedExpensesView, Add/Edit forms, CashFlowForecastEngine integration, Settings link, #Preview (light+dark), model container registration, pbxproj 16 entries. Closes #193.
- Pass 2 (Quality): Score 9/10
- Issues found: 🟢 .onChange(of: count) won't recompute forecast on amount/date edits (mitigated by .onAppear). 🟢 customCategories.map per-row (negligible scale). 🟢 No unit tests for new engine helpers.
- Coder patterns: Excellent. Locale-safe Decimal parsing (en_US_POSIX) in both forms. AppCategory.find with custom: correct. Decimal.description locale-independent for form seeding. Bool predicates in @Query safe. applyPlannedExpenses boundary checks correct. Engine default=[] ensures backward compat with existing tests.
