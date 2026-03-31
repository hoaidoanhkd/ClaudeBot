#!/bin/bash
# branch-memory.sh — Per-branch memory context manager.
# Detects current git branch and loads/saves branch-specific notes.
#
# Usage:
#   branch-memory.sh load              # Load current branch's memory (inject into stdout)
#   branch-memory.sh save "notes"      # Save notes for current branch
#   branch-memory.sh switch            # Called on branch switch — swap context
#   branch-memory.sh list              # List all branches with saved memory
#   branch-memory.sh detect "bash_cmd" # Check if a bash command is a branch switch
#
# Storage: ~/agents/memory/$PROJECT_NAME/branches/<branch-name>.md
# Called by PostToolUse hook on Bash tool calls containing git checkout/switch.

set -euo pipefail

source "$HOME/agents/config.env" 2>/dev/null || true
PROJECT_PATH="${PROJECT_PATH:-$(pwd)}"
PROJECT_NAME="${PROJECT_NAME:-default}"
BRANCH_DIR="$HOME/agents/memory/$PROJECT_NAME/branches"
mkdir -p "$BRANCH_DIR"

get_branch() {
  cd "$PROJECT_PATH" 2>/dev/null && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown"
}

ACTION="${1:-load}"
shift 2>/dev/null || true

case "$ACTION" in
  detect)
    # Check if a bash command triggers a branch switch
    CMD="${1:-}"
    if echo "$CMD" | grep -qE "git (checkout|switch|worktree add)\s"; then
      echo '{"branch_switch": true}'
      exit 0
    fi
    echo '{"branch_switch": false}'
    exit 0
    ;;

  load)
    BRANCH=$(get_branch)
    BRANCH_FILE="$BRANCH_DIR/${BRANCH//\//_}.md"

    if [ -f "$BRANCH_FILE" ]; then
      echo "<branch-context branch=\"$BRANCH\">"
      cat "$BRANCH_FILE"
      echo "</branch-context>"
    else
      echo "<branch-context branch=\"$BRANCH\">"
      echo "  No saved context for branch '$BRANCH'."
      echo "  Save notes: ~/Desktop/Projects/ClaudeBot/scripts/branch-memory.sh save \"your notes here\""
      echo "</branch-context>"
    fi
    ;;

  save)
    BRANCH=$(get_branch)
    BRANCH_FILE="$BRANCH_DIR/${BRANCH//\//_}.md"
    NOTES="${1:-}"

    if [ -z "$NOTES" ]; then
      echo "Usage: branch-memory.sh save \"notes about current work on this branch\""
      exit 1
    fi

    # Append with timestamp
    {
      echo ""
      echo "## $(date '+%Y-%m-%d %H:%M') — $BRANCH"
      echo "$NOTES"
    } >> "$BRANCH_FILE"

    echo "Saved to $BRANCH_FILE"
    ;;

  switch)
    # Called after a branch switch is detected
    # 1. Save current state summary to old branch
    # 2. Load new branch's memory
    BRANCH=$(get_branch)
    BRANCH_FILE="$BRANCH_DIR/${BRANCH//\//_}.md"

    echo "<branch-switch to=\"$BRANCH\">"
    if [ -f "$BRANCH_FILE" ]; then
      echo "  Loaded context for branch '$BRANCH':"
      tail -20 "$BRANCH_FILE" | sed 's/^/  /'
    else
      echo "  New branch '$BRANCH' — no saved context."
    fi
    echo "</branch-switch>"
    ;;

  list)
    echo "📂 Branch memories for $PROJECT_NAME:"
    for f in "$BRANCH_DIR"/*.md; do
      [ -f "$f" ] || continue
      name=$(basename "$f" .md | tr '_' '/')
      lines=$(wc -l < "$f" | tr -d ' ')
      last=$(stat -f '%Sm' -t '%Y-%m-%d' "$f" 2>/dev/null || date -r "$f" '+%Y-%m-%d' 2>/dev/null || echo "?")
      echo "  $name — $lines lines (last: $last)"
    done
    ;;

  *)
    echo "Usage: branch-memory.sh [load|save|switch|list|detect]"
    exit 1
    ;;
esac
