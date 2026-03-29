#!/bin/bash
# repo-map.sh — Generate a project map for agents to understand the codebase
# Usage: repo-map.sh <project-path> [output-file]
# Output: markdown file with file tree, key files, functions, and relationships
set -euo pipefail

PROJECT="${1:-.}"
OUTPUT="${2:-}"

if [ ! -d "$PROJECT" ]; then
  echo "Error: $PROJECT is not a directory"
  exit 1
fi

generate_map() {
  echo "# Repo Map — $(basename "$PROJECT")"
  echo "Generated: $(date '+%Y-%m-%d %H:%M')"
  echo ""

  # File count by type
  echo "## Overview"
  for ext in swift ts js py go rs java kt rb; do
    count=$(find "$PROJECT" -name "*.$ext" -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/build/*' -not -path '*/.build/*' -not -path '*/Pods/*' -not -path '*/.claude/*' 2>/dev/null | wc -l | tr -d ' ')
    if [ "$count" -gt 0 ]; then
      echo "- $ext: $count files"
    fi
  done
  echo ""

  # File tree (max 3 levels deep, ignore common noise)
  echo "## File Tree"
  echo '```'
  find "$PROJECT" -maxdepth 3 -type f \
    \( -name '*.swift' -o -name '*.ts' -o -name '*.js' -o -name '*.py' -o -name '*.go' -o -name '*.rs' -o -name '*.md' \) \
    -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/build/*' \
    -not -path '*/.build/*' -not -path '*/Pods/*' -not -path '*/.claude/*' \
    2>/dev/null | sed "s|$PROJECT/||" | sort
  echo '```'
  echo ""

  # Key files with line counts
  echo "## Key Files (by size)"
  find "$PROJECT" -type f \
    \( -name '*.swift' -o -name '*.ts' -o -name '*.js' -o -name '*.py' -o -name '*.go' \) \
    -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/build/*' \
    -not -path '*/.build/*' -not -path '*/Pods/*' -not -path '*/.claude/*' \
    2>/dev/null | while read -r f; do
    lines=$(wc -l < "$f" | tr -d ' ')
    echo "$lines $f"
  done | sort -rn | head -20 | while read -r lines file; do
    echo "- $(echo "$file" | sed "s|$PROJECT/||") ($lines lines)"
  done
  echo ""

  # Classes/Structs/Functions (Swift)
  if find "$PROJECT" -name '*.swift' -not -path '*/.git/*' 2>/dev/null | grep -q .; then
    echo "## Definitions (Swift)"
    find "$PROJECT" -name '*.swift' -not -path '*/.git/*' -not -path '*/.claude/*' -not -path '*/build/*' 2>/dev/null | while read -r f; do
      defs=$(grep -nE '^\s*(class |struct |enum |protocol |actor |func |@Observable|@Model)' "$f" 2>/dev/null | head -10)
      if [ -n "$defs" ]; then
        echo "### $(echo "$f" | sed "s|$PROJECT/||")"
        echo "$defs" | while IFS= read -r line; do
          echo "  - $line"
        done
      fi
    done
    echo ""
  fi

  # TypeScript/JavaScript
  if find "$PROJECT" -name '*.ts' -o -name '*.js' -not -path '*/node_modules/*' 2>/dev/null | grep -q .; then
    echo "## Definitions (TypeScript/JavaScript)"
    find "$PROJECT" \( -name '*.ts' -o -name '*.js' \) -not -path '*/node_modules/*' -not -path '*/.git/*' 2>/dev/null | while read -r f; do
      defs=$(grep -nE '^\s*(export |class |function |const .* = |interface |type )' "$f" 2>/dev/null | head -10)
      if [ -n "$defs" ]; then
        echo "### $(echo "$f" | sed "s|$PROJECT/||")"
        echo "$defs" | while IFS= read -r line; do
          echo "  - $line"
        done
      fi
    done
    echo ""
  fi

  # Python
  if find "$PROJECT" -name '*.py' -not -path '*/.git/*' 2>/dev/null | grep -q .; then
    echo "## Definitions (Python)"
    find "$PROJECT" -name '*.py' -not -path '*/.git/*' -not -path '*/venv/*' 2>/dev/null | while read -r f; do
      defs=$(grep -nE '^\s*(class |def |async def )' "$f" 2>/dev/null | head -10)
      if [ -n "$defs" ]; then
        echo "### $(echo "$f" | sed "s|$PROJECT/||")"
        echo "$defs" | while IFS= read -r line; do
          echo "  - $line"
        done
      fi
    done
    echo ""
  fi

  # Dependencies
  echo "## Dependencies"
  if [ -f "$PROJECT/package.json" ]; then
    echo "### package.json"
    grep -A 50 '"dependencies"' "$PROJECT/package.json" 2>/dev/null | grep '"' | head -15 | sed 's/^/  /'
  fi
  if [ -f "$PROJECT/Podfile" ]; then
    echo "### Podfile"
    grep "pod '" "$PROJECT/Podfile" 2>/dev/null | head -10 | sed 's/^/  /'
  fi
  if [ -f "$PROJECT/requirements.txt" ]; then
    echo "### requirements.txt"
    head -15 "$PROJECT/requirements.txt" | sed 's/^/  /'
  fi
  if [ -f "$PROJECT/Package.swift" ]; then
    echo "### Package.swift"
    grep -E '\.package|\.product' "$PROJECT/Package.swift" 2>/dev/null | head -10 | sed 's/^/  /'
  fi
}

if [ -n "$OUTPUT" ]; then
  generate_map > "$OUTPUT"
  echo "Repo map saved to $OUTPUT"
else
  generate_map
fi
