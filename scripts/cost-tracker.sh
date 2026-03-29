#!/bin/bash
# cost-tracker.sh — Estimate token cost per agent from session data
# Usage: cost-tracker.sh [--today | --week | --all]
set -euo pipefail
source "$HOME/agents/config.env"

PERIOD="${1:---today}"
MEMORY_DIR="$HOME/agents/memory/${PROJECT_NAME:-unknown}"

# Token cost estimates per model (USD per 1M tokens, input/output avg)
# Claude Max = flat subscription, but tracking helps understand usage
OPUS_COST=45    # $15 input + $75 output, avg ~$45/1M
SONNET_COST=12  # $3 input + $15 output, avg ~$12/1M
HAIKU_COST=2    # $0.25 input + $1.25 output, avg ~$2/1M

# Estimate tokens per task type
TOKENS_PER_TASK_COORDINATOR=50000
TOKENS_PER_TASK_CODER=200000
TOKENS_PER_TASK_REVIEWER=50000

echo "=== ClaudeBot Cost Estimate ==="
echo "Project: ${PROJECT_NAME:-unknown}"
echo "Period: $PERIOD"
echo ""

# Count tasks from lessons
LESSONS="$MEMORY_DIR/shared/lessons.md"
if [ ! -f "$LESSONS" ]; then
  echo "No lessons file found. Run some tasks first."
  exit 0
fi

case "$PERIOD" in
  --today)
    DATE_FILTER=$(date '+%Y-%m-%d')
    TASKS=$(grep "^## $DATE_FILTER" "$LESSONS" 2>/dev/null | wc -l | tr -d ' ')
    ;;
  --week)
    TASKS=0
    for i in 0 1 2 3 4 5 6; do
      D=$(date -v-${i}d '+%Y-%m-%d' 2>/dev/null || date -d "$i days ago" '+%Y-%m-%d')
      COUNT=$(grep "^## $D" "$LESSONS" 2>/dev/null | wc -l | tr -d ' ')
      TASKS=$((TASKS + COUNT))
    done
    ;;
  --all)
    TASKS=$(grep "^## " "$LESSONS" 2>/dev/null | wc -l | tr -d ' ')
    ;;
esac

SUCCESS=$(grep "SUCCESS" "$LESSONS" 2>/dev/null | wc -l | tr -d ' ')
FAIL=$(grep "FAIL" "$LESSONS" 2>/dev/null | wc -l | tr -d ' ')

echo "--- Tasks ---"
echo "  Total: $TASKS"
echo "  Success: $SUCCESS"
echo "  Failed: $FAIL"
echo ""

# Estimate tokens
TOTAL_COORDINATOR=$((TASKS * TOKENS_PER_TASK_COORDINATOR))
TOTAL_CODER=$((TASKS * TOKENS_PER_TASK_CODER))
TOTAL_REVIEWER=$((TASKS * TOKENS_PER_TASK_REVIEWER))
TOTAL_TOKENS=$((TOTAL_COORDINATOR + TOTAL_CODER + TOTAL_REVIEWER))

echo "--- Estimated Token Usage ---"
echo "  Coordinator (Sonnet): ~${TOTAL_COORDINATOR} tokens"
echo "  Coder (Opus):         ~${TOTAL_CODER} tokens"
echo "  Reviewer (Sonnet):    ~${TOTAL_REVIEWER} tokens"
echo "  Total:                ~${TOTAL_TOKENS} tokens"
echo ""

# Cost estimate (if using API, not Max subscription)
COST_COORDINATOR=$((TOTAL_COORDINATOR * SONNET_COST / 1000000))
COST_CODER=$((TOTAL_CODER * OPUS_COST / 1000000))
COST_REVIEWER=$((TOTAL_REVIEWER * SONNET_COST / 1000000))
COST_TOTAL=$((COST_COORDINATOR + COST_CODER + COST_REVIEWER))

echo "--- Estimated Cost (if API, not Max) ---"
echo "  Coordinator: ~\$${COST_COORDINATOR}"
echo "  Coder:       ~\$${COST_CODER}"
echo "  Reviewer:    ~\$${COST_REVIEWER}"
echo "  Total:       ~\$${COST_TOTAL}"
echo ""
echo "  Note: Claude Max subscription = flat rate, no per-token cost."
echo "  These estimates show what API usage would cost."
