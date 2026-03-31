#!/bin/bash
# memory-learn.sh — Confidence-tiered learning from corrections, successes, and observations.
#
# Agents call this to record learnings with confidence levels.
# High-confidence rules (from user corrections) auto-update agent rules.
# Low-confidence observations get pruned if never reinforced.
#
# Usage:
#   memory-learn.sh correction "Never use Decimal in #Predicate" "user said: don't do this"
#   memory-learn.sh success "let+closure pattern for sub-views" "PR #177 scored 9/10"
#   memory-learn.sh observation "shimmer applied at leaf level" "worked in PR #167"
#   memory-learn.sh reinforce "let+closure pattern"    # boost confidence of existing rule
#   memory-learn.sh prune                              # remove low-confidence old rules
#   memory-learn.sh list                               # show all rules with scores
#
# Confidence tiers:
#   HIGH (10)  — user corrections ("don't do X", "always use Y")
#   MEDIUM (6) — task success (PR merged with score >= 8)
#   OBSERVATION (3) — noticed pattern, not yet confirmed
#
# Rules decay -1 per week if not reinforced. Pruned at score <= 0.

set -euo pipefail

source "$HOME/agents/config.env" 2>/dev/null || true
MEMORY_DIR="${HOME}/agents/memory/${PROJECT_NAME:-default}/shared"
RULES_FILE="$MEMORY_DIR/learned_rules.json"

mkdir -p "$MEMORY_DIR"

# Initialize rules file if missing
if [ ! -f "$RULES_FILE" ]; then
  echo '[]' > "$RULES_FILE"
fi

ACTION="${1:-list}"
shift 2>/dev/null || true

python3 -c "
import json, sys, os
from datetime import datetime, timedelta

RULES_FILE = sys.argv[1]
action = sys.argv[2]
args = sys.argv[3:]

# Load rules
with open(RULES_FILE, 'r') as f:
    rules = json.load(f)

now = datetime.now().strftime('%Y-%m-%d')

def save():
    with open(RULES_FILE, 'w') as f:
        json.dump(rules, f, indent=2)

def find_rule(keyword):
    kw = keyword.lower()
    for r in rules:
        if kw in r['rule'].lower():
            return r
    return None

if action == 'correction':
    rule_text = args[0] if args else ''
    context = args[1] if len(args) > 1 else ''
    if not rule_text:
        print('Usage: memory-learn.sh correction \"rule\" \"context\"')
        sys.exit(1)
    existing = find_rule(rule_text)
    if existing:
        existing['confidence'] = min(existing['confidence'] + 4, 15)
        existing['reinforced'] = now
        existing['history'].append({'action': 'correction_reinforced', 'date': now, 'context': context})
        print(f'Reinforced: \"{existing[\"rule\"]}\" → confidence {existing[\"confidence\"]}')
    else:
        rules.append({
            'rule': rule_text,
            'tier': 'HIGH',
            'confidence': 10,
            'created': now,
            'reinforced': now,
            'context': context,
            'history': [{'action': 'created_from_correction', 'date': now, 'context': context}]
        })
        print(f'NEW HIGH rule: \"{rule_text}\" (confidence: 10)')
    save()

elif action == 'success':
    rule_text = args[0] if args else ''
    context = args[1] if len(args) > 1 else ''
    if not rule_text:
        print('Usage: memory-learn.sh success \"pattern\" \"context\"')
        sys.exit(1)
    existing = find_rule(rule_text)
    if existing:
        existing['confidence'] = min(existing['confidence'] + 2, 15)
        existing['reinforced'] = now
        existing['history'].append({'action': 'success_reinforced', 'date': now, 'context': context})
        print(f'Reinforced: \"{existing[\"rule\"]}\" → confidence {existing[\"confidence\"]}')
    else:
        rules.append({
            'rule': rule_text,
            'tier': 'MEDIUM',
            'confidence': 6,
            'created': now,
            'reinforced': now,
            'context': context,
            'history': [{'action': 'created_from_success', 'date': now, 'context': context}]
        })
        print(f'NEW MEDIUM rule: \"{rule_text}\" (confidence: 6)')
    save()

elif action == 'observation':
    rule_text = args[0] if args else ''
    context = args[1] if len(args) > 1 else ''
    if not rule_text:
        print('Usage: memory-learn.sh observation \"pattern\" \"context\"')
        sys.exit(1)
    existing = find_rule(rule_text)
    if existing:
        existing['confidence'] = min(existing['confidence'] + 1, 15)
        existing['reinforced'] = now
        print(f'Reinforced: \"{existing[\"rule\"]}\" → confidence {existing[\"confidence\"]}')
    else:
        rules.append({
            'rule': rule_text,
            'tier': 'LOW',
            'confidence': 3,
            'created': now,
            'reinforced': now,
            'context': context,
            'history': [{'action': 'created_from_observation', 'date': now, 'context': context}]
        })
        print(f'NEW LOW rule: \"{rule_text}\" (confidence: 3)')
    save()

elif action == 'reinforce':
    keyword = args[0] if args else ''
    if not keyword:
        print('Usage: memory-learn.sh reinforce \"keyword\"')
        sys.exit(1)
    existing = find_rule(keyword)
    if existing:
        existing['confidence'] = min(existing['confidence'] + 2, 15)
        existing['reinforced'] = now
        existing['history'].append({'action': 'manual_reinforce', 'date': now})
        print(f'Reinforced: \"{existing[\"rule\"]}\" → confidence {existing[\"confidence\"]}')
        save()
    else:
        print(f'No rule found matching \"{keyword}\"')

elif action == 'prune':
    # Decay: -1 per week since last reinforced
    pruned = []
    kept = []
    for r in rules:
        last = datetime.strptime(r['reinforced'], '%Y-%m-%d')
        weeks = (datetime.now() - last).days // 7
        r['confidence'] -= weeks
        if r['confidence'] <= 0:
            pruned.append(r['rule'])
        else:
            kept.append(r)
    rules = kept
    save()
    if pruned:
        print(f'Pruned {len(pruned)} rules:')
        for p in pruned:
            print(f'  ❌ {p}')
    else:
        print('No rules to prune.')
    print(f'Remaining: {len(rules)} rules')

elif action == 'list':
    if not rules:
        print('No learned rules yet.')
        sys.exit(0)
    # Sort by confidence descending
    rules.sort(key=lambda r: r['confidence'], reverse=True)
    print(f'📚 {len(rules)} learned rules:')
    print()
    for r in rules:
        tier_icon = {'HIGH': '🔴', 'MEDIUM': '🟡', 'LOW': '⚪'}.get(r['tier'], '⚪')
        bar = '█' * min(r['confidence'], 15) + '░' * (15 - min(r['confidence'], 15))
        print(f'  {tier_icon} [{r[\"confidence\"]:2d}/15] {bar} {r[\"rule\"]}')
        print(f'          created: {r[\"created\"]} | reinforced: {r[\"reinforced\"]}')
    save()

else:
    print(f'Unknown action: {action}')
    print('Usage: memory-learn.sh [correction|success|observation|reinforce|prune|list] ...')
    sys.exit(1)
" "$RULES_FILE" "$ACTION" "$@"
