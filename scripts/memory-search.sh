#!/bin/bash
# Search agent memory files
# Usage: memory-search.sh <query>
set -euo pipefail

QUERY="${1:-}"
if [ -z "$QUERY" ]; then
  echo "Usage: $0 <search-query>"
  exit 1
fi

MEMORY_DIR=~/agents/memory

if [ ! -d "$MEMORY_DIR" ]; then
  echo "No memory directory found at $MEMORY_DIR"
  exit 1
fi

echo "Searching memory for: $QUERY"
echo "─────────────────────────────"

grep -rn -i --color=auto -C 2 "$QUERY" "$MEMORY_DIR" 2>/dev/null || echo "No matches found."
