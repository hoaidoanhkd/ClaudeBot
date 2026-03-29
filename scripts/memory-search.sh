#!/bin/bash
# memory-search.sh — Searches agent memory files in ~/agents/memory/.
# Takes a search query as argument. Outputs matching lines with context.
set -euo pipefail

QUERY="${1:-}"
MEMORY_DIR="$HOME/agents/memory"

if [ -z "$QUERY" ]; then
  echo "Usage: $0 <search-query>"
  echo "Searches all memory files in $MEMORY_DIR"
  exit 1
fi

if [ ! -d "$MEMORY_DIR" ]; then
  echo "No memory directory found at $MEMORY_DIR"
  exit 0
fi

echo "=== Memory Search: \"$QUERY\" ==="
echo ""

found=0
for f in "$MEMORY_DIR"/*.md; do
  if [ ! -f "$f" ]; then continue; fi

  results=$(grep -in -C 2 "$QUERY" "$f" 2>/dev/null) || true
  if [ -n "$results" ]; then
    echo "--- $(basename "$f") ---"
    echo "$results"
    echo ""
    found=$((found + 1))
  fi
done

# Also search GOALS.md
GOALS_FILE="$HOME/agents/GOALS.md"
if [ -f "$GOALS_FILE" ]; then
  results=$(grep -in -C 1 "$QUERY" "$GOALS_FILE" 2>/dev/null) || true
  if [ -n "$results" ]; then
    echo "--- GOALS.md ---"
    echo "$results"
    echo ""
    found=$((found + 1))
  fi
fi

# Also search global cross-project memory
GLOBAL_DIR="$HOME/agents/memory/global"
if [ -d "$GLOBAL_DIR" ]; then
  for f in "$GLOBAL_DIR"/*.md; do
    if [ ! -f "$f" ]; then continue; fi
    results=$(grep -in -C 2 "$QUERY" "$f" 2>/dev/null) || true
    if [ -n "$results" ]; then
      echo "--- [GLOBAL] $(basename "$f") ---"
      echo "$results"
      echo ""
      found=$((found + 1))
    fi
  done
fi

if [ "$found" -eq 0 ]; then
  echo "(no results found)"
fi

echo "=== $found file(s) matched ==="
