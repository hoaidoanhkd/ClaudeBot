#!/bin/bash
# pane-events.sh — Extract real-time events from tmux pane output.
# Parses send_message, PR actions, tool calls from all agent terminals.
# Outputs JSON array of events for the dashboard.
#
# Uses a cursor file to only return NEW events since last call.

set -euo pipefail

CURSOR_FILE="/tmp/claudebot-pane-cursor.json"
HISTORY_FILE="/tmp/claudebot-pane-history.json"
SESSIONS="cc-coordinator cc-coder cc-reviewer"
CAPTURE_LINES=200  # how many lines back to scan

python3 -c "
import json, re, sys, os, hashlib
from datetime import datetime, timezone

CURSOR_FILE = sys.argv[1]
sessions_str = sys.argv[2]
capture_lines = int(sys.argv[3])
HISTORY_FILE = sys.argv[4] if len(sys.argv) > 4 else '/tmp/claudebot-pane-history.json'

sessions = sessions_str.split()
ROLE_MAP = {
    'cc-coordinator': 'coordinator',
    'cc-coder': 'coder',
    'cc-reviewer': 'reviewer',
}

# Load cursor (last seen line hashes per session)
cursor = {}
if os.path.exists(CURSOR_FILE):
    try:
        with open(CURSOR_FILE, 'r') as f:
            cursor = json.load(f)
    except Exception:
        cursor = {}

import subprocess

events = []
new_cursor = {}
now = datetime.now(timezone.utc).strftime('%H:%M')

for session in sessions:
    role = ROLE_MAP.get(session, session)

    # Capture pane
    try:
        r = subprocess.run(
            ['tmux', 'capture-pane', '-t', session, '-p', '-S', f'-{capture_lines}'],
            capture_output=True, text=True, timeout=5
        )
        if r.returncode != 0:
            continue
        lines = r.stdout.split('\n')
    except Exception:
        continue

    # Hash all lines to find new ones since last cursor
    prev_hashes = set(cursor.get(session, []))
    current_hashes = []
    new_lines = []

    for line in lines:
        stripped = line.strip()
        if not stripped:
            continue
        h = hashlib.md5(stripped.encode()).hexdigest()[:12]
        current_hashes.append(h)
        if h not in prev_hashes:
            new_lines.append(stripped)

    # Save cursor (keep last N hashes)
    new_cursor[session] = current_hashes[-capture_lines:]

    # Parse new lines for events
    for line in new_lines:

        # ── Extract correlation ID (PR number or task name) ──
        corr_id = ''
        pr_match = re.search(r'PR\s*#(\d+)', line, re.I)
        if pr_match:
            corr_id = 'pr-' + pr_match.group(1)

        # ── send_message events ──
        # Pattern: claude-peers - send_message (MCP)(to_id: \"xxx\", message: \"...\")
        m = re.search(r'send_message\s*\(MCP\)\(to_id:\s*\"([^\"]+)\",\s*message:\s*\"(.+?)\"', line)
        if m:
            to_id = m.group(1)
            msg = m.group(2)[:200].replace('\\n', ' ')
            # Try to resolve to_id to role name
            to_name = to_id
            for s, r2 in ROLE_MAP.items():
                pass  # can't resolve without peer list, keep ID
            events.append({
                'type': 'message',
                'agent': role,
                'data': {
                    'to': to_id,
                    'subject': msg[:60],
                    'body': msg,
                },
                'time': now,
            })
            continue

        # ── Received message ──
        # Pattern: ← claude-peers: message text
        m = re.match(r'^←\s*claude-peers:\s*(.+)', line)
        if m:
            msg = m.group(1)[:200]
            events.append({
                'type': 'message_received',
                'agent': role,
                'data': {
                    'from': 'peer',
                    'body': msg,
                },
                'time': now,
            })
            continue

        # ── PR created ──
        # Pattern: gh pr create or PR #N created
        m = re.search(r'(?:PR|pr)\s*#(\d+)\s*(?:created|opened)', line, re.I)
        if m:
            events.append({
                'type': 'pr_created',
                'agent': role,
                'data': {'pr': int(m.group(1)), 'title': line[:80]},
                'time': now,
            })
            continue

        # ── PR merged ──
        m = re.search(r'(?:PR|pr)\s*#(\d+).*(?:merged|MERGED)', line, re.I)
        if m:
            score = ''
            sm = re.search(r'(\d+/10)', line)
            if sm:
                score = sm.group(1)
            events.append({
                'type': 'pr_merged',
                'agent': role,
                'data': {'pr': int(m.group(1)), 'score': score, 'title': line[:80]},
                'time': now,
            })
            continue

        # ── PR review ──
        m = re.search(r'gh pr review\s+(\d+)\s*--(\w+)', line)
        if m:
            events.append({
                'type': 'pr_review',
                'agent': role,
                'data': {'pr': int(m.group(1)), 'action': m.group(2)},
                'time': now,
            })
            continue

        # ── Discord/Telegram reply ──
        m = re.search(r'(?:discord|telegram)\s*-\s*reply\s*\(MCP\)\(.*text:\s*\"(.+?)\"', line, re.I)
        if m:
            msg = m.group(1)[:150].replace('\\n', ' ')
            events.append({
                'type': 'channel_reply',
                'agent': role,
                'data': {'message': msg},
                'time': now,
            })
            continue

        # ── Tool calls (significant ones) ──
        m = re.match(r'^⏺\s*(Bash|Write|Edit|Read)\((.+?)\)', line)
        if m:
            tool = m.group(1)
            arg = m.group(2)[:80]
            # Only log significant tool calls
            if tool in ('Write', 'Edit') or 'gh pr' in arg or 'git' in arg:
                events.append({
                    'type': 'tool_call',
                    'agent': role,
                    'data': {'tool': tool, 'args': arg},
                    'time': now,
                })
            continue

        # ── Standing by / status changes ──
        m = re.match(r'^⏺\s*(Standing by|Waiting|Ready for next)', line, re.I)
        if m:
            events.append({
                'type': 'status',
                'agent': role,
                'data': {'message': 'idle', 'task': m.group(1)},
                'time': now,
            })
            continue

# Save cursor
with open(CURSOR_FILE, 'w') as f:
    json.dump(new_cursor, f)

# Append new events to persistent history and return ALL history
history = []
if os.path.exists(HISTORY_FILE):
    try:
        with open(HISTORY_FILE, 'r') as f:
            history = json.load(f)
    except Exception:
        history = []

if events:
    # Post-process: add correlation IDs based on PR numbers
    for ev in events:
        data = ev.get('data', {})
        combined = json.dumps(data)
        pr_m = re.search(r'PR\s*#(\d+)', combined, re.I)
        if pr_m:
            ev['corr_id'] = 'pr-' + pr_m.group(1)

    history.extend(events)
    # Keep last 200 events
    history = history[-200:]
    with open(HISTORY_FILE, 'w') as f:
        json.dump(history, f)

print(json.dumps({
    'events': history,
    'new_count': len(events),
    'total_count': len(history),
}, indent=None, separators=(',', ':')))
" "$CURSOR_FILE" "$SESSIONS" "$CAPTURE_LINES" "$HISTORY_FILE"
