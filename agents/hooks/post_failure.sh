#!/bin/bash
# Post-failure hook: log errors to agent memory for future sessions
# Called by watchdog when an agent restarts after crash

AGENT_ROLE="${1:-unknown}"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
MEMORY_FILE="$HOME/agents/memory/${AGENT_ROLE}.md"
LOG_FILE="$HOME/logs/agent-errors.log"

# Log to error file
echo "[$TIMESTAMP] $AGENT_ROLE crashed and was restarted" >> "$LOG_FILE"

# Append to agent memory so it knows about the crash
if [[ -f "$MEMORY_FILE" ]]; then
  echo "" >> "$MEMORY_FILE"
  echo "## $TIMESTAMP — CRASH RECOVERY" >> "$MEMORY_FILE"
  echo "- Agent crashed and was auto-restarted by watchdog" >> "$MEMORY_FILE"
  echo "- Check previous task for potential cause" >> "$MEMORY_FILE"
fi
