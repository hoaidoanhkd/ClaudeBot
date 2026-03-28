# /parallel — Parallel Coder Execution Guide

Use this command to understand how to spawn and manage parallel Coder agents for independent subtasks.

---

## What are parallel Coders?

Parallel Coders are temporary `cc-coder-N` tmux sessions (N = 1, 2, 3) that each run `claude --agent coder`. They are spawned on demand for independent subtasks and auto-cleanup when their task completes. The main `cc-coder` session continues to exist as the default Coder.

---

## Quick start

### Spawn one parallel Coder
```bash
~/scripts/spawn-coder.sh "feature-name" "Full task description here"
```

### Example — two independent features in parallel
```bash
# Terminal 1: spawn parallel coder for CSV export
~/scripts/spawn-coder.sh "csv-export" "Implement CSV export in HistoryView. Add export button, write CSVExporter.swift, update HistoryViewModel. Reply results to Coordinator when done."

# Terminal 2: main Coder handles the other subtask
# (send via Coordinator → main Coder message)
```

---

## Script reference: spawn-coder.sh

**Location:** `~/scripts/spawn-coder.sh`

**Arguments:**
- `task_name` — short slug used for the session label (e.g. `csv-export`, `fix-crash`)
- `task_description` — full instructions sent as the bootstrap message to the agent

**Behavior:**
1. Reads `PROJECT_PATH` from `~/agents/config.env`
2. Finds the lowest free slot: `cc-coder-1`, `cc-coder-2`, or `cc-coder-3`
3. Creates the tmux session and starts `claude --agent coder`
4. Sends the task description as a bootstrap message
5. When the agent exits, the session is killed automatically

**Limits:** Max 3 parallel Coders. If all slots are busy, the script exits with an error.

---

## Monitoring

```bash
# List all active coder sessions
tmux list-sessions | grep cc-coder

# Attach to a parallel coder session
tmux attach -t cc-coder-1

# Kill a stuck session manually
tmux kill-session -t cc-coder-2
```

---

## Rules for Coordinator

- Coordinator may call `spawn-coder.sh` directly via Bash (exception to no-Bash rule)
- Only use parallel Coders for truly independent subtasks (different files, no shared state)
- Max 3 parallel slots total
- Always collect ALL results before dispatching to Reviewer
- Report spawned session names to Telegram so user can monitor if needed

---

## Rules for parallel Coder agents

When a parallel Coder receives its bootstrap message, it must:
1. Call `set_summary("Parallel Coder [task-name] — working on assigned subtask")`
2. Execute the task
3. Send results back to Coordinator via `send_message`
4. Exit cleanly — do not wait for follow-up messages

---

## Coordinator workflow example

User: "Implement CSV export AND add budget alerts — they are independent"

Coordinator actions:
1. Identify 2 independent subtasks
2. Send main Coder: "[PARALLEL 1/2] Implement CSV export in HistoryView..."
3. Run: `~/scripts/spawn-coder.sh "budget-alerts" "[PARALLEL 2/2] Add budget alert notifications..."`
4. Telegram: "Spawning 2 parallel Coders. cc-coder handles CSV export, cc-coder-1 handles budget alerts."
5. Wait for both replies
6. Merge results, dispatch consolidated diff to Reviewer
7. Telegram: "Both subtasks complete. Reviewer checking..."
