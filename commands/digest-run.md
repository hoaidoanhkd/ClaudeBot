# Run Daily Digest Now

Run the Daily Claude Code Digest immediately without waiting for the schedule.

## Steps:

1. Run script: `bash ~/.claude/scheduled/daily-digest.sh`
2. Follow log real-time: `tail -f ~/.claude/scheduled/logs/digest-$(date +%Y-%m-%d).log`
3. When done, read the latest digest output at `~/path/to/digest/folder` and display a summary.
