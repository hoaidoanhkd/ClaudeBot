#!/bin/bash
# goals-to-json.sh — Parse GOALS.md into JSON for the dashboard task board.
# Cross-references with merged PRs to auto-detect done tasks.
#
# GOALS.md format:
#   - [ ] Task description (Effort: S)   ← todo
#   - [x] Task description — PR #N       ← done (explicit)
#   - [~] Task description               ← in progress (explicit)
#
# Auto-detection:
#   - If a [ ] task has keywords matching a merged PR title → auto-mark as done
#   - Merged PRs fetched via `gh pr list` (cached 60s to avoid rate limits)
#
# Output: JSON to stdout

set -euo pipefail

GOALS_FILE="${1:-$HOME/agents/GOALS.md}"
PROJECT_PATH="${2:-$HOME/Desktop/Projects/BurnRate}"
PR_CACHE="/tmp/claudebot-merged-prs.json"
PR_CACHE_TTL=15  # seconds

if [ ! -f "$GOALS_FILE" ]; then
  echo '{"tasks":[],"categories":[],"stats":{"todo":0,"progress":0,"done":0}}'
  exit 0
fi

# Refresh merged PR cache if stale
if [ ! -f "$PR_CACHE" ] || [ "$(( $(date +%s) - $(stat -f %m "$PR_CACHE" 2>/dev/null || echo 0) ))" -gt "$PR_CACHE_TTL" ]; then
  cd "$PROJECT_PATH" 2>/dev/null && \
    gh pr list --state merged --limit 20 --json number,title,mergedAt > "$PR_CACHE" 2>/dev/null || \
    echo '[]' > "$PR_CACHE"
fi

python3 -c "
import json, re, sys, os

goals_path = sys.argv[1]
pr_cache = sys.argv[2]

# Read GOALS.md
with open(goals_path, 'r') as f:
    content = f.read()

# Read merged PRs
merged_prs = []
try:
    with open(pr_cache, 'r') as f:
        merged_prs = json.load(f)
except Exception:
    pass

# Build keyword index from merged PR titles for fuzzy matching
def title_keywords(title):
    # Extract significant words (>3 chars, lowercase)
    words = re.findall(r'[a-zA-Z]+', title.lower())
    return set(w for w in words if len(w) > 3)

pr_keyword_map = []
for pr in merged_prs:
    kws = title_keywords(pr.get('title', ''))
    pr_keyword_map.append({
        'number': pr['number'],
        'title': pr.get('title', ''),
        'merged': pr.get('mergedAt', ''),
        'keywords': kws,
    })

def match_pr(task_title):
    \"\"\"Find a merged PR that matches this task title (fuzzy keyword match).\"\"\"
    task_kws = title_keywords(task_title)
    best = None
    best_score = 0
    for pr in pr_keyword_map:
        overlap = task_kws & pr['keywords']
        # Need at least 2 matching words, and overlap must be >40% of task keywords
        score = len(overlap)
        if score >= 2 and score > best_score:
            best = pr
            best_score = score
    return best

# Parse GOALS.md
tasks = []
current_category = 'Uncategorized'
task_id = 0

for line in content.split('\n'):
    line = line.strip()

    # Category headers
    if line.startswith('## '):
        current_category = line[3:].strip()
        # Skip legend/header sections
        if any(w in current_category.lower() for w in ['legend', '---']):
            continue
        continue

    # Skip separator lines
    if line == '---':
        continue

    # Task lines: - [ ] , - [x] , - [~] , - [>]
    m = re.match(r'^-\s*\[([ x~>])\]\s*(.+)$', line)
    if not m:
        continue

    task_id += 1
    check = m.group(1)
    text = m.group(2).strip()

    # Determine column from checkbox
    if check == 'x':
        col = 'done'
    elif check in ('~', '>'):
        col = 'progress'
    else:
        col = 'todo'

    # Extract effort
    effort = 'S'
    em = re.search(r'Effort:\s*([SML])', text, re.I)
    if em:
        effort = em.group(1).upper()

    # Extract agent assignment
    agent = ''
    am = re.search(r'Agent:\s*(\w+)', text, re.I)
    if am:
        agent = am.group(1).lower()

    # Detect priority
    priority = 'normal'
    if '\u2b50' in text or 'Priority' in text:
        priority = 'high'
    elif 'Quick Win' in text:
        priority = 'quick'

    # Extract existing PR reference
    pr_ref = ''
    pm = re.search(r'PR\s*#(\d+)', text)
    if pm:
        pr_ref = pm.group(1)

    # Clean up display title
    title = re.sub(r'\s*\(Effort:\s*[SML]\)', '', text)
    title = re.sub(r'\s*\(Agent:\s*\w+\)', '', title)
    title = re.sub(r'\s*\u2b50\s*', '', title)
    title = re.sub(r'\s*—\s*PR\s*#\d+\s*$', '', title)
    title = title.strip()

    # Auto-detect: if task is still 'todo' but matches a merged PR → mark done
    matched_pr = None
    if col == 'todo' and not pr_ref:
        matched_pr = match_pr(title)
        if matched_pr:
            col = 'done'
            pr_ref = str(matched_pr['number'])

    tasks.append({
        'id': task_id,
        'title': title,
        'category': current_category,
        'col': col,
        'effort': effort,
        'agent': agent,
        'priority': priority,
        'pr': pr_ref,
        'auto_detected': bool(matched_pr),
    })

# Stats
stats = {
    'todo': sum(1 for t in tasks if t['col'] == 'todo'),
    'progress': sum(1 for t in tasks if t['col'] == 'progress'),
    'done': sum(1 for t in tasks if t['col'] == 'done'),
    'total': len(tasks),
    'auto_done': sum(1 for t in tasks if t.get('auto_detected')),
}

categories = sorted(set(t['category'] for t in tasks))

print(json.dumps({
    'tasks': tasks,
    'categories': categories,
    'stats': stats,
    'merged_prs': len(merged_prs),
}, indent=None, separators=(',', ':')))
" "$GOALS_FILE" "$PR_CACHE"
