#!/bin/bash
# agent-health.sh — Checks health of all agent sessions and the claude-peers broker.
# Outputs a formatted status report. Exit 0 if all healthy, exit 1 if any issues.
set -euo pipefail

HEALTHY=true

status_icon() {
  if [ "$1" = "ok" ]; then echo "OK"; else echo "FAIL"; fi
}

echo "=== Agent Health Report ==="
echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Check tmux sessions
echo "--- Tmux Sessions ---"
for session in cc-coordinator cc-coder cc-reviewer; do
  if tmux has-session -t "$session" 2>/dev/null; then
    pid=$(tmux list-panes -t "$session" -F '#{pane_pid}' 2>/dev/null | head -1)
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      echo "  $session: $(status_icon ok) (pid: $pid)"
    else
      echo "  $session: $(status_icon ok) (session exists, process unclear)"
    fi
  else
    echo "  $session: $(status_icon fail) (session not found)"
    HEALTHY=false
  fi
done

echo ""

# Check parallel coder sessions
echo "--- Parallel Coders ---"
parallel_found=false
for i in 1 2 3; do
  session="cc-coder-$i"
  if tmux has-session -t "$session" 2>/dev/null; then
    echo "  $session: $(status_icon ok)"
    parallel_found=true
  fi
done
if [ "$parallel_found" = false ]; then
  echo "  (none active)"
fi

echo ""

# Check claude-peers broker
echo "--- Claude Peers Broker ---"
if [ -d "$HOME/claude-peers-mcp" ]; then
  broker_status=$(cd "$HOME/claude-peers-mcp" && bun cli.ts status 2>&1) || true
  if echo "$broker_status" | grep -qi "running\|connected\|peer"; then
    echo "  Broker: $(status_icon ok)"
    echo "$broker_status" | sed 's/^/    /'
  else
    echo "  Broker: $(status_icon fail)"
    echo "$broker_status" | sed 's/^/    /'
    HEALTHY=false
  fi
else
  echo "  Broker: $(status_icon fail) (~/claude-peers-mcp not found)"
  HEALTHY=false
fi

echo ""

# Check daemon processes
echo "--- Daemons ---"
for daemon in agent-watchdog agent-keepalive ci-monitor; do
  pid=$(pgrep -f "${daemon}.sh" 2>/dev/null | head -1) || true
  if [ -n "$pid" ]; then
    echo "  $daemon: $(status_icon ok) (pid: $pid)"
  else
    echo "  $daemon: not running"
  fi
done

echo ""
echo "=========================="

if [ "$HEALTHY" = true ]; then
  echo "Overall: HEALTHY"
  exit 0
else
  echo "Overall: ISSUES DETECTED"
  exit 1
fi
