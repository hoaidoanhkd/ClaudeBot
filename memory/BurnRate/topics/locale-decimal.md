# Locale & Decimal — BurnRate
# Last updated: 2026-04-01

## Decimal(string:) — MUST specify locale
- Decimal(string: text, locale: Locale(identifier: "en_US_POSIX"))
- Bare Decimal(string: text) returns nil on non-US locales
- ALL user input parsing must use explicit locale

## NSDecimalNumber.intValue — FORBIDDEN
- Returns 0 for repeating decimals (Foundation bug, e.g., 333.333…)
- Fix: Int(NSDecimalNumber(decimal: val).doubleValue)
- Double precision sufficient for personal finance

## NumberFormatter
- Always set locale explicitly
- Decimal.description is locale-independent — safe for form field seeding

## Key PRs
- PR #162: Fixed 6× bare Decimal(string:) + 1× NSDecimalNumber.intValue (10/10)
- PR #174: Confirmed .doubleValue + Int() as standard pattern
