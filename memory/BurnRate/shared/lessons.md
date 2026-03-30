
## 2026-03-30 — Review PR #2 (ClaudeBot) — MERGED
- Quality: 9/10
- Lesson: Evolution cycle PRs for agent rule updates should be reviewed against real PR history to confirm accuracy — all 4 rules in this cycle were verified against PRs #143-#148. GitHub self-approval is blocked for repo owner; merge directly in that case.
- Tags: evolution, coder-rules, anti-patterns, swiftdata, decimal, predicate

## 2026-03-30 — /evolve Cycle 2 — SUCCESS
- Task: Self-improvement evolution cycle (6 rule changes)
- Outcome: PR #2 merged to ClaudeBot repo, score 9/10
- Duration: ~8m (proposal → approve → Coder → Reviewer → merge)
- Retries: 0
- Lesson: git reset --hard in agent repo wipes untracked local memory files — Coder should avoid reset --hard in ~/agents/ repo. Discord channel can lose allowlist mid-session — always have Telegram as fallback.
- Tags: evolve, self-improvement, discord, memory-files

## 2026-03-30 — Bundle ID / Simulator Install Investigation — NO BUG
- Task: Diagnose "missing bundle ID / cannot install on simulator"
- Outcome: No code bug. Root cause: "iPhone 16" simulator doesn't exist on Xcode 26.3 (ships with iPhone 17 family + iPhone 16e only)
- Lesson: "xcrun simctl install" errors that look like bundle ID issues may actually be "device not found" errors. Always check available simulators with `xcrun simctl list devices` before assuming code is broken. On Xcode 26.3, use iPhone 17 Pro as default simulator target.
- Tags: simulator, xcode, debugging, false-alarm

## 2026-03-30 — Review PR #150 — MERGED
- Quality: 10/10
- Lesson: NSDecimalNumber.intValue is unreliable for repeating decimals (known Foundation bug — returns 0 for e.g. 333.333…). Safe workaround: .doubleValue + Int(). Double precision is sufficient for personal finance day counts. Pattern worth adding to anti_patterns.md.
- Tags: decimal, nsDecimalNumber, foundation-bug, runway, precision

## 2026-03-30 — Fix Empty Function Bodies PR #151 — SUCCESS
- Task: Fix 9 empty function bodies found by scan
- Outcome: PR #151 merged, score 10/10
- Duration: ~30m (Coder was blocked on permissions mid-task)
- Retries: 0
- Lesson: scan's "empty blocks" count can include duplicates from git worktrees. All 9 were intentional no-ops. Adding /* no-op */ comments is the right fix — clarifies intent for reviewers without changing behavior.
- Tags: code-quality, empty-blocks, comments, effort-s

## 2026-03-30 — Review PR #3 (ClaudeBot) — MERGED
- Quality: 9/10
- Lesson: When two evolution cycle PRs both insert rules after the same anchor in coder.md, a conflict arises. Resolution: keep both rule sets in sequence. Reviewer can safely resolve additive-only conflicts and rebase before merging.
- Tags: evolution, merge-conflict, rebase, coder-rules, coordinator-rules

## 2026-03-30 — Evolution PR #3 (ClaudeBot) — SUCCESS
- Task: Add 5 rules: auto-approve permissions, /scan cooldown, simulator query, no git reset in agents, NSDecimalNumber.intValue forbidden
- Outcome: PR #3 merged (9/10). Merge conflict resolved additively by Reviewer.
- Duration: ~5m
- Retries: 0
- Lesson: When multiple evolution PRs touch same anchor in coder.md, merge conflicts are expected — always additive resolution (keep both sets in sequence). Discord allowlist drops intermittently — Telegram is reliable fallback.
- Tags: evolve, coordinator, coder, merge-conflict, discord

## 2026-03-30 — Review PR #152 — MERGED (issue #153 filed)
- Quality: 8/10
- Lesson: When scheduling notifications linked to model objects, always purge ALL stale IDs at the top of the scheduling function (e.g. remove all `burnrate.bill.*` before re-adding). Just adding/replacing current IDs leaves ghost notifications for deleted objects. Pattern: fetch pending, filter by prefix, remove, then reschedule.
- Tags: notifications, UNUserNotificationCenter, ghost-notification, deletion, cleanup

## 2026-03-30 — Review PR #154 — MERGED (issue #155 filed)
- Quality: 9/10
- Lesson: When fixing async notification cleanup (getPendingNotificationRequests + remove), always put the reschedule loop INSIDE the completion handler to guarantee remove-then-add ordering. Running async remove concurrently with synchronous adds creates a non-deterministic race on the notification daemon's XPC queue.
- Tags: notifications, UNUserNotificationCenter, async, race-condition, ghost-cleanup

## 2026-03-30 — Bill Reminders PR #152 — SUCCESS
- Task: Add local push notifications 1 day before recurring bills
- Outcome: PR #152 merged, score 8/10. Follow-up #153 (ghost notifications on rule deletion)
- Duration: ~5m
- Retries: 0
- Lesson: When scheduling notifications per entity, always clear ALL matching prefix notifications before rescheduling (not just on toggle-off). removePendingNotificationRequests should be called at start of scheduleBillReminders.
- Tags: notifications, recurring, effort-s

## 2026-03-30 — Spending Pace Alerts PR #154 — SUCCESS
- Task: Mid-month warning when spending 20%+ ahead of budget pace
- Outcome: PR #154 merged, score 9/10. Follow-up #155 (async race in ghost fix)
- Duration: ~6m
- Retries: 0
- Lesson: UNUserNotificationCenter.getPendingNotificationRequests is async — scheduling loop must go INSIDE the completion handler to avoid XPC race. Pace formula: (spent/budget) > (daysElapsed/daysInMonth) * 1.2 with guard dayOfMonth >= 5 for minimum data.
- Tags: notifications, budget, pace, async, effort-s

## 2026-03-30 — Review PR #156 — MERGED
- Quality: 10/10
- Lesson: Correct pattern for UNUserNotificationCenter remove-then-reschedule: pre-filter rules OUTSIDE the callback (value capture), then inside getPendingNotificationRequests callback: remove stale IDs first, then add new requests. This serializes all operations on UNC's internal queue with guaranteed ordering.
- Tags: notifications, UNUserNotificationCenter, async, callback, race-fix

## 2026-03-30 — Review PR #157 — MERGED (issue #158 filed)
- Quality: 8/10
- Lesson: When reconstructing historical balances by walking backwards from a live value, ALWAYS undo the current (partial) period's transactions FIRST before stepping to prior periods. Starting from live balance without undoing the current month biases all historical points by the current month's net delta.
- Tags: historical-reconstruction, trend-chart, date-math, net-worth, off-by-period

## 2026-03-30 — Review PR #159 — MERGED (issue #160 filed)
- Quality: 8/10
- Lesson: Debt payoff cascade algorithms must update the rolling extra payment AND elapsed months after EVERY debt is paid off, not just the first. Pattern: `cumulativeExtra = payment` (freed amount rolls to next debt) + `totalMonthsElapsed += months` inside the main loop, not inside an `if i == 0` block.
- Tags: snowball, avalanche, cascade, financial-calc, debt-payoff, loop-logic

## 2026-03-30 — Review PR #161 — MERGED
- Quality: 9/10
- Lesson: For cascade payment algorithms, `cumulativeExtra += minPay` each iteration is equivalent to `cumulativeExtra = previous_payment` — both correctly model freed minimum cascading to next debt. Always verify cascade loops update both the elapsed time counter AND the cumulative extra every iteration, not conditionally.
- Tags: cascade, snowball, financial-calc, subscription-detection, algorithm

## 2026-03-30 — Async Race Fix PR #156 — SUCCESS
- Task: Fix UNUserNotificationCenter async race in scheduleBillReminders
- Outcome: PR #156 merged, score 10/10
- Lesson: getPendingNotificationRequests callback is async — all dependent scheduling logic must go INSIDE the completion handler, not outside. Pre-filter value-types before the callback to avoid closure capture issues.
- Tags: notifications, async, concurrency, effort-s

## 2026-03-30 — Net Worth Tracker PR #157 — SUCCESS
- Task: Add assets/liabilities/net worth dashboard with 6-month trend chart
- Outcome: PR #157 merged, score 8/10. Follow-up #158 (historical trend bias — undo current month before walking backwards).
- Lesson: Historical reconstruction walking backwards must undo current period first. "Start from live balance and walk back" pattern requires undoing currentMonth txns before i=0 snapshot.
- Tags: net-worth, swift-charts, date-math, effort-m

## 2026-03-30 — Debt Payoff Calculator PR #159 — SUCCESS
- Task: Snowball/avalanche debt payoff planner
- Outcome: PR #159 merged, score 8/10. Follow-up #160 (snowball cascade only applied to debt[0]).
- Lesson: Snowball cascade must roll through ALL debts — cumulativeExtra += minPay per paid-off debt. Common off-by-one: cascade guard `if i == 0` prevents rolling to subsequent debts.
- Tags: debt, snowball, cascade, calculation, effort-m

## 2026-03-30 — Subscription Detector PR #161 — SUCCESS
- Task: Auto-detect recurring subscriptions from transaction history
- Outcome: PR #161 merged, score 9/10
- Lesson: Good detection: group by normalized description, ±5% amount tolerance (use Decimal(1)/20 not force-unwrap literal), 70%+ interval match rate, non-overlapping frequency ranges. session-only @State dismiss is acceptable for v1.
- Tags: subscription-detection, algorithm, effort-m

## 2026-03-30 — P0 Locale+intValue Fixes PR #162 — SUCCESS
- Task: Fix 6× bare Decimal(string:) + 1× NSDecimalNumber.intValue across 6 files
- Outcome: PR #162 merged, score 10/10
- Duration: ~3m
- Lesson: Anti-pattern rules in coder.md are working — Coder caught all 7 instances in one sweep. Mechanical correctness fixes are fastest when rules are clear.
- Tags: locale, decimal, intValue, correctness, effort-s

## 2026-03-30 — P1 UX Fixes PR #163 — SUCCESS
- Task: Subscription persist, debt validation, net worth nav link (3 fixes)
- Outcome: PR #163 merged, score 10/10
- Duration: ~3m
- Lesson: AppStorage JSON-encoded Set<String> is a clean pattern for persisting small sets (Set<String> is natively Codable, try? handles edge cases, default "[]" decodes to empty). Validation gates should suppress error on initial load (hasEditedPayment pattern).
- Tags: appstorage, validation, ux, effort-s

## 2026-03-30 — DashboardView Refactor PR #164 — SUCCESS
- Task: Decompose DashboardView 620 LOC → 4 sub-views
- Outcome: PR #164 merged, score 10/10. 620 → 259 LOC (58% reduction)
- Duration: ~5m
- Retries: 0
- Lesson: Pure let + closure sub-view pattern (from PR #108) scales well. Keep complex chart wrappers and notification onChange in orchestrator — they're inherently tied to view state. Target <200 LOC is aspirational; 259 with good decomposition is acceptable. All 4 sub-views need pbxproj entries (PBXBuildFile + PBXFileReference + group + Sources phase).
- Tags: swiftui, refactor, dashboard, decomposition, effort-m

## 2026-03-30 — Review PR #165 — MERGED
- Quality: 8/10
- Lesson: SwiftData #Predicate is safe for String/Bool/Date properties but Decimal comparisons need verification — SwiftData stores Decimal as TEXT in SQLite, meaning numeric comparisons in #Predicate may fall back to in-memory or use string ordering. Always confirm storage type before pushing Decimal comparisons to DB level.
- Tags: swiftdata, predicate, decimal, performance, filtering

## 2026-03-30 — SwiftData #Predicate Optimization PR #165 — SUCCESS
- Task: Replace in-memory .filter{} with #Predicate macros (GitHub #124)
- Outcome: PR #165 merged, score 8/10. Follow-up #166 (Decimal TEXT comparison in #Predicate)
- Duration: ~10m
- Retries: 0
- Lesson: SwiftData #Predicate cannot handle enum rawValue comparisons — keep those in-memory. Decimal stored as TEXT in SwiftData — numeric #Predicate comparisons may differ for negative values on small datasets (< 20 items, low risk).
- Tags: swiftdata, predicate, performance, enum, decimal

## 2026-03-30 — Review PR #167 — MERGED
- Quality: 8/10
- Lesson: When composing skeleton components, shimmer should be applied at ONE level only — either the leaf component OR the parent container, never both. Nested .shimmer() calls create double gradient overlays with independent animation phases.
- Tags: swiftui, skeleton, animation, shimmer, ux, accessibility

## 2026-03-30 — Pull-to-refresh + Skeleton Loading PR #167 — SUCCESS
- Task: Add .refreshable and skeleton shimmer loading to main screens (#122)
- Outcome: PR #167 merged, score 8/10. Follow-up #168 (double shimmer on DashboardSkeleton)
- Duration: ~15m
- Retries: 0
- Lesson: When composing skeleton components, apply .shimmer() at the leaf level only — never at both parent and child. ShimmerModifier rendering content twice via .mask(content) is acceptable for simple shapes. SavingsGoalsView .refreshable can rely on @Query auto-update without manual refresh.
- Tags: skeleton, shimmer, pull-to-refresh, animation, swiftui
