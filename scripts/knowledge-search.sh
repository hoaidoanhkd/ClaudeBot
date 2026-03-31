#!/bin/bash
# knowledge-search.sh — BM25-ranked search over CSV knowledge bases.
# Zero dependencies (pure Python). Returns structured Do/Don't/Code results.
#
# Usage:
#   knowledge-search.sh "SwiftData delete"                    # search custom rules
#   knowledge-search.sh "react hooks" --stack react            # search React stack
#   knowledge-search.sh "color palette fintech" --general      # search general design
#   knowledge-search.sh "Decimal locale" --top 3 --full        # top 3 with code
#   knowledge-search.sh --all "responsive layout"              # search everything
#   knowledge-search.sh --list                                 # list all knowledge bases
#
# Knowledge dirs:
#   agents/rules/platforms/*.csv          — custom learned rules (default)
#   agents/rules/knowledge/stacks/*.csv   — 16 platform stacks
#   agents/rules/knowledge/general/*.csv  — UX, colors, typography, charts

set -euo pipefail

BASE_DIR="$HOME/Desktop/Projects/ClaudeBot/agents/rules"
KNOWLEDGE_DIR="$BASE_DIR/platforms"  # default: custom rules
QUERY=""
TOP_N=5
FULL=false
LIST=false
STACK=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --top) TOP_N="$2"; shift 2 ;;
    --full) FULL=true; shift ;;
    --list) LIST=true; shift ;;
    --stack) STACK="$2"; KNOWLEDGE_DIR="$BASE_DIR/knowledge/stacks"; shift 2 ;;
    --general) KNOWLEDGE_DIR="$BASE_DIR/knowledge/general"; shift ;;
    --all) KNOWLEDGE_DIR="__ALL__"; shift ;;
    *) QUERY="$QUERY $1"; shift ;;
  esac
done
QUERY=$(echo "$QUERY" | xargs)

# Auto-detect stack from PROJECT_TYPE if not specified
if [ -z "$STACK" ] && [ "$KNOWLEDGE_DIR" != "__ALL__" ] && [ "$KNOWLEDGE_DIR" = "$BASE_DIR/platforms" ]; then
  source "$HOME/agents/config.env" 2>/dev/null || true
  case "${PROJECT_TYPE:-}" in
    ios-swiftui|ios-uikit) STACK="swiftui" ;;
    web|web-react)         STACK="react" ;;
    web-nextjs)            STACK="nextjs" ;;
    web-vue)               STACK="vue" ;;
    flutter)               STACK="flutter" ;;
    react-native)          STACK="react-native" ;;
    android)               STACK="jetpack-compose" ;;
    python|python-django)  ;; # no stack CSV, use general
    laravel|php)           STACK="laravel" ;;
  esac

  # If auto-detected, search BOTH custom rules + stack
  if [ -n "$STACK" ]; then
    KNOWLEDGE_DIR="__AUTO__"
  fi
fi

# If --stack specified manually, filter to that stack's CSV only
if [ -n "$STACK" ] && [ "$KNOWLEDGE_DIR" != "__AUTO__" ] && [ "$KNOWLEDGE_DIR" != "__ALL__" ]; then
  STACK_FILE="$BASE_DIR/knowledge/stacks/${STACK}.csv"
  if [ ! -f "$STACK_FILE" ]; then
    echo "Stack not found: $STACK"
    echo "Available: $(ls $BASE_DIR/knowledge/stacks/*.csv 2>/dev/null | xargs -I{} basename {} .csv | tr '\n' ' ')"
    exit 1
  fi
fi

python3 -c "
import csv, re, math, sys, os, json

KNOWLEDGE_DIR = sys.argv[1]
query = sys.argv[2]
top_n = int(sys.argv[3])
full_mode = sys.argv[4] == 'true'
list_mode = sys.argv[5] == 'true'
stack_filter = sys.argv[6] if len(sys.argv) > 6 else ''
BASE_DIR = sys.argv[7] if len(sys.argv) > 7 else ''

# Find all CSV files
csv_files = []

if KNOWLEDGE_DIR == '__ALL__' and BASE_DIR:
    # Search all directories
    for subdir in ['platforms', 'knowledge/stacks', 'knowledge/general']:
        d = os.path.join(BASE_DIR, subdir)
        if os.path.isdir(d):
            for f in sorted(os.listdir(d)):
                if f.endswith('.csv'):
                    csv_files.append(os.path.join(d, f))
elif KNOWLEDGE_DIR == '__AUTO__' and BASE_DIR and stack_filter:
    # Auto mode: custom rules (matching stack) + detected stack CSV
    custom_dir = os.path.join(BASE_DIR, 'platforms')
    if os.path.isdir(custom_dir):
        for f in sorted(os.listdir(custom_dir)):
            if f.endswith('.csv') and stack_filter in f.lower():
                csv_files.append(os.path.join(custom_dir, f))
    sf = os.path.join(BASE_DIR, 'knowledge', 'stacks', stack_filter + '.csv')
    if os.path.exists(sf):
        csv_files.append(sf)
elif stack_filter and BASE_DIR:
    # Single stack file (manual --stack)
    sf = os.path.join(BASE_DIR, 'knowledge', 'stacks', stack_filter + '.csv')
    if os.path.exists(sf):
        csv_files.append(sf)
else:
    if os.path.isdir(KNOWLEDGE_DIR):
        for f in sorted(os.listdir(KNOWLEDGE_DIR)):
            if f.endswith('.csv'):
                csv_files.append(os.path.join(KNOWLEDGE_DIR, f))

if list_mode:
    # List ALL directories regardless of current filter
    all_dirs = {
        'Custom rules': os.path.join(BASE_DIR, 'platforms') if BASE_DIR else KNOWLEDGE_DIR,
        'Stacks (16 platforms)': os.path.join(BASE_DIR, 'knowledge', 'stacks') if BASE_DIR else '',
        'General (UX/design)': os.path.join(BASE_DIR, 'knowledge', 'general') if BASE_DIR else '',
    }
    total_rules = 0
    for label, d in all_dirs.items():
        if not d or not os.path.isdir(d):
            continue
        files = sorted(f for f in os.listdir(d) if f.endswith('.csv'))
        if not files:
            continue
        count = 0
        names = []
        for f in files:
            with open(os.path.join(d, f)) as fh:
                rows = sum(1 for _ in csv.reader(fh)) - 1
            count += rows
            short = f.replace('.csv','')
            names.append(short + '(' + str(rows) + ')')
        total_rules += count
        print(f'📂 {label}: {count} rules in {len(files)} files')
        # Show files in rows of 4
        for i in range(0, len(names), 4):
            chunk = ', '.join(names[i:i+4])
            print('   ' + chunk)
    print(f'\n📚 Total: {total_rules} rules across all knowledge bases')
    print(f'\nUsage:')
    print(f'  knowledge-search.sh "query"                # custom rules')
    print(f'  knowledge-search.sh "query" --stack react   # React stack')
    print(f'  knowledge-search.sh "query" --general       # UX/design')
    print(f'  knowledge-search.sh "query" --all           # search everything')
    sys.exit(0)

if not query:
    print('Usage: knowledge-search.sh \"query\" [--top N] [--full] [--list]')
    sys.exit(1)

# ── BM25 Implementation ──
class BM25:
    def __init__(self, k1=1.5, b=0.75):
        self.k1 = k1
        self.b = b
        self.docs = []
        self.idf = {}
        self.avgdl = 0

    def tokenize(self, text):
        text = re.sub(r'[^\w\s]', ' ', str(text).lower())
        return [w for w in text.split() if len(w) > 2]

    def fit(self, documents):
        self.docs = [self.tokenize(d) for d in documents]
        self.N = len(self.docs)
        self.avgdl = sum(len(d) for d in self.docs) / max(self.N, 1)
        # IDF
        df = {}
        for doc in self.docs:
            for w in set(doc):
                df[w] = df.get(w, 0) + 1
        self.idf = {w: math.log((self.N - freq + 0.5) / (freq + 0.5) + 1) for w, freq in df.items()}

    def score(self, query):
        q_tokens = self.tokenize(query)
        scores = []
        for doc in self.docs:
            s = 0
            doc_len = len(doc)
            tf_map = {}
            for w in doc:
                tf_map[w] = tf_map.get(w, 0) + 1
            for qt in q_tokens:
                if qt not in self.idf:
                    continue
                tf = tf_map.get(qt, 0)
                num = tf * (self.k1 + 1)
                den = tf + self.k1 * (1 - self.b + self.b * doc_len / max(self.avgdl, 1))
                s += self.idf[qt] * num / den
            scores.append(s)
        return scores

# ── Load all CSVs ──
all_rows = []
for path in csv_files:
    fname = os.path.basename(path)
    with open(path, encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            row['_source'] = fname
            all_rows.append(row)

if not all_rows:
    print('(no knowledge base files found)')
    sys.exit(0)

# ── Build search corpus ──
# Combine key columns into searchable text
documents = []
for row in all_rows:
    parts = [
        row.get('Category', ''),
        row.get('Guideline', ''),
        row.get('Description', ''),
        row.get('Do', ''),
        row.get('Don\\'t', row.get('Dont', '')),
        row.get('Code Good', row.get('Code Example Good', '')),
        row.get('Code Bad', row.get('Code Example Bad', '')),
    ]
    documents.append(' '.join(parts))

# ── Search ──
bm25 = BM25()
bm25.fit(documents)
scores = bm25.score(query)

# Rank
ranked = sorted(enumerate(scores), key=lambda x: x[1], reverse=True)
results = [(i, s) for i, s in ranked if s > 0][:top_n]

if not results:
    print(f'(no results for: \"{query}\")')
    sys.exit(0)

# ── Output ──
print(f'<knowledge query=\"{query}\" results=\"{len(results)}\">')
for idx, (i, score) in enumerate(results):
    row = all_rows[i]
    sev = row.get('Severity', '?')
    sev_icon = {'critical': '🔴', 'high': '🟡', 'medium': '🔵'}.get(sev, '⚪')
    cat = row.get('Category', '?')
    guideline = row.get('Guideline', '?')
    desc = row.get('Description', '')

    print(f'  {sev_icon} [{sev}] {cat} → {guideline}')
    print(f'     {desc}')
    print(f'     ✅ Do: {row.get(\"Do\", \"\")}')
    dont = row.get(\"Don't\", row.get('Dont', ''))
    print(f'     ❌ Don\\'t: {dont}')

    if full_mode:
        cg = row.get('Code Good', '')
        cb = row.get('Code Bad', '')
        if cg:
            print(f'     ✅ Code: {cg}')
        if cb:
            print(f'     ❌ Code: {cb}')

    print()

print('</knowledge>')
" "$KNOWLEDGE_DIR" "$QUERY" "$TOP_N" "$FULL" "$LIST" "$STACK" "$BASE_DIR"
