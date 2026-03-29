#!/bin/bash
# Save or update Discord bot token securely (token hidden from screen)
# Usage: bash setup-discord-token.sh

echo ""
echo "Discord Token Setup"
echo "────────────────────"
echo ""
echo "Get your token from:"
echo "  discord.com/developers/applications → your bot → Bot tab → Reset Token"
echo ""
echo -n "Paste your Discord bot token (hidden): "
read -rs TOKEN
echo ""

if [ -z "$TOKEN" ]; then
  echo "No token entered. Aborted."
  exit 1
fi

mkdir -p ~/.claude/channels/discord
echo "DISCORD_BOT_TOKEN=$TOKEN" > ~/.claude/channels/discord/.env
echo "✅ Token saved!"
echo ""
echo "Next: restart agents with ./start.sh"
echo ""
