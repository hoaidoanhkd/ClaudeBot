#!/bin/bash
# goal-discovery.sh — Scans a project directory for potential improvements.
# Looks for TODO/FIXME comments, missing tests, code smells, large files.
# Takes project path as argument. Outputs suggestions for GOALS.md.
set -euo pipefail

PROJECT_DIR="${1:-.}"

if [ ! -d "$PROJECT_DIR" ]; then
  echo "ERROR: Directory not found: $PROJECT_DIR"
  exit 1
fi

echo "=== Goal Discovery Scan ==="
echo "Project: $PROJECT_DIR"
echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# 1. TODO/FIXME comments
echo "--- TODO/FIXME Comments ---"
todo_count=0
while IFS= read -r match; do
  echo "  $match"
  todo_count=$((todo_count + 1))
done < <(grep -rn 'TODO\|FIXME\|HACK\|XXX\|WORKAROUND' "$PROJECT_DIR" \
  --include='*.swift' --include='*.ts' --include='*.js' --include='*.py' \
  --include='*.go' --include='*.rs' --include='*.java' --include='*.kt' \
  --include='*.rb' --include='*.m' --include='*.h' \
  2>/dev/null | head -50 || true)
echo "  Count: $todo_count"
echo ""

# 2. Force unwraps (Swift specific)
echo "--- Force Unwraps (Swift) ---"
force_unwrap_count=0
while IFS= read -r match; do
  echo "  $match"
  force_unwrap_count=$((force_unwrap_count + 1))
done < <(grep -rn -E '\w+!\.' "$PROJECT_DIR" --include='*.swift' 2>/dev/null \
  | grep -v '// ' | grep -v 'IBOutlet' | grep -v 'IBAction' | head -30 || true)
# Also check force unwrap with subscript access (e.g., array![0])
while IFS= read -r match; do
  echo "  $match"
  force_unwrap_count=$((force_unwrap_count + 1))
done < <(grep -rn -E '\w+!\[' "$PROJECT_DIR" --include='*.swift' 2>/dev/null \
  | grep -v '// ' | grep -v 'IBOutlet' | grep -v 'IBAction' | head -30 || true)
echo "  Count: $force_unwrap_count"
echo ""

# 3. Large files (>300 lines)
echo "--- Large Files (>300 lines) ---"
large_count=0
while IFS= read -r file; do
  if [ -z "$file" ]; then continue; fi
  lines=$(wc -l < "$file" | tr -d ' ')
  if [ "$lines" -gt 300 ]; then
    echo "  $file: $lines lines"
    large_count=$((large_count + 1))
  fi
done < <(find "$PROJECT_DIR" \( -name '*.swift' -o -name '*.ts' -o -name '*.js' -o -name '*.py' -o -name '*.go' \) \
  -not -path '*/.*' -not -path '*/node_modules/*' -not -path '*/build/*' \
  -not -path '*/Pods/*' -not -path '*/.build/*' 2>/dev/null || true)
echo "  Count: $large_count"
echo ""

# 4. Missing tests
echo "--- Test Coverage ---"
src_files=$(find "$PROJECT_DIR" \( -name '*.swift' -o -name '*.ts' -o -name '*.py' \) \
  -not -path '*Test*' -not -path '*test*' -not -path '*spec*' -not -path '*Spec*' \
  -not -path '*/.*' -not -path '*/node_modules/*' -not -path '*/build/*' \
  -not -path '*/Pods/*' 2>/dev/null | wc -l | tr -d ' ') || src_files=0
test_files=$(find "$PROJECT_DIR" \( -name '*Test*.swift' -o -name '*test*.ts' -o -name '*test*.py' -o -name '*spec*.ts' -o -name '*spec*.py' \) \
  -not -path '*/.*' -not -path '*/node_modules/*' 2>/dev/null | wc -l | tr -d ' ') || test_files=0
echo "  Source files: $src_files"
echo "  Test files:   $test_files"
ratio=0
if [ "$src_files" -gt 0 ]; then
  ratio=$((test_files * 100 / src_files))
  echo "  Test ratio:   ${ratio}%"
fi
echo ""

# 5. Empty function/method bodies
echo "--- Empty Bodies ---"
empty_count=$(grep -rn '{\s*}' "$PROJECT_DIR" \
  --include='*.swift' --include='*.ts' --include='*.js' \
  2>/dev/null | grep -v 'test' | grep -v 'spec' | wc -l | tr -d ' ') || empty_count=0
echo "  Empty blocks found: $empty_count"
echo ""

# 6. Hardcoded strings (potential localization issues)
echo "--- Hardcoded Strings (sample) ---"
grep -rn '"[A-Z][a-z].*"' "$PROJECT_DIR" \
  --include='*.swift' 2>/dev/null \
  | grep -v 'import\|///\|//\|print\|#Preview\|@\|Log\|key\|Key\|identifier\|Identifier' \
  | head -10 || echo "  (none found or not a Swift project)"
echo ""

# Summary
echo "=== Summary ==="
echo "TODO/FIXME:       $todo_count"
echo "Force unwraps:    $force_unwrap_count"
echo "Large files:      $large_count"
echo "Empty blocks:     $empty_count"
echo "Test ratio:       ${src_files} src / ${test_files} test"
echo ""
echo "=== Suggested Goals ==="
if [ "$todo_count" -gt 0 ]; then
  echo "- [ ] Resolve $todo_count TODO/FIXME comments (#completeness, Effort:M)"
fi
if [ "$force_unwrap_count" -gt 5 ]; then
  echo "- [ ] Remove force unwraps for crash safety (#stability, Effort:S)"
fi
if [ "$large_count" -gt 0 ]; then
  echo "- [ ] Refactor $large_count large files (>300 lines) (#quality, Effort:M)"
fi
if [ "$test_files" -eq 0 ] && [ "$src_files" -gt 0 ]; then
  echo "- [ ] Add unit tests (currently 0 test files) (#quality, Effort:L)"
elif [ "$src_files" -gt 0 ] && [ "$ratio" -lt 30 ]; then
  echo "- [ ] Improve test coverage (currently ${ratio}%) (#quality, Effort:M)"
fi
if [ "$empty_count" -gt 5 ]; then
  echo "- [ ] Implement $empty_count empty function bodies (#completeness, Effort:S)"
fi
