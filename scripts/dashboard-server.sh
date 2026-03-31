#!/bin/bash
# dashboard-server.sh — Lightweight HTTP server for the Agent Teams Dashboard.
# Serves dashboard.html + JSON APIs from shell scripts.
# Requires Python 3.
#
# Usage: ./scripts/dashboard-server.sh [port]
# Default port: 7842

set -euo pipefail

PORT="${1:-7842}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
EVENT_LOG="${CLAUDEBOT_EVENT_LOG:-/tmp/claudebot-events.json}"
GOALS_FILE="${HOME}/agents/GOALS.md"

# Reset pane cursor on server start so first poll gets recent history
rm -f /tmp/claudebot-pane-cursor.json

echo "Dashboard server starting on http://localhost:${PORT}"
echo "  Project: $PROJECT_DIR"
echo "  Events:  $EVENT_LOG"
echo "  Goals:   $GOALS_FILE"
echo ""

# Initialize event log if missing
if [ ! -f "$EVENT_LOG" ]; then
  echo '{"events":[],"agents":{},"meta":{"started":"'$(date -u '+%Y-%m-%dT%H:%M:%SZ')'","version":"1.0"}}' > "$EVENT_LOG"
  echo "Created empty event log at $EVENT_LOG"
fi

python3 -c "
import http.server
import json
import subprocess
import os
import sys
from urllib.parse import urlparse

PORT = int(sys.argv[1])
PROJECT_DIR = sys.argv[2]
SCRIPT_DIR = sys.argv[3]
EVENT_LOG = sys.argv[4]
GOALS_FILE = sys.argv[5]

class DashboardHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=PROJECT_DIR, **kwargs)

    def do_GET(self):
        path = urlparse(self.path).path

        if path == '/api/all':
            self.send_json(self.get_all())
        elif path == '/api/agents':
            self.send_json(self.get_agents())
        elif path == '/api/goals':
            self.send_json(self.get_goals())
        elif path == '/api/events':
            self.send_json(self.get_events())
        elif path == '/':
            self.path = '/dashboard.html'
            super().do_GET()
        else:
            super().do_GET()

    def send_json(self, data):
        body = json.dumps(data).encode()
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', len(body))
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Cache-Control', 'no-cache')
        self.end_headers()
        self.wfile.write(body)

    def get_agents(self):
        try:
            out = subprocess.run(
                [os.path.join(SCRIPT_DIR, 'agent-status-json.sh')],
                capture_output=True, text=True, timeout=10
            )
            return json.loads(out.stdout)
        except Exception as e:
            return {'error': str(e), 'agents': {}, 'daemons': {}}

    def get_goals(self):
        try:
            out = subprocess.run(
                [os.path.join(SCRIPT_DIR, 'goals-to-json.sh'), GOALS_FILE],
                capture_output=True, text=True, timeout=10
            )
            return json.loads(out.stdout)
        except Exception as e:
            return {'error': str(e), 'tasks': [], 'stats': {}}

    def get_events(self):
        # Merge: event-logger.sh events + tmux pane-parsed events
        events = []

        # Source 1: event log file (from event-logger.sh)
        try:
            if os.path.exists(EVENT_LOG):
                with open(EVENT_LOG, 'r') as f:
                    log = json.load(f)
                events.extend(log.get('events', []))
        except Exception:
            pass

        # Source 2: tmux pane events (real-time, no agent changes needed)
        # Call pane-events.sh which maintains its own history file
        try:
            subprocess.run(
                [os.path.join(SCRIPT_DIR, 'pane-events.sh')],
                capture_output=True, text=True, timeout=10
            )
            # Read accumulated history
            history_file = '/tmp/claudebot-pane-history.json'
            if os.path.exists(history_file):
                with open(history_file, 'r') as f:
                    pane_events = json.load(f)
                for i, ev in enumerate(pane_events):
                    if 'id' not in ev:
                        h = hash(json.dumps(ev, sort_keys=True)) & 0xFFFFFFFF
                        ev['id'] = 'pane-' + str(h)
                events.extend(pane_events)
        except Exception:
            pass

        return {'events': events, 'agents': {}}

    def get_all(self):
        return {
            'agents': self.get_agents(),
            'goals': self.get_goals(),
            'events': self.get_events(),
        }

    def log_message(self, format, *args):
        # Quiet logging — only log API calls
        msg = format % args
        if '/api/' in msg:
            sys.stderr.write(f'[dashboard] {msg}\n')

print(f'Dashboard: http://localhost:{PORT}')
print(f'API: http://localhost:{PORT}/api/all')
print('Press Ctrl+C to stop.')
print()

server = http.server.HTTPServer(('0.0.0.0', PORT), DashboardHandler)
try:
    server.serve_forever()
except KeyboardInterrupt:
    print('\nDashboard server stopped.')
" "$PORT" "$PROJECT_DIR" "$SCRIPT_DIR" "$EVENT_LOG" "$GOALS_FILE"
