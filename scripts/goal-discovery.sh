#!/bin/bash
# Scan project for potential improvements and generate goal suggestions
# Usage: goal-discovery.sh <project-path>
set -euo pipefail

PROJECT="${1:-.}"

if [ ! -d "$PROJECT" ]; then
  echo "Error: $PROJECT is not a directory"
  exit 1
fi

echo "# Goal Discovery — $(basename "$PROJECT")"
echo ""

# TODOs and FIXMEs
echo "## TODOs / FIXMEs"
TODOS=$(grep -rn 'TODO\|FIXME\|HACK\|XXX' "$PROJECT" --include='*.swift' --include='*.py' --include='*.ts' --include='*.js' --include='*.go' --include='*.rs' 2>/dev/null | grep -v node_modules | grep -v .git || true)
if [ -n "$TODOS" ]; then
  echo "$TODOS" | head -20 | while IFS= read -r line; do
    FILE=$(echo "$line" | cut -d: -f1 | sed "s|$PROJECT/||")
    TEXT=$(echo "$line" | grep -oE '(TODO|FIXME|HACK|XXX):?.*' | head -1)
    echo "- [ ] $FILE: $TEXT"
  done
else
  echo "  None found"
fi

echo ""

# Large files (>300 lines)
echo "## Large files (>300 lines)"
find "$PROJECT" -type f \( -name '*.swift' -o -name '*.py' -o -name '*.ts' -o -name '*.js' \) \
  ! -path '*/node_modules/*' ! -path '*/.git/*' ! -path '*/build/*' \
  -exec awk -v f={} 'END { if (NR > 300) printf "- [ ] Refactor %s (%d lines)\n", f, NR }' {} \; 2>/dev/null || true

echo ""

# Missing tests
echo "## Potential missing tests"
find "$PROJECT" -type f \( -name '*.swift' -o -name '*.py' -o -name '*.ts' \) \
  ! -path '*/test*' ! -path '*/Test*' ! -path '*Spec*' ! -path '*_test*' \
  ! -path '*/node_modules/*' ! -path '*/.git/*' 2>/dev/null | while read -r f; do
  BASE=$(basename "$f" | sed 's/\.[^.]*$//')
  if ! find "$PROJECT" -name "*${BASE}*test*" -o -name "*${BASE}*Test*" -o -name "*${BASE}*spec*" 2>/dev/null | grep -q .; then
    echo "- [ ] Add tests for $(echo "$f" | sed "s|$PROJECT/||")"
  fi
done | head -15

echo ""
echo "Run /scan in Claude Code for AI-powered analysis."
