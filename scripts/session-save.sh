#!/bin/bash
# session-save.sh — Save current session state for recovery after restart
# Called automatically by agents before shutdown or periodically
set -euo pipefail
source "$HOME/agents/config.env"

STATE_FILE="$HOME/agents/session-state.json"

# Get current branch
BRANCH=$(cd "$PROJECT_PATH" && git branch --show-current 2>/dev/null || echo "unknown")

# Get uncommitted files
MODIFIED=$(cd "$PROJECT_PATH" && git diff --name-only 2>/dev/null | head -10 | tr '\n' ',' | sed 's/,$//')

# Get active tmux sessions
SESSIONS=""
for s in cc-coordinator cc-coder cc-reviewer; do
  if tmux has-session -t "$s" 2>/dev/null; then
    SESSIONS="$SESSIONS$s,"
  fi
done
SESSIONS="${SESSIONS%,}"

# Get active channel
CHANNEL=$(cat "$HOME/agents/active-channel.txt" 2>/dev/null || echo "unknown")

# Get current go-loop status
GO_LOOP="stopped"
if pgrep -f "go-loop.sh" >/dev/null 2>&1; then
  GO_LOOP="running"
fi

cat > "$STATE_FILE" << EOF
{
  "saved_at": "$(date '+%Y-%m-%dT%H:%M:%S')",
  "project": "$PROJECT_NAME",
  "branch": "$BRANCH",
  "modified_files": "$MODIFIED",
  "active_sessions": "$SESSIONS",
  "channel": "$CHANNEL",
  "go_loop": "$GO_LOOP"
}
EOF

echo "Session state saved to $STATE_FILE"
