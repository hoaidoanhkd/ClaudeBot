#!/bin/bash
# agent-status-json.sh — Output real-time agent status as JSON for the dashboard.
#
# Data sources (layered, each overrides the previous):
#   1. tmux sessions — alive/offline detection
#   2. claude-peers broker API (port 7899) — peer summaries, last_seen
#   3. tmux capture-pane — last activity line from each agent's terminal
#   4. event log — structured events (optional, for historical data)
#
# Output: JSON to stdout

set -euo pipefail

EVENT_LOG="${CLAUDEBOT_EVENT_LOG:-/tmp/claudebot-events.json}"
BROKER_PORT="${CLAUDE_PEERS_PORT:-7899}"
BROKER_URL="http://127.0.0.1:${BROKER_PORT}"

python3 -c "
import json, subprocess, sys, os, re
from datetime import datetime, timezone

EVENT_LOG = sys.argv[1]
BROKER_URL = sys.argv[2]

# ─── 1. Detect tmux sessions ───
SESSIONS = {
    'cc-coordinator': 'coordinator',
    'cc-coder': 'coder',
    'cc-reviewer': 'reviewer',
}

agents = {}

for session, role in SESSIONS.items():
    alive = False
    try:
        r = subprocess.run(['tmux', 'has-session', '-t', session], capture_output=True, timeout=3)
        alive = r.returncode == 0
    except Exception:
        pass

    agents[role] = {
        'name': role.capitalize(),
        'color': {'coordinator': '#7c6aef', 'coder': '#60a5fa', 'reviewer': '#fb923c'}.get(role, '#8b8fa3'),
        'icon': role[0].upper(),
        'session': session,
        'alive': alive,
        'status': 'offline' if not alive else 'idle',
        'task': '',
        'summary': '',
        'activity': '',
        'last_seen': '',
    }

# Check parallel coders
for i in range(1, 4):
    session = f'cc-coder-{i}'
    try:
        r = subprocess.run(['tmux', 'has-session', '-t', session], capture_output=True, timeout=3)
        if r.returncode == 0:
            agents[f'coder-{i}'] = {
                'name': f'Coder #{i}',
                'color': '#60a5fa',
                'icon': str(i),
                'session': session,
                'alive': True,
                'status': 'working',
                'task': '',
                'summary': '',
                'activity': '',
                'last_seen': '',
            }
    except Exception:
        pass

# ─── 2. Query claude-peers broker for summaries ───
peers = []
try:
    import urllib.request
    req = urllib.request.Request(
        f'{BROKER_URL}/list-peers',
        data=json.dumps({'scope': 'machine', 'cwd': '/', 'exclude_id': 'dashboard'}).encode(),
        headers={'Content-Type': 'application/json'},
        method='POST'
    )
    with urllib.request.urlopen(req, timeout=3) as resp:
        peers = json.loads(resp.read())
except Exception:
    pass

# Map peers to agents by matching tty/session or summary keywords
ROLE_KEYWORDS = {
    'coordinator': ['coordinator', 'delegates tasks', 'team lead'],
    'coder': ['coder', 'coding', 'implement', 'refactor'],
    'reviewer': ['reviewer', 'review', 'auto-merge', 'senior reviewer'],
}

for peer in peers:
    summary = (peer.get('summary') or '').lower()
    tty = peer.get('tty', '')

    # Match by tty → session mapping
    matched_role = None
    for session, role in SESSIONS.items():
        # tmux sessions map to specific ttys; match by keyword as fallback
        pass

    # Match by summary keywords
    if not matched_role:
        for role, keywords in ROLE_KEYWORDS.items():
            if any(kw in summary for kw in keywords):
                matched_role = role
                break

    if matched_role and matched_role in agents:
        agents[matched_role]['summary'] = peer.get('summary', '')
        agents[matched_role]['last_seen'] = peer.get('last_seen', '')
        agents[matched_role]['peer_id'] = peer.get('id', '')

        # Infer status from summary
        s = summary
        if any(w in s for w in ['refactor', 'implement', 'working', 'building', 'creating', 'writing', 'fixing']):
            agents[matched_role]['status'] = 'working'
            # Extract task from summary
            agents[matched_role]['task'] = peer.get('summary', '')
        elif any(w in s for w in ['review', 'checking', 'examining']):
            agents[matched_role]['status'] = 'reviewing'
            agents[matched_role]['task'] = peer.get('summary', '')
        elif any(w in s for w in ['delegat', 'dispatch', 'running /go', 'auto-loop']):
            agents[matched_role]['status'] = 'delegating'
            agents[matched_role]['task'] = peer.get('summary', '')
        elif agents[matched_role]['alive']:
            agents[matched_role]['status'] = 'idle'

# Handle multiple coordinators — pick the one with /go auto-loop as primary
coordinators = [p for p in peers if 'coordinator' in (p.get('summary') or '').lower()]
if len(coordinators) > 1:
    # Find the auto-loop one
    for p in coordinators:
        s = (p.get('summary') or '').lower()
        if '/go' in s or 'auto-loop' in s:
            agents['coordinator']['summary'] = p.get('summary', '')
            agents['coordinator']['task'] = p.get('summary', '')
            agents['coordinator']['status'] = 'delegating'
            agents['coordinator']['last_seen'] = p.get('last_seen', '')
            break

# ─── 3. tmux capture-pane — extract last activity ───
STATUS_PATTERNS = [
    (r'(Creating|Writing|Editing|Reading|Building|Running|Compiling)', 'working'),
    (r'(Review|Checking|Examining|Approving|Merging)', 'reviewing'),
    (r'(Waiting|Standing by|Ready|Idle)', 'idle'),
    (r'(PR #?\d+|pull/\d+)', 'working'),
    (r'(Baked for|Completed|Done|merged)', 'done'),
    (r'(Error|Failed|BLOCKED)', 'error'),
]

for role, info in agents.items():
    if not info['alive']:
        continue
    session = info['session']
    try:
        r = subprocess.run(
            ['tmux', 'capture-pane', '-t', session, '-p'],
            capture_output=True, text=True, timeout=5
        )
        if r.returncode == 0:
            lines = [l.strip() for l in r.stdout.strip().split('\n') if l.strip()]
            # Get last meaningful lines (skip empty, prompts, decorators)
            activity_lines = []
            for line in reversed(lines):
                # Skip prompts, decorators, empty
                if line in ('', '❯', '?') or line.startswith('───') or line.startswith('╌'):
                    continue
                if line.startswith('? for shortcuts') or line.startswith('Update available'):
                    continue
                if line.startswith('Esc to cancel') or line.startswith('❯ '):
                    continue
                activity_lines.append(line)
                if len(activity_lines) >= 3:
                    break

            if activity_lines:
                info['activity'] = activity_lines[0][:120]  # last meaningful line

                # If no task from peers, infer from pane
                if not info['task']:
                    info['task'] = activity_lines[0][:80]

    except Exception:
        pass

# ─── 4. Overlay event log (optional, for structured history) ───
if os.path.exists(EVENT_LOG):
    try:
        with open(EVENT_LOG, 'r') as f:
            log = json.load(f)
        # Only use event log data if it's newer than peer data
        for agent_id, agent_data in log.get('agents', {}).items():
            if agent_id in agents:
                ev_updated = agent_data.get('updated', '')
                peer_seen = agents[agent_id].get('last_seen', '')
                # If event log is newer, use its status
                if ev_updated and (not peer_seen or ev_updated > peer_seen):
                    if agent_data.get('status'):
                        agents[agent_id]['status'] = agent_data['status']
                    if agent_data.get('task'):
                        agents[agent_id]['task'] = agent_data['task']
    except (json.JSONDecodeError, KeyError):
        pass

# ─── 5. Daemons ───
daemons = {}
for daemon in ['agent-watchdog', 'agent-keepalive', 'ci-monitor']:
    try:
        r = subprocess.run(['pgrep', '-f', f'{daemon}.sh'], capture_output=True, text=True, timeout=3)
        daemons[daemon] = {
            'running': r.returncode == 0,
            'pid': r.stdout.strip().split('\\n')[0] if r.stdout.strip() else ''
        }
    except Exception:
        daemons[daemon] = {'running': False, 'pid': ''}

# ─── 6. Detect active tasks from agent summaries ───
# Extract what each agent is currently working on for the board overlay
active_tasks = []
for role, info in agents.items():
    if info['status'] in ('working', 'reviewing', 'delegating') and info.get('summary'):
        active_tasks.append({
            'agent': role,
            'summary': info['summary'],
            'status': info['status'],
        })

# ─── Output ───
now = datetime.now(timezone.utc).isoformat()
print(json.dumps({
    'agents': agents,
    'daemons': daemons,
    'peers_count': len(peers),
    'broker_online': len(peers) > 0,
    'active_tasks': active_tasks,
    'timestamp': now,
}, indent=None, separators=(',', ':')))
" "$EVENT_LOG" "$BROKER_URL"
