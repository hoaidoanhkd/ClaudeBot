# Unit Testing — BurnRate
# Last updated: 2026-04-01

## Test Architecture
- Pure injection pattern: updateTransactions()/refresh() instead of @Query/SwiftData
- ViewModels with dependency injection → testable without ModelContext
- XCTest framework, tests in BurnRateTests target

## Test Setup
- Test files need: PBXFileReference + PBXBuildFile in project.pbxproj
- Added to BurnRateTests target (not main app target)
- Import @testable import BurnRate

## Gold Standard Tests
- SubscriptionDetectorEngineTests: normalization, frequency detection, edge cases
- Pure logic services (no SwiftData dependency) are ideal test targets

## Current Coverage
- 209 tests (PR #200: added 83 unit tests, 126→209)
- Coverage still low (~1% by file count, 62 files)
- Priority: ViewModels + Services → then Views

## Gotchas
- Avoid @Query/SwiftData in tests — use injection pattern
- Zero-target savings: test division by zero edge case
- Date-dependent tests: mock Date() or use fixed reference dates
