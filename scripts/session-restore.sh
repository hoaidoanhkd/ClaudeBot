#!/bin/bash
# session-restore.sh — Show last session state for recovery
# Called on startup to help agents resume where they left off
set -euo pipefail

STATE_FILE="$HOME/agents/session-state.json"

if [ ! -f "$STATE_FILE" ]; then
  echo "No saved session state."
  exit 0
fi

echo "=== Last Session State ==="
cat "$STATE_FILE" | python3 -m json.tool 2>/dev/null || cat "$STATE_FILE"
echo ""

# Check if there's uncommitted work
MODIFIED=$(python3 -c "import json; d=json.load(open('$STATE_FILE')); print(d.get('modified_files',''))" 2>/dev/null || true)
if [ -n "$MODIFIED" ]; then
  echo "⚠️  Uncommitted files from last session: $MODIFIED"
  echo "   Consider: git stash or continue working on them"
fi

BRANCH=$(python3 -c "import json; d=json.load(open('$STATE_FILE')); print(d.get('branch',''))" 2>/dev/null || true)
if [ "$BRANCH" != "main" ] && [ -n "$BRANCH" ]; then
  echo "📌 Last branch: $BRANCH (not main)"
fi

GO_LOOP=$(python3 -c "import json; d=json.load(open('$STATE_FILE')); print(d.get('go_loop',''))" 2>/dev/null || true)
if [ "$GO_LOOP" = "running" ]; then
  echo "🔄 Go-loop was running. Resume with /go"
fi
