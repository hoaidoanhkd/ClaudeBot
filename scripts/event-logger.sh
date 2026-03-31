#!/bin/bash
# event-logger.sh — Append structured events to a shared JSON log.
# All agents call this to record status changes, messages, task updates, etc.
# The dashboard reads this file for real-time display.
#
# Usage:
#   event-logger.sh <event_type> <agent> <message> [extra_json_fields]
#
# Examples:
#   event-logger.sh status coordinator "delegating" '{"task":"Build dashboard"}'
#   event-logger.sh message backend '{"to":"frontend","subject":"API ready","body":"Schema at /api/schema.json"}'
#   event-logger.sh task_update coordinator '{"task_id":"1","title":"Design API","from":"todo","to":"progress","assignee":"backend"}'
#   event-logger.sh pr_created coder '{"pr":42,"title":"REST endpoints","branch":"feat/api"}'
#   event-logger.sh pr_merged reviewer '{"pr":42,"score":"9/10"}'
#   event-logger.sh pipeline coordinator '{"action":"start","task":"Build dashboard"}'
#   event-logger.sh pipeline coordinator '{"action":"complete","task":"Build dashboard","result":"success"}'

set -euo pipefail

EVENT_LOG="${CLAUDEBOT_EVENT_LOG:-/tmp/claudebot-events.json}"
MAX_EVENTS=500

event_type="${1:?Usage: event-logger.sh <type> <agent> <message|json> [extra_json]}"
agent="${2:?Missing agent name}"
payload="${3:-"{}"}"
extra="${4:-}"

timestamp=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
ts_short=$(date '+%H:%M')
event_id=$(date '+%s%N' | cut -c1-13)

# Initialize log file if missing or empty
if [ ! -f "$EVENT_LOG" ] || [ ! -s "$EVENT_LOG" ]; then
  echo '{"events":[],"agents":{},"meta":{"started":"'"$timestamp"'","version":"1.0"}}' > "$EVENT_LOG"
fi

# Build the event JSON
# For simple string payloads, wrap in a "message" field
if echo "$payload" | python3 -c "import sys,json; json.load(sys.stdin)" 2>/dev/null; then
  payload_json="$payload"
else
  payload_json=$(python3 -c "import json; print(json.dumps({'message': $(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$payload")}))")
fi

# Merge extra fields if provided
if [ -n "$extra" ]; then
  payload_json=$(python3 -c "
import json, sys
a = json.loads(sys.argv[1])
b = json.loads(sys.argv[2])
a.update(b)
print(json.dumps(a))
" "$payload_json" "$extra")
fi

# Construct event object
event_json=$(python3 -c "
import json, sys
event = {
    'id': sys.argv[1],
    'type': sys.argv[2],
    'agent': sys.argv[3],
    'timestamp': sys.argv[4],
    'time': sys.argv[5],
    'data': json.loads(sys.argv[6])
}
print(json.dumps(event))
" "$event_id" "$event_type" "$agent" "$timestamp" "$ts_short" "$payload_json")

# Atomically update the log file
python3 -c "
import json, sys, os

log_path = sys.argv[1]
new_event = json.loads(sys.argv[2])
agent = sys.argv[3]
event_type = sys.argv[4]
max_events = int(sys.argv[5])

# Read current log
with open(log_path, 'r') as f:
    log = json.load(f)

# Append event (keep last N)
log['events'].append(new_event)
if len(log['events']) > max_events:
    log['events'] = log['events'][-max_events:]

# Update agent status if this is a status event
if event_type == 'status':
    data = new_event['data']
    log['agents'][agent] = {
        'status': data.get('message', data.get('status', 'idle')),
        'task': data.get('task', ''),
        'updated': new_event['timestamp'],
        'time': new_event['time']
    }

# Update meta
log['meta']['last_event'] = new_event['timestamp']
log['meta']['event_count'] = len(log['events'])

# Write atomically
tmp = log_path + '.tmp'
with open(tmp, 'w') as f:
    json.dump(log, f, indent=None, separators=(',', ':'))
os.replace(tmp, log_path)
" "$EVENT_LOG" "$event_json" "$agent" "$event_type" "$MAX_EVENTS"

echo "OK: $event_type/$agent @ $ts_short"
