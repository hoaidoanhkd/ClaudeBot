#!/bin/bash
# rollback.sh — Revert a merged PR and create revert PR
# Usage: rollback.sh <PR_NUMBER>
set -euo pipefail
source "$HOME/agents/config.env"

PR_NUM="${1:-}"
if [ -z "$PR_NUM" ]; then
  echo "Usage: $0 <PR_NUMBER>"
  exit 1
fi

echo "=== Rollback PR #$PR_NUM ==="

# Get PR info
MERGE_SHA=$(gh pr view "$PR_NUM" --repo "$GITHUB_REPO" --json mergeCommit --jq '.mergeCommit.oid' 2>/dev/null)
PR_TITLE=$(gh pr view "$PR_NUM" --repo "$GITHUB_REPO" --json title --jq '.title' 2>/dev/null)

if [ -z "$MERGE_SHA" ]; then
  echo "Error: PR #$PR_NUM not found or not merged"
  exit 1
fi

echo "Reverting: $PR_TITLE ($MERGE_SHA)"

# Ensure on main and up to date
cd "$PROJECT_PATH"
git checkout main
git pull origin main

# Create revert branch
BRANCH="revert/pr-$PR_NUM"
git checkout -b "$BRANCH"

# Revert the merge commit
if git revert --no-edit -m 1 "$MERGE_SHA"; then
  echo "Revert commit created"
else
  echo "Error: Could not revert. May need manual resolution."
  exit 1
fi

# Push and create PR
git push -u origin "$BRANCH"
gh pr create --repo "$GITHUB_REPO" \
  --title "Revert PR #$PR_NUM: $PR_TITLE" \
  --body "Automated rollback of PR #$PR_NUM.

Reason: Reverted by /rollback command.

Original PR: #$PR_NUM" \
  --base main

echo ""
echo "Revert PR created. Review and merge to complete rollback."
