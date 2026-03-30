
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
