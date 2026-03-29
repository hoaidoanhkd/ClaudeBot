#!/bin/bash
# Generate weekly summary: commits, PRs, goals
# Usage: weekly-digest.sh [--output file.md]
set -euo pipefail
source ~/agents/config.env

OUTPUT=""
if [ "${1:-}" = "--output" ] && [ -n "${2:-}" ]; then
  OUTPUT="$2"
fi

digest() {
  echo "# Weekly Digest — $PROJECT_NAME"
  echo "**$(date -v-7d +%Y-%m-%d 2>/dev/null || date -d '7 days ago' +%Y-%m-%d) to $(date +%Y-%m-%d)**"
  echo ""

  # Commits
  echo "## Commits"
  if [ -d "$PROJECT_PATH/.git" ]; then
    COUNT=$(cd "$PROJECT_PATH" && git log --oneline --since="7 days ago" 2>/dev/null | wc -l | tr -d ' ')
    echo "- **$COUNT** commits this week"
    echo ""
    cd "$PROJECT_PATH" && git log --oneline --since="7 days ago" 2>/dev/null | head -15 | while read -r line; do
      echo "  - $line"
    done
  else
    echo "- Project not found"
  fi

  echo ""

  # PRs
  echo "## Pull Requests"
  if command -v gh &>/dev/null; then
    MERGED=$(gh pr list --repo "$GITHUB_REPO" --state merged --limit 20 --json title,number,mergedAt 2>/dev/null || echo "[]")
    MERGED_COUNT=$(echo "$MERGED" | jq length 2>/dev/null || echo "0")
    echo "- **$MERGED_COUNT** PRs merged"
    echo "$MERGED" | jq -r '.[] | "  - #\(.number) \(.title)"' 2>/dev/null || true
  else
    echo "- gh CLI not available"
  fi

  echo ""

  # Goals
  echo "## Goals"
  if [ -f ~/agents/GOALS.md ]; then
    TOTAL=$(grep -c '^\- \[' ~/agents/GOALS.md 2>/dev/null || echo "0")
    DONE=$(grep -c '^\- \[x\]' ~/agents/GOALS.md 2>/dev/null || echo "0")
    echo "- **$DONE/$TOTAL** goals completed"
  else
    echo "- No GOALS.md"
  fi
}

if [ -n "$OUTPUT" ]; then
  digest > "$OUTPUT"
  echo "Digest saved to $OUTPUT"
else
  digest
fi
