# Evolution Policy — Rules for self-improvement

## What CAN be evolved
- agents/coordinator.md — workflow rules, command handling, dispatch patterns
- agents/coder.md — coding patterns, tool usage, workflow phases
- agents/senior-reviewer.md — review checklist, merge criteria
- agents/HEARTBEAT.md — monitoring checklist items

## What CANNOT be evolved
- agents/rules/immutable.md — NEVER
- agents/rules/evolution-policy.md — NEVER (meta-rules are fixed)
- scripts/*.sh — code changes need manual review
- install.sh, start.sh, config.env — infrastructure changes need manual review

## When to evolve
- Every 20 completed tasks (automatic trigger in /go loop)
- On /evolve command (manual trigger)
- Weekly scheduled review (Sunday via HEARTBEAT)

## How to evolve
1. ANALYZE: Read $MEMORY_DIR/shared/lessons.md for last 7 days
2. IDENTIFY: Find patterns — errors that repeat 3+, bottlenecks, missing rules
3. PROPOSE: Generate specific .md changes (add/modify/remove rules)
4. VALIDATE:
   - Change does NOT contradict immutable.md
   - Change does NOT remove working rules (only add or modify)
   - File size stays under 15KB after change
   - Change has data-driven justification (cite specific lessons)
5. PRESENT: Show proposed changes to user on active channel
6. WAIT: User must reply "approve" or "reject"
7. APPLY: If approved, Coder creates PR in ClaudeBot repo with changes
8. LOG: Record evolution in $MEMORY_DIR/shared/evolution_log.md

## Size budgets
- coordinator.md: max 15KB
- coder.md: max 10KB
- senior-reviewer.md: max 8KB
- HEARTBEAT.md: max 3KB

## Rollback
- If /go loop success rate drops >20% after evolution → auto-revert
- User can always /rollback the evolution PR
