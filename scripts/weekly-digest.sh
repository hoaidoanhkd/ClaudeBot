#!/bin/bash
# weekly-digest.sh — Generates a weekly summary of commits, PRs merged, and goals completed.
# Uses git log for commit history, gh for PR data.
# Sources ~/agents/config.env for project settings.
set -euo pipefail

source "$HOME/agents/config.env"

SINCE="7 days ago"
OUTPUT_FILE="${1:-}"

generate_digest() {
  echo "# Weekly Digest"
  echo "**Project:** $PROJECT_NAME"
  echo "**Period:** $(date -v-7d '+%Y-%m-%d' 2>/dev/null || date -d '7 days ago' '+%Y-%m-%d') to $(date '+%Y-%m-%d')"
  echo "**Generated:** $(date '+%Y-%m-%d %H:%M:%S')"
  echo ""

  # Commits
  echo "## Commits"
  if [ -d "$PROJECT_PATH/.git" ]; then
    commit_count=$(cd "$PROJECT_PATH" && git log --oneline --since="$SINCE" 2>/dev/null | wc -l | tr -d ' ') || commit_count=0
    echo "**Total:** $commit_count commits"
    echo ""
    if [ "$commit_count" -gt 0 ]; then
      echo '```'
      (cd "$PROJECT_PATH" && git log --oneline --since="$SINCE" 2>/dev/null | head -20)
      echo '```'
      if [ "$commit_count" -gt 20 ]; then
        echo "_(showing 20 of $commit_count)_"
      fi
    fi
  else
    echo "Not a git repo at $PROJECT_PATH"
  fi
  echo ""

  # PRs merged
  echo "## Pull Requests Merged"
  if command -v gh &>/dev/null && [ -n "${GITHUB_REPO:-}" ]; then
    merged_prs=$(gh pr list --repo "$GITHUB_REPO" --state merged --json number,title,mergedAt 2>/dev/null) || merged_prs="[]"

    pr_count=$(echo "$merged_prs" | grep -c '"number"' 2>/dev/null) || pr_count=0
    echo "**Total:** $pr_count PRs merged (recent)"
    echo ""
    if [ "$pr_count" -gt 0 ]; then
      echo "$merged_prs" | grep -o '"number":[0-9]*\|"title":"[^"]*"' | paste - - | while read -r line; do
        num=$(echo "$line" | grep -o '[0-9]*' | head -1)
        title=$(echo "$line" | grep -o '"title":"[^"]*"' | cut -d'"' -f4)
        echo "- #$num $title"
      done
    fi
  else
    echo "gh CLI not available or GITHUB_REPO not set"
  fi
  echo ""

  # Goals progress
  echo "## Goals Progress"
  GOALS_FILE="$HOME/agents/GOALS.md"
  if [ -f "$GOALS_FILE" ]; then
    total=$(grep -c '^\- \[' "$GOALS_FILE" 2>/dev/null) || total=0
    completed=$(grep -c '^\- \[x\]' "$GOALS_FILE" 2>/dev/null) || completed=0
    pending=$((total - completed))
    echo "- **Completed:** $completed"
    echo "- **Pending:** $pending"
    echo "- **Total:** $total"
    echo ""
    if [ "$completed" -gt 0 ]; then
      echo "### Recently Completed"
      grep '^\- \[x\]' "$GOALS_FILE" | head -10 | sed 's/^- \[x\] /- /'
    fi
  else
    echo "No GOALS.md found"
  fi
  echo ""

  # Agent stats
  echo "## Agent Activity"
  WATCHDOG_LOG="$HOME/logs/agent-watchdog.log"
  if [ -f "$WATCHDOG_LOG" ]; then
    restarts=$(grep -c "RESTART:" "$WATCHDOG_LOG" 2>/dev/null) || restarts=0
    echo "- Watchdog restarts: $restarts"
  fi
  echo "- Agents: coordinator, coder, reviewer"
  echo ""
}

if [ -n "$OUTPUT_FILE" ]; then
  generate_digest > "$OUTPUT_FILE"
  echo "Digest written to $OUTPUT_FILE"
else
  generate_digest
fi
