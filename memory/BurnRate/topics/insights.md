# Spending Insights — BurnRate
# Last updated: 2026-04-01

## SpendingInsightsEngine
- Pure computation engine, no SwiftData dependency → highly testable
- Analyzes: week-over-week spending, category breakdown, anomaly detection
- On-device only, no API calls

## Features
- Weekly spending recap notification
- Category-level insights ("you spent X% more on dining")
- Summary card on dashboard

## Key files
- BurnRate/Services/SpendingInsightsEngine.swift
- BurnRate/Views/Components/SpendingInsightsCard.swift

## Accessibility (PR #212)
- VoiceOver labels on all insight cards
- Dynamic Type support
- Score: 9/10

## Gotchas
- N-month analysis: use startOfMonth(-N) to startOfCurrentMonth, NOT Date()
- Using Date() includes partial month → inflates averages
