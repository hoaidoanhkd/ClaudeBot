# SwiftData Patterns — BurnRate
# Last updated: 2026-04-01

## #Predicate Rules
- ONLY use String/Bool/Date/Int in #Predicate — NEVER enum .rawValue (runtime crash)
- Decimal stored as TEXT in SQLite → string comparison semantics, not numeric
- Safe: filter enum and Decimal in-memory with .filter{}

## Delete Patterns
- Delete Orphan Guard: count references BEFORE delete, show alert with count
- Delete+Dismiss: dismiss() FIRST, capture context+object, delete in Task @MainActor
- NEVER delete then dismiss — tombstoned @Bindable crashes view

## Gotchas
- Decimal comparison in #Predicate: $0.balance < 0 does STRING compare not numeric
- AppCategory.find(id) MUST pass custom: parameter — falls back to wrong category without it
- onChange(of: array.count) misses property mutations — use compound key

## Key files
- BurnRate/Models/ — all SwiftData @Model definitions
- BurnRate/Services/ — data access layer
