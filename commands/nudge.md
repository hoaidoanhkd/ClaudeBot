# Proactive Nudge — Trigger Now

Send a proactive nudge to the Coordinator to check goals and suggest a task.

## Steps:

```bash
~/scripts/go-loop.sh
```

This picks the next uncompleted goal from GOALS.md and dispatches it to the Coordinator via tmux.
After that, check Telegram — the Coordinator will send a task suggestion for approval.
