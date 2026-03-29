
## 2026-03-29 — Evolution
- Tasks analyzed: 19 lessons + 2 anti-patterns
- Changes:
  1. ADD: Pre-task GOALS.md verification rule (prevent stale task waste)
  2. ADD: SwiftData delete orphan guard rule (prevent silent data loss)
  3. ADD: send_message uses `to_id` param (not `to`)
  4. MODIFY: Dispatch template includes anti-patterns alongside lessons
- Status: approved
- PR: pending (dispatched to Coder)

## 2026-03-30 — Evolution Cycle 2
- Tasks analyzed: PRs #143-#148 (QA batch + bug fixes)
- Changes:
  1. ADD: SwiftData Delete+Dismiss Task pattern (dismiss first, delete async)
  2. ADD: Decimal(string:) locale rule (always en_US_POSIX)
  3. ADD: SwiftData #Predicate enum restriction (no .rawValue in predicates)
  4. ADD: N-month historical analysis upper bound (startOfCurrentMonth, not Date())
  5. MODIFY: onChange(of: .count) rule expanded (compound key or onDismiss for property changes)
  6. PRUNE: Deduplicated anti_patterns.md (merged 2 Decimal entries → 1, merged 2 #Predicate entries → 1)
- Status: implementing
- PR: pending
