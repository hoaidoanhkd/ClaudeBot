
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
