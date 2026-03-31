# UI Patterns — BurnRate
# Last updated: 2026-04-01

## Pull-to-refresh + Skeleton Loading
- .refreshable { await vm.refresh() } on List/ScrollView
- Skeleton views with .shimmer() at LEAF level only (never parent+child)
- Shimmer uses @State phase animation — one level only

## Widgets (WidgetKit)
- Medium widget: 3-metric layout (balance, spending, savings)
- Timeline refresh: every 15 minutes
- AppIntentTimelineProvider for user-configurable widgets
- Shared data via App Group container

## Siri Shortcuts (AppIntents)
- 5 AppIntents: CheckBalance, AddExpense, ShowBudget, ShowInsights, QuickAdd
- @Parameter for user input, IntentDialog for responses
- Shortcuts app integration automatic via AppShortcutsProvider

## Anti-patterns
- Nested .shimmer(): parent + child both shimmer → double gradient, too bright
- GeometryReader for simple layouts → use .frame() instead
- Fixed font sizes → always use Dynamic Type (.font(.body))
