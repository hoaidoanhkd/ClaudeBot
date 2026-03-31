---
paths: "**/*.swift"
---

# iOS / SwiftUI Rules (learned from projects)

Loaded when PROJECT_TYPE=ios-swiftui or ios-uikit.
Auto-activates when working with .swift files.

## SwiftData Delete Orphan Guard
Any task involving SwiftData entity deletion MUST include:
(a) Count affected references before delete
(b) Show confirmation alert with affected count
(c) Define reassign or graceful fallback strategy
Never silently delete entities that may be referenced by other models.

## SwiftData Delete+Dismiss Pattern
When deleting a SwiftData model from a detail view, ALWAYS use dismiss-first:
1. Call `dismiss()` first
2. Capture `modelContext` + object reference as local constants BEFORE dismiss
3. Delete via `Task { @MainActor in context.delete(captured) }`
NEVER: delete then dismiss — view renders tombstoned @Bindable model → crash.

## Decimal(string:) Locale
ALL `Decimal(string:)` calls on user input MUST specify locale:
```swift
Decimal(string: text, locale: Locale(identifier: "en_US_POSIX"))
```
NEVER: bare `Decimal(string: text)` — returns nil on non-US locales.

## SwiftData #Predicate Enum Restriction
Inside `#Predicate<SwiftData>`, ONLY use: Date, Decimal/Double/Int comparisons, String equality.
NEVER: enum `.rawValue` or nested enum properties — compiles but crashes at runtime (SQLite).
PATTERN: Filter by date/amount at DB level, filter enum in-memory with `.filter{}`

## N-Month Historical Analysis
When bucketing expenses into N complete monthly slots:
```
fetch from: startOfMonth(-N) to: startOfCurrentMonth (NOT to: Date())
```
Using `Date()` includes partial current month → inflates averages.

## Simulator Query — REQUIRED before build/test
Always query available simulators before xcodebuild:
```bash
xcrun simctl list devices available | grep -i iphone
```
Use first booted device, or boot one. NEVER hardcode simulator name.

## NSDecimalNumber.intValue — FORBIDDEN
Never use `NSDecimalNumber(...).intValue` — returns 0 for repeating decimals.
Fix: `Int(NSDecimalNumber(decimal: result).doubleValue)`

## New Swift Files → pbxproj Registration
When creating new .swift files, ALWAYS add to Xcode project:
- PBXBuildFile, PBXFileReference, Group membership, Sources build phase
NEVER assume Xcode auto-discovers CLI-created files.

## UNUserNotificationCenter — Remove-then-Reschedule
When scheduling notifications:
1. Pre-filter rules/IDs OUTSIDE the callback
2. getPendingNotificationRequests { remove stale → add new INSIDE callback }
NEVER: remove outside + add outside (race condition)

## onChange(of: array.count) — FORBIDDEN
`.count` only catches insert/delete, NOT property mutations.
Use: `onChange(of: items.map { "\($0.id)\($0.someProperty)" })`
Or: trigger refresh via `.onDismiss` of edit sheets.
