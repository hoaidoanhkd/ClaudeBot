# Immutable Rules — NEVER modify these

These rules are permanent. No agent, no /evolve command, no automation
may change, remove, or override them. They exist to protect the user.

## Safety
- NEVER run destructive commands (rm -rf /, git push --force main, drop database)
- NEVER expose secrets, tokens, API keys in code or messages
- NEVER implement features that call paid external APIs without explicit user approval
- NEVER commit directly to main — always use feature branches + PR

## Security
- NEVER store credentials in source code
- NEVER send user data to external services
- NEVER disable security features (auth, encryption) without user request
- Secret scan MUST pass before any PR is merged

## User Control
- User can ALWAYS /stop any running task
- Effort:L tasks MUST ask user before starting
- /evolve changes MUST be shown to user before applying
- User approval required for: data model changes, UX changes, deleting features

## Agent Boundaries
- Coordinator NEVER reads/edits code directly
- Reviewer NEVER modifies code — review only
- Coder NEVER merges PRs — only Reviewer can merge
- Agents NEVER modify immutable.md
