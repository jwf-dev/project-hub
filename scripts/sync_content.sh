#!/usr/bin/env bash
# sync_content.sh
# Syncs Markdown files from your Obsidian vault's Publish/ folder to the Hugo site.
# Assumes vault is at ~/iCloudDrive/ObsidianVault (configurable via VAULT_ROOT env var)

set -euo pipefail

# Configuration
VAULT_ROOT="${VAULT_ROOT:-$HOME/iCloudDrive/ObsidianVault}"
SRC="${VAULT_ROOT}/Publish"
DST="$(dirname "$0")/../site/content"

echo "🔄 Syncing content from $SRC to $DST..."

# Check if source exists
if [ ! -d "$SRC" ]; then
  echo "❌ Error: Publish folder not found at $SRC"
  echo "   Set VAULT_ROOT environment variable if your vault is elsewhere."
  echo "   Example: VAULT_ROOT=/path/to/vault ./scripts/sync_content.sh"
  exit 1
fi

# Ensure destination exists
mkdir -p "$DST"

# Perform rsync (deletes files in DST that don't exist in SRC)
rsync -av --delete "$SRC/" "$DST/"

echo "✅ Sync complete!"
