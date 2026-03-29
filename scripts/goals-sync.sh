#!/bin/bash
# goals-sync.sh — Syncs ~/agents/GOALS.md with GitHub Issues.
# Flags: --push (local to GitHub), --pull (GitHub to local), --both
# Sources ~/agents/config.env for GITHUB_REPO.
set -euo pipefail

source "$HOME/agents/config.env"

GOALS_FILE="$HOME/agents/GOALS.md"
MODE="${1:---both}"

if [ -z "${GITHUB_REPO:-}" ]; then
  echo "ERROR: GITHUB_REPO not set in config.env"
  exit 1
fi

if ! command -v gh &>/dev/null; then
  echo "ERROR: gh CLI not installed"
  exit 1
fi

push_goals() {
  echo "--- Push: GOALS.md -> GitHub Issues ---"
  if [ ! -f "$GOALS_FILE" ]; then
    echo "No GOALS.md found at $GOALS_FILE"
    return
  fi

  local created=0
  local closed=0

  # Parse uncompleted goals
  while IFS= read -r line; do
    title=$(echo "$line" | sed 's/^- \[ \] //' | sed 's/ (#.*$//' | sed 's/ (Effort:.*//' | xargs)
    if [ -z "$title" ]; then continue; fi

    existing=$(gh issue list --repo "$GITHUB_REPO" --search "$title" --json number,title --jq '.[0].number' 2>/dev/null) || existing=""
    if [ -z "$existing" ]; then
      echo "  Creating issue: $title"
      gh issue create --repo "$GITHUB_REPO" --title "$title" --body "Auto-created from GOALS.md" 2>/dev/null || true
      created=$((created + 1))
    fi
  done < <(grep '^\- \[ \]' "$GOALS_FILE" 2>/dev/null || true)

  # Close issues for completed goals
  while IFS= read -r line; do
    title=$(echo "$line" | sed 's/^- \[x\] //' | sed 's/ (#.*$//' | sed 's/ (Effort:.*//' | xargs)
    if [ -z "$title" ]; then continue; fi

    issue_num=$(gh issue list --repo "$GITHUB_REPO" --state open --search "$title" --json number --jq '.[0].number' 2>/dev/null) || issue_num=""
    if [ -n "$issue_num" ]; then
      echo "  Closing issue #$issue_num: $title"
      gh issue close "$issue_num" --repo "$GITHUB_REPO" 2>/dev/null || true
      closed=$((closed + 1))
    fi
  done < <(grep '^\- \[x\]' "$GOALS_FILE" 2>/dev/null || true)

  echo "  Push complete: $created created, $closed closed"
}

pull_goals() {
  echo "--- Pull: GitHub Issues -> GOALS.md ---"

  local added=0

  issues=$(gh issue list --repo "$GITHUB_REPO" --state open --json number,title --jq '.[] | "#\(.number) \(.title)"' 2>/dev/null) || issues=""
  if [ -z "$issues" ]; then
    echo "  No open issues found"
    return
  fi

  if [ ! -f "$GOALS_FILE" ]; then
    echo "# Project Goals" > "$GOALS_FILE"
    echo "" >> "$GOALS_FILE"
  fi

  while IFS= read -r issue_line; do
    title=$(echo "$issue_line" | sed 's/^#[0-9]* //')
    if ! grep -qF "$title" "$GOALS_FILE" 2>/dev/null; then
      echo "  Adding goal: $issue_line"
      echo "- [ ] $issue_line" >> "$GOALS_FILE"
      added=$((added + 1))
    fi
  done <<< "$issues"

  echo "  Pull complete: $added goals added"
}

case "$MODE" in
  --push)
    push_goals
    ;;
  --pull)
    pull_goals
    ;;
  --both)
    push_goals
    echo ""
    pull_goals
    ;;
  *)
    echo "Usage: $0 [--push|--pull|--both]"
    exit 1
    ;;
esac
