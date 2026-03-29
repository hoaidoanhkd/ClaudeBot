#!/bin/bash
# spawn-coder.sh — Spawns an additional coder agent in a new tmux session.
# Usage: spawn-coder.sh <task-name> <task-description>
# Names sessions cc-coder-1, cc-coder-2, cc-coder-3 (max 3 parallel coders).
set -euo pipefail

source "$HOME/agents/config.env"

TASK_NAME="${1:-}"
TASK_DESC="${2:-}"

if [ -z "$TASK_NAME" ] || [ -z "$TASK_DESC" ]; then
  echo "Usage: $0 <task-name> <task-description>"
  echo "Example: $0 csv-export 'Implement CSV export in HistoryView'"
  exit 1
fi

# Find lowest free slot
SESSION=""
for i in 1 2 3; do
  candidate="cc-coder-$i"
  if ! tmux has-session -t "$candidate" 2>/dev/null; then
    SESSION="$candidate"
    break
  fi
done

if [ -z "$SESSION" ]; then
  echo "ERROR: All 3 parallel coder slots are busy (cc-coder-1, cc-coder-2, cc-coder-3)"
  echo "Kill a session first: tmux kill-session -t cc-coder-N"
  exit 1
fi

echo "Spawning parallel coder: $SESSION (task: $TASK_NAME)"

# Create tmux session with coder agent
tmux new-session -d -s "$SESSION" \
  "cd $PROJECT_PATH && claude --enable-auto-mode --agent coder --dangerously-load-development-channels server:claude-peers"

# Wait for agent to initialize
sleep 8
tmux send-keys -t "$SESSION" Enter 2>/dev/null || true
sleep 3

# Send the task as bootstrap message
tmux send-keys -t "$SESSION" "[PARALLEL-CODER] Task: $TASK_NAME. $TASK_DESC" Enter

echo "Parallel coder $SESSION started with task: $TASK_NAME"
echo "Monitor: tmux attach -t $SESSION"
