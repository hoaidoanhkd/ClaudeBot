
## Notification Feature — 2026-03-30
- Pattern: For scheduled notifications that get rescheduled, always clear ALL pending with matching prefix before adding new ones (prevents ghosts from deleted entities)
- Key code: `center.getPendingNotificationRequests { requests in let ghostIds = requests.filter { $0.identifier.hasPrefix("burnrate.bill.") }.map(\.identifier); center.removePendingNotificationRequests(withIdentifiers: ghostIds) }`
- Files: NotificationManager.swift

## AppStorage JSON-encoded Set<String> — 2026-03-30
- Pattern: Persist a `Set<String>` via @AppStorage by JSON-encoding to String
- Key code: `@AppStorage("key") var json: String = "[]"` + computed var decodes + mutating func encodes back
- Files: SubscriptionDetectorView.swift (PR #163)
