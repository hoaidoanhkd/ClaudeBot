#!/bin/bash
# agent-stats.sh — Shows statistics: agent uptime, goals progress, PR count, and more.
# Sources ~/agents/config.env for project settings.
set -euo pipefail

source "$HOME/agents/config.env"

echo "=== Agent Statistics ==="
echo "Project: $PROJECT_NAME"
echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Agent uptime
echo "--- Agent Uptime ---"
for session in cc-coordinator cc-coder cc-reviewer; do
  if tmux has-session -t "$session" 2>/dev/null; then
    created=$(tmux display-message -t "$session" -p '#{session_created}' 2>/dev/null) || true
    if [ -n "$created" ]; then
      now=$(date +%s)
      elapsed=$((now - created))
      hours=$((elapsed / 3600))
      mins=$(( (elapsed % 3600) / 60 ))
      echo "  $session: ${hours}h ${mins}m"
    else
      echo "  $session: running (uptime unknown)"
    fi
  else
    echo "  $session: not running"
  fi
done

echo ""

# Goals progress
echo "--- Goals Progress ---"
GOALS_FILE="$HOME/agents/GOALS.md"
if [ -f "$GOALS_FILE" ]; then
  total=$(grep -c '^\- \[' "$GOALS_FILE" 2>/dev/null) || total=0
  done_count=$(grep -c '^\- \[x\]' "$GOALS_FILE" 2>/dev/null) || done_count=0
  pending=$((total - done_count))
  echo "  Total:     $total"
  echo "  Completed: $done_count"
  echo "  Pending:   $pending"
else
  echo "  GOALS.md not found"
fi

echo ""

# GitHub stats
echo "--- GitHub Stats ---"
if command -v gh &>/dev/null && [ -n "${GITHUB_REPO:-}" ]; then
  open_prs=$(gh pr list --repo "$GITHUB_REPO" --state open --json number --jq length 2>/dev/null) || open_prs="?"
  merged_prs=$(gh pr list --repo "$GITHUB_REPO" --state merged --json number --jq length 2>/dev/null) || merged_prs="?"
  echo "  PRs open:   $open_prs"
  echo "  PRs merged: $merged_prs"

  open_issues=$(gh issue list --repo "$GITHUB_REPO" --state open --json number --jq length 2>/dev/null) || open_issues="?"
  closed_issues=$(gh issue list --repo "$GITHUB_REPO" --state closed --json number --jq length 2>/dev/null) || closed_issues="?"
  echo "  Issues open:   $open_issues"
  echo "  Issues closed: $closed_issues"

  latest_run=$(gh run list --repo "$GITHUB_REPO" --limit 1 --json status,conclusion,name --jq '.[0] | "\(.name): \(.status) (\(.conclusion // "pending"))"' 2>/dev/null) || latest_run="?"
  echo "  Latest CI: $latest_run"
else
  echo "  gh CLI not available or GITHUB_REPO not set"
fi

echo ""

# Commit stats (last 7 days)
echo "--- Commits (last 7 days) ---"
if [ -d "$PROJECT_PATH/.git" ]; then
  commit_count=$(cd "$PROJECT_PATH" && git log --oneline --since="7 days ago" 2>/dev/null | wc -l | tr -d ' ') || commit_count=0
  echo "  Count: $commit_count"
else
  echo "  Not a git repo"
fi

echo ""

# Watchdog restarts
echo "--- Watchdog Restarts ---"
WATCHDOG_LOG="$HOME/logs/agent-watchdog.log"
if [ -f "$WATCHDOG_LOG" ]; then
  restart_count=$(grep -c "RESTART:" "$WATCHDOG_LOG" 2>/dev/null) || restart_count=0
  echo "  Total restarts: $restart_count"
else
  echo "  No watchdog log found"
fi

echo ""

# Knowledge base
echo "--- Knowledge Base ---"
MEMORY_DIR="$HOME/agents/memory"
if [ -d "$MEMORY_DIR" ]; then
  for f in "$MEMORY_DIR"/*.md; do
    if [ -f "$f" ]; then
      name=$(basename "$f" .md)
      lines=$(wc -l < "$f" | tr -d ' ')
      echo "  $name: ${lines} lines"
    fi
  done
else
  echo "  Memory directory not found"
fi

echo ""
echo "=========================="
