#!/bin/bash
# go-loop.sh — Auto-run loop: picks next goal from GOALS.md, dispatches to coordinator.
# Stops when /tmp/go-loop-stop exists, no goals remain, or limits are hit.
# Sends tasks via tmux send-keys to cc-coordinator.
set -euo pipefail

source "$HOME/agents/config.env"

GOALS_FILE="$HOME/agents/GOALS.md"
STOP_FILE="/tmp/go-loop-stop"
DELAY="${GO_LOOP_DELAY:-30}"
MAX_TASKS=5
TASK_COUNT=0
FAIL_COUNT=0
MAX_FAILS=3

mkdir -p "$HOME/logs"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# Clean up stop file from previous run
rm -f "$STOP_FILE"

log "Go-loop started (delay: ${DELAY}s, max tasks: $MAX_TASKS)"

while true; do
  # Check stop conditions
  if [ -f "$STOP_FILE" ]; then
    log "Stop file found. Exiting."
    rm -f "$STOP_FILE"
    exit 0
  fi

  if [ "$TASK_COUNT" -ge "$MAX_TASKS" ]; then
    log "Completed $MAX_TASKS tasks. Pausing. Run /go to continue."
    tmux send-keys -t cc-coordinator "Completed $MAX_TASKS tasks in auto-run. Pausing. User can /go to continue." Enter 2>/dev/null || true
    exit 0
  fi

  if [ "$FAIL_COUNT" -ge "$MAX_FAILS" ]; then
    log "Too many consecutive failures ($MAX_FAILS). Stopping."
    tmux send-keys -t cc-coordinator "Auto-run stopped: $MAX_FAILS consecutive failures." Enter 2>/dev/null || true
    exit 1
  fi

  # Check coordinator session exists
  if ! tmux has-session -t cc-coordinator 2>/dev/null; then
    log "ERROR: cc-coordinator session not found. Exiting."
    exit 1
  fi

  # Pick next goal from GOALS.md
  if [ ! -f "$GOALS_FILE" ]; then
    log "No GOALS.md found. Triggering scan."
    tmux send-keys -t cc-coordinator "/scan" Enter 2>/dev/null || true
    sleep 60
    continue
  fi

  # Find first uncompleted goal (priority order in GOALS.md)
  next_goal=$(grep '^\- \[ \]' "$GOALS_FILE" | head -1 | sed 's/^- \[ \] //' || true)

  if [ -z "$next_goal" ]; then
    log "No pending goals. Triggering scan."
    tmux send-keys -t cc-coordinator "No pending goals found. Running /scan to discover new goals." Enter 2>/dev/null || true
    sleep 120
    next_goal=$(grep '^\- \[ \]' "$GOALS_FILE" 2>/dev/null | head -1 | sed 's/^- \[ \] //' || true)
    if [ -z "$next_goal" ]; then
      log "Still no goals after scan. All done!"
      tmux send-keys -t cc-coordinator "All goals completed! No more tasks to run." Enter 2>/dev/null || true
      exit 0
    fi
  fi

  log "Dispatching task: $next_goal"
  tmux send-keys -t cc-coordinator "AUTO-RUN: Implement this goal: $next_goal" Enter

  # Wait for task to complete
  log "Waiting for task completion..."
  sleep "$DELAY"

  TASK_COUNT=$((TASK_COUNT + 1))
  log "Task count: $TASK_COUNT/$MAX_TASKS"

  # Brief pause between tasks
  sleep 10
done
