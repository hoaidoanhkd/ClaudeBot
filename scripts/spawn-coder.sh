#!/bin/bash
# Spawn an additional coder agent for parallel work
# Usage: spawn-coder.sh "task description"
set -euo pipefail
source ~/agents/config.env

TASK="${1:-}"
if [ -z "$TASK" ]; then
  echo "Usage: $0 \"task description\""
  exit 1
fi

# Find next available session number
NUM=2
while tmux has-session -t "cc-coder-$NUM" 2>/dev/null; do
  NUM=$((NUM + 1))
done

SESSION="cc-coder-$NUM"
echo "Spawning $SESSION..."

tmux new-session -d -s "$SESSION" \
  "cd $PROJECT_PATH && claude --agent coder --dangerously-load-development-channels server:claude-peers"

sleep 8
tmux send-keys -t "$SESSION" Enter
sleep 2

# Send the task
tmux send-keys -t "$SESSION" "$TASK" Enter

echo "$SESSION started with task: $TASK"
echo "Attach: tmux attach -t $SESSION"
