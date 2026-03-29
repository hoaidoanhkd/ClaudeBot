#!/bin/bash
# ci-monitor.sh — Monitors GitHub Actions runs for the configured repo.
# Alerts coordinator via tmux if a run fails.
# Sources ~/agents/config.env for GITHUB_REPO and CI_MONITOR_INTERVAL.
set -euo pipefail

source "$HOME/agents/config.env"

INTERVAL="${CI_MONITOR_INTERVAL:-120}"
LAST_SEEN_FILE="/tmp/ci-monitor-last-seen"

if [ -z "${GITHUB_REPO:-}" ]; then
  echo "ERROR: GITHUB_REPO not set in config.env"
  exit 1
fi

if ! command -v gh &>/dev/null; then
  echo "ERROR: gh CLI not installed"
  exit 1
fi

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

log "CI Monitor started (repo: $GITHUB_REPO, interval: ${INTERVAL}s)"

# Initialize last seen run ID
touch "$LAST_SEEN_FILE"
last_seen_id=$(cat "$LAST_SEEN_FILE" 2>/dev/null || echo "")

while true; do
  # Get latest completed run
  run_json=$(gh run list --repo "$GITHUB_REPO" --limit 1 --json databaseId,status,conclusion,name,headBranch 2>/dev/null) || run_json="[]"

  if [ "$run_json" != "[]" ] && [ -n "$run_json" ]; then
    run_id=$(echo "$run_json" | grep -o '"databaseId":[0-9]*' | head -1 | cut -d: -f2) || run_id=""
    conclusion=$(echo "$run_json" | grep -o '"conclusion":"[^"]*"' | head -1 | cut -d'"' -f4) || conclusion=""
    name=$(echo "$run_json" | grep -o '"name":"[^"]*"' | head -1 | cut -d'"' -f4) || name=""
    branch=$(echo "$run_json" | grep -o '"headBranch":"[^"]*"' | head -1 | cut -d'"' -f4) || branch=""

    # Only alert on new failed runs
    if [ -n "$run_id" ] && [ "$run_id" != "$last_seen_id" ]; then
      if [ "$conclusion" = "failure" ]; then
        log "CI FAILED: $name on $branch (run $run_id)"
        if tmux has-session -t cc-coordinator 2>/dev/null; then
          tmux send-keys -t cc-coordinator "CI FAILED: $name on branch $branch (run #$run_id). Please investigate and fix." Enter
        fi
      elif [ "$conclusion" = "success" ]; then
        log "CI passed: $name on $branch (run $run_id)"
      else
        log "CI status: $conclusion for $name on $branch"
      fi
      echo "$run_id" > "$LAST_SEEN_FILE"
      last_seen_id="$run_id"
    fi
  fi

  sleep "$INTERVAL"
done
