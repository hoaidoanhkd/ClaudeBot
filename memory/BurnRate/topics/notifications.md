# Notifications — BurnRate
# Last updated: 2026-04-01

## Scheduling Pattern
- Remove-then-reschedule INSIDE getPendingNotificationRequests callback
- Pre-filter rules/IDs OUTSIDE the callback
- NEVER: remove outside + add outside (race condition)

## Ghost Notification Prevention
- Clear ALL pending with matching prefix before adding new
- Pattern: center.getPendingNotificationRequests { remove stale → add new }

## Weekly Recap
- weeklyRecapEnabled defaults to FALSE (PR #169)
- Rich notification with category spending summary
- Uses on-device computation (no API)

## Key files
- BurnRate/Services/NotificationManager.swift (refactored PR #201, split into extensions)
- private → internal when split across files

## Gotchas
- removePendingNotificationRequests is synchronous — no completion handler needed
- getPendingNotificationRequests callback is async — all scheduling MUST go inside
