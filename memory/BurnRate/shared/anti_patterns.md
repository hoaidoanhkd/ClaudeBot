
## 2026-03-30 — Decimal comparison in SwiftData #Predicate (PR #165)
- Anti-pattern: Using `Decimal` values in `#Predicate` for `@Query` (e.g., `$0.balance < 0`, `$0.currentAmount < $0.targetAmount`)
- Risk: SwiftData stores Decimal as TEXT in SQLite → string comparison semantics differ from numeric (e.g., "-50" > "-100" as strings but -50 > -100 numerically is false)
- Fix: Keep Decimal comparisons as in-memory `.filter {}` OR verify SwiftData's actual storage type and predicate translation behavior first
- Safe alternatives: Use Int (points/cents) for amounts if DB-level filtering is needed, or store a computed Bool property (e.g., `isNegative: Bool`) and filter on that
