#!/bin/bash
# memory-inject.sh — Auto-inject relevant memory context for an agent session.
# Called before agent startup or when agent receives a new task.
#
# Features:
#   - Multi-keyword search across all memory files
#   - Progressive disclosure: summary first, full detail on demand
#   - Token estimation for cost awareness
#
# Usage:
#   memory-inject.sh <keywords> [--full]         # search by keywords
#   memory-inject.sh --task "Refactor NetWorth"   # extract keywords from task description
#   memory-inject.sh --summary                    # show available memories overview
#
# Output: formatted context block for injection into agent prompt

set -euo pipefail

source "$HOME/agents/config.env" 2>/dev/null || true
MEMORY_DIR="${HOME}/agents/memory/${PROJECT_NAME:-default}/shared"
FULL_MODE=false
TASK_MODE=false
SUMMARY_MODE=false
KEYWORDS=""

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --full) FULL_MODE=true; shift ;;
    --task) TASK_MODE=true; KEYWORDS="$2"; shift 2 ;;
    --summary) SUMMARY_MODE=true; shift ;;
    *) KEYWORDS="$KEYWORDS $1"; shift ;;
  esac
done
KEYWORDS=$(echo "$KEYWORDS" | xargs) # trim

if [ "$SUMMARY_MODE" = true ]; then
  python3 -c "
import os, sys

memory_dir = sys.argv[1]
if not os.path.isdir(memory_dir):
    print('No memory directory found.')
    sys.exit(0)

total_lines = 0
files = {}
for f in sorted(os.listdir(memory_dir)):
    if not f.endswith('.md'): continue
    path = os.path.join(memory_dir, f)
    with open(path) as fh:
        lines = fh.readlines()
    entries = sum(1 for l in lines if l.startswith('## '))
    total_lines += len(lines)
    files[f] = {'lines': len(lines), 'entries': entries}

est_tokens = total_lines * 8  # rough estimate: ~8 tokens per line
print(f'📚 Memory: {len(files)} files, ~{total_lines} lines, ~{est_tokens} tokens')
for f, info in files.items():
    print(f'  {f}: {info[\"entries\"]} entries ({info[\"lines\"]} lines)')
" "$MEMORY_DIR"
  exit 0
fi

if [ -z "$KEYWORDS" ]; then
  echo "Usage: memory-inject.sh <keywords> [--full]"
  echo "       memory-inject.sh --task \"task description\""
  echo "       memory-inject.sh --summary"
  exit 1
fi

python3 -c "
import os, re, sys

memory_dir = sys.argv[1]
raw_keywords = sys.argv[2]
full_mode = sys.argv[3] == 'true'
task_mode = sys.argv[4] == 'true'

# Extract meaningful keywords from task description
def extract_keywords(text):
    # Remove common stop words, keep meaningful terms
    stop = {'the','a','an','to','in','for','of','and','or','is','are','was','were',
            'be','been','has','have','had','do','does','did','will','would','could',
            'should','may','might','can','this','that','these','those','it','its',
            'with','from','by','on','at','as','but','not','no','all','each','every',
            'add','implement','create','build','make','fix','update','refactor',
            'effort','pr','task','sub','views','loc','view','file','files','code',
            'new','use','using','into','app','data','model','type','list','item'}
    words = re.findall(r'[a-zA-Z]+', text)
    # Split CamelCase: SavingsGoalDetailView → savings, goal, detail, view
    expanded = []
    for w in words:
        parts = re.findall(r'[A-Z][a-z]+|[a-z]+', w)
        expanded.extend(p.lower() for p in parts)
    return [w for w in expanded if len(w) > 2 and w not in stop]

if task_mode:
    keywords = extract_keywords(raw_keywords)
else:
    keywords = raw_keywords.lower().split()

if not keywords:
    print('(no keywords to search)')
    sys.exit(0)

if not os.path.isdir(memory_dir):
    print('(no memory directory)')
    sys.exit(0)

# Search all memory files for entries matching keywords
MEMORY_FILES = ['lessons.md', 'successful_patterns.md', 'anti_patterns.md']

class MemoryEntry:
    def __init__(self, source, header, lines, score):
        self.source = source
        self.header = header
        self.lines = lines
        self.full_text = '\n'.join(lines)
        self.score = score
        self.tokens_est = len(self.full_text.split()) * 1.3  # rough token estimate

matches = []

for fname in MEMORY_FILES:
    path = os.path.join(memory_dir, fname)
    if not os.path.exists(path):
        continue

    with open(path) as f:
        content = f.read()

    # Split into entries by ## headers
    entries = re.split(r'^(## .+)$', content, flags=re.MULTILINE)

    i = 1
    while i < len(entries):
        header = entries[i].strip()
        body = entries[i+1].strip() if i+1 < len(entries) else ''
        i += 2

        # Score: count keyword matches in header + body
        combined = (header + ' ' + body).lower()
        score = 0
        for kw in keywords:
            # Exact match worth 2, substring worth 1
            if kw in combined:
                score += 2
            elif any(kw in word for word in combined.split()):
                score += 1

        # Need meaningful match: score >= 3 AND at least 1 keyword with 5+ chars matched
        long_kw_matched = any(kw in combined and len(kw) >= 5 for kw in keywords)
        if score >= 3 and long_kw_matched:
            source_label = fname.replace('.md','').replace('_',' ').title()
            body_lines = [l for l in body.split('\n') if l.strip()]
            matches.append(MemoryEntry(source_label, header, body_lines, score))

# Sort by score descending
matches.sort(key=lambda m: m.score, reverse=True)

if not matches:
    print(f'(no memories found for: {\" \".join(keywords)})')
    sys.exit(0)

# Progressive disclosure
total_tokens = sum(int(m.tokens_est) for m in matches)
summary_tokens = sum(min(40, int(m.tokens_est)) for m in matches[:5])

print(f'<memory-context keywords=\"{\" \".join(keywords)}\">')
print(f'  Found {len(matches)} related memories (~{total_tokens} tokens full, ~{summary_tokens} tokens summary)')
print()

if full_mode:
    # Full detail mode
    for i, m in enumerate(matches[:8]):
        print(f'  [{m.source}] {m.header}')
        for line in m.lines:
            print(f'    {line}')
        print()
else:
    # Summary mode — 1-line per entry, top 5
    for i, m in enumerate(matches[:5]):
        # Extract the most useful line (Lesson, Pattern, or first line)
        summary_line = ''
        for line in m.lines:
            if any(line.strip().startswith(prefix) for prefix in ['- Lesson:', '- Pattern:', '- Fix:', '- Error:', '- Anti-pattern:']):
                summary_line = line.strip().lstrip('- ')
                break
        if not summary_line and m.lines:
            summary_line = m.lines[0].strip().lstrip('- ')

        tag = '⚠️' if 'Anti' in m.source else '✅' if 'Success' in m.source else '📝'
        print(f'  {tag} [{m.source}] {m.header}')
        print(f'     {summary_line[:120]}')
        print()

    remaining = len(matches) - 5
    if remaining > 0:
        print(f'  ... +{remaining} more (use memory-inject.sh \"{\" \".join(keywords)}\" --full)')
    print()
    print(f'  💡 To load full context (~{total_tokens} tokens): memory-inject.sh \"{\" \".join(keywords)}\" --full')

print('</memory-context>')
" "$MEMORY_DIR" "$KEYWORDS" "$FULL_MODE" "$TASK_MODE"
