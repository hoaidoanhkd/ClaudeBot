# Refactoring Patterns — BurnRate
# Last updated: 2026-04-01

## Sub-view Extract Pattern (let + closure)
- Pass state as `let` values, mutations as `() -> Void` closures
- Mutations stay in parent orchestrator, sub-views are pure display
- Target: parent <200 LOC, sub-views in separate files

## File Splitting Rules
- `private` → `internal` (default) when splitting across files
- New files need pbxproj: PBXBuildFile + PBXFileReference + Group + Sources
- All new views MUST have #Preview macros

## Naming Convention
- Types+helpers → `[View]Types.swift` (e.g., DebtPayoffTypes.swift)
- Row components → `[View]RowViews.swift`
- Section groups → `[View]SectionViews.swift`
- Charts → `[View]ChartViews.swift`

## Completed Refactors (all scored 9-10/10)
- DashboardView 620→259 LOC (PR #164)
- CategoryManagementView 496→119 LOC (PR #171)
- BudgetListView 462→110 LOC (PR #172)
- DebtPayoffView 459→221 LOC (PR #175)
- NetWorthView 416→168 LOC (PR #177)
- MonthlySummaryView 364→67 LOC (PR #178)
- CashFlowForecastView 361→sub-views (PR #199)
- RecurringRulesView 353→133 LOC (PR #203)
- SavingsGoalDetailView 308→147 LOC (PR #204)
