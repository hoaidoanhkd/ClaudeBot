# Heartbeat Checklist

Coordinator reads this file periodically (every 30 minutes or when idle).
Check each item and take action if needed.

## Agent Health
- [ ] All 3 tmux sessions alive? (cc-coordinator, cc-coder, cc-reviewer) → if dead, run `~/.claude/scheduled/multi-agent-start.sh`
- [ ] Claude-peers broker responding? → if not, restart broker

## Task Monitoring
- [ ] Is go-loop stuck on same task > 30 minutes? → alert user: "⏳ Task [name] taking longer than expected"
- [ ] Any unreviewed PRs older than 1 hour? → `gh pr list --state open` → remind reviewer
- [ ] Any failed CI runs? → `gh run list --status failure -L 1` → alert + dispatch fix

## Memory Hygiene
- [ ] Logs growing too large? → `du -sh ~/logs/` → if > 500MB, prune old logs
- [ ] Memory files growing too large? → if shared/lessons.md > 200 lines, run `~/scripts/memory-prune.sh`

## Proactive Suggestions
- [ ] Idle for 2+ hours with pending goals? → suggest `/go` to user
- [ ] GOALS.md has items > 7 days old untouched? → flag as stale
- [ ] Weekly digest due? (Sunday) → auto-run `~/scripts/weekly-digest.sh`
