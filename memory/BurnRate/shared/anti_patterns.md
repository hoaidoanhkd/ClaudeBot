# Anti-Patterns — BurnRate

## 2026-03-29 — PR #105 — onChange(of: .count) for SwiftData cache invalidation
- Problem: Using `.onChange(of: transactions.count)` to trigger ViewModel cache refresh misses edits to existing objects (count doesn't change on edit)
- Better: Also trigger on sheet dismiss, or use `.task(id:)` with a richer identity signal
- Context: When replacing computed properties with cached ViewModel state, change detection must cover ALL mutation types (insert, delete, AND update)
- Tags: swiftdata, caching, onChange

## 2026-03-29 — PR #110 — Silent deletion of referenced entity
- Problem: Deleting CustomCategory doesn't warn user about transactions that reference it. Transactions silently fall back to "Other" category.
- Better: Count affected transactions, show confirmation alert with count, optionally offer reassignment
- Context: CustomCategory.id is stored as string in Transaction.category — no SwiftData relationship, so no cascade/nullify
- Tags: delete, data-integrity, confirmation

## 2026-03-29 — PR #137 — Opt-in default anti-pattern
- Pattern: `@AppStorage("featureEnabled") var featureEnabled = true` for a new feature
- Problem: Silently opts in existing users who have parent feature (notificationsEnabled) already enabled. They receive the new notification without consent.
- Fix: Always default new optional features to `false`. User must consciously enable in Settings.
- Tags: AppStorage, notifications, defaults, opt-in

## 2026-03-30 — PR #141 + #143 + #148 — Delete from detail view without dismiss
- Anti-pattern: Delete SwiftData model then dismiss view (or forget to dismiss entirely)
- Problem: Calling `context.delete(model)` then `dismiss()` (or never dismissing) leaves the view rendering a tombstoned @Bindable model during the dismiss animation — can crash.
- Fix: Call `dismiss()` first, capture model reference and context as locals, then delete in `Task { @MainActor in delete(captured) }`. The Task runs after the current handler, by which time the view is safely dismissed.
- Rule: For SwiftData deletes that also dismiss the current view: dismiss() first, delete async via Task {@MainActor in}.
- Tags: swiftdata, dismiss, delete-pattern, tombstone, crash

## 2026-03-30 — PR #145 + #147 — Date-range bucket overflow in historical analysis
- Anti-pattern: Using `to: Date()` (now) as fetch upper bound when analysing N complete historical months
- Problem: The current partial month gets included. If the bucket array has N slots (0..N-1), monthDiff=N expenses from the current month overflow to bucket N-1, inflating that month's totals.
- Fix: Always use `to: startOfCurrentMonth` when analysing complete historical months. Reserve the current partial month for a separate bucket or exclude it entirely.
- Rule: Historical analysis over N complete months should fetch `from: startOfMonth(-N) to: startOfCurrentMonth`, not `to: Date()`.
- Tags: date-math, bucketing, off-by-one, averages

## 2026-03-30 — PR #148 — SwiftData #Predicate enum rawValue crash
- Anti-pattern: Using enum `.rawValue` inside SwiftData `#Predicate`
- Problem: `$0.type.rawValue == someRaw` inside #Predicate compiles but crashes at runtime because SQLite cannot translate Codable enum rawValue comparisons.
- Fix: Remove enum comparison from #Predicate entirely. Keep date/amount/string comparisons at DB level. Move enum type filtering to in-memory `.filter { }` after fetch.
- Rule: Never use .rawValue, enum cases, or nested enum properties inside #Predicate<SwiftData>. Only use: Date comparisons, Decimal/Double/Int comparisons, String equality on stored String properties.
- Tags: swiftdata, predicate, enum, crash, sqlite

## 2026-03-30 — PR #148 — Decimal(string:) without locale on user input
- Anti-pattern: `Decimal(string: text)` without specifying locale on user-facing text fields
- Problem: Uses device locale by default. On locales with comma decimal separator (German, French, etc.), "1.50" parses as nil → silent failure.
- Fix: Always use `Decimal(string: text, locale: Locale(identifier: "en_US_POSIX"))` for amounts typed in text fields. Cache the locale as `static let posixLocale = Locale(identifier: "en_US_POSIX")`.
- Rule: All Decimal(string:) calls on user-input text fields must specify en_US_POSIX locale.
- Tags: locale, decimal, parsing, i18n
