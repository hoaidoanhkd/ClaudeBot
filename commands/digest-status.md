# Digest Status

Check the status of the weekly digest system.

## Steps:

### 1. Check if digest script exists
```bash
ls -la ~/scripts/weekly-digest.sh
```

### 2. Check launchd agent status
```bash
launchctl list | grep claudebot
```

### 3. View schedule config
```bash
plutil -p ~/Library/LaunchAgents/com.claudebot.agents.plist
```
Get the run time from StartCalendarInterval.

### 4. View latest log
```bash
tail -20 ~/logs/weekly-digest-$(date +%Y-%m-%d).log 2>/dev/null || echo "No log for today yet"
```

### 5. Display summary
Format clearly with:
- Status: Active/Inactive
- Run time: HH:MM
- Last log (summary)

### 6. Show management commands
- Run now: `bash ~/scripts/weekly-digest.sh`
- Save to file: `bash ~/scripts/weekly-digest.sh --output ~/Desktop/digest-$(date +%Y-%m-%d).md`
- Enable: `launchctl load ~/Library/LaunchAgents/com.claudebot.agents.plist`
- Disable: `launchctl unload ~/Library/LaunchAgents/com.claudebot.agents.plist`
- View log: `tail -50 ~/logs/weekly-digest-$(date +%Y-%m-%d).log`
