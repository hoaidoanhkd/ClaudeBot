#!/bin/bash
# Auto-run loop: pick goals from GOALS.md and dispatch to coordinator
# Stop by: touch /tmp/go-loop-stop
set -euo pipefail
source ~/agents/config.env

DELAY="${1:-120}"
GOALS_FILE=~/agents/GOALS.md
STOP_FILE=/tmp/go-loop-stop

rm -f "$STOP_FILE"
echo "Go-loop started (delay: ${DELAY}s between tasks)"
echo "Stop with: touch /tmp/go-loop-stop"

while [ ! -f "$STOP_FILE" ]; do
  # Pick next unchecked goal
  GOAL=$(grep '^\- \[ \]' "$GOALS_FILE" 2>/dev/null | head -1 | sed 's/^- \[ \] //')

  if [ -z "$GOAL" ]; then
    echo "[$(date)] No pending goals. Waiting..."
    sleep "$DELAY"
    continue
  fi

  echo "[$(date)] Dispatching: $GOAL"
  tmux send-keys -t cc-coordinator "Implement this goal: $GOAL" Enter 2>/dev/null || {
    echo "[$(date)] Failed to send to coordinator. Is it running?"
    sleep "$DELAY"
    continue
  }

  sleep "$DELAY"
done

echo "Go-loop stopped."
rm -f "$STOP_FILE"
