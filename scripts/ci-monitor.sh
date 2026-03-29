#!/bin/bash
# Monitor GitHub Actions and alert on failures
set -euo pipefail
source ~/agents/config.env

INTERVAL="${CI_MONITOR_INTERVAL:-120}"
LAST_SEEN=""

echo "CI Monitor started for $GITHUB_REPO (interval: ${INTERVAL}s)"

while true; do
  # Get latest run
  RUN=$(gh run list --repo "$GITHUB_REPO" --limit 1 --json databaseId,status,conclusion,headBranch,name 2>/dev/null || true)

  if [ -n "$RUN" ]; then
    ID=$(echo "$RUN" | jq -r '.[0].databaseId // empty' 2>/dev/null || true)
    STATUS=$(echo "$RUN" | jq -r '.[0].status // empty' 2>/dev/null || true)
    CONCLUSION=$(echo "$RUN" | jq -r '.[0].conclusion // empty' 2>/dev/null || true)
    BRANCH=$(echo "$RUN" | jq -r '.[0].headBranch // empty' 2>/dev/null || true)

    if [ "$ID" != "$LAST_SEEN" ] && [ "$STATUS" = "completed" ] && [ "$CONCLUSION" = "failure" ]; then
      echo "[$(date)] CI FAILED on $BRANCH (run $ID)"
      tmux send-keys -t cc-coordinator "CI failed on branch $BRANCH (GitHub Actions run #$ID). Please investigate." Enter 2>/dev/null || true
      LAST_SEEN="$ID"
    fi
  fi

  sleep "$INTERVAL"
done
