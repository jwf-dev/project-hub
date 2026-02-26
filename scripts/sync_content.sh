#!/usr/bin/env bash
# sync_content.sh
# Syncs Markdown files bidirectionally between Obsidian vault and Hugo site.
#
# USAGE:
#   ./scripts/sync_content.sh              # Sync vault → site (vault is source of truth)
#   ./scripts/sync_content.sh --to-vault   # Sync site → vault (for created projects)
#   ./scripts/sync_content.sh --both       # Bidirectional sync
#
# VAULT LOCATIONS:
#   Mac (iCloud):      /Users/awitten/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Project\ Vault/
#   Linux simulation:  ~/iCloudDrive/ObsidianVault/

set -euo pipefail

# Default vault path (Mac iCloud)
VAULT_ROOT="${VAULT_ROOT:-/Users/awitten/Library/Mobile Documents/iCloud~md~obsidian/Documents/Project Vault}"

# If vault doesn't exist, try fallback location
if [ ! -d "$VAULT_ROOT" ]; then
  VAULT_ROOT="${VAULT_ROOT:-$HOME/iCloudDrive/ObsidianVault}"
fi

SRC="${VAULT_ROOT}/Publish"
DST="$(dirname "$0")/../site/content"
MODE="${1:-vault-to-site}"  # Default: vault → site

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Utility functions
log_info() {
  echo -e "${GREEN}✓${NC} $1"
}

log_error() {
  echo -e "${RED}✗${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}⚠${NC} $1"
}

# Check if source exists
check_source() {
  if [ ! -d "$SRC" ]; then
    log_error "Publish folder not found at: $SRC"
    echo ""
    echo "Set VAULT_ROOT environment variable if your vault is elsewhere:"
    echo "  VAULT_ROOT=/path/to/vault ./scripts/sync_content.sh"
    echo ""
    echo "Expected structure:"
    echo "  \$VAULT_ROOT/Publish/"
    echo "  ├── Projects/"
    echo "  └── Notes/"
    exit 1
  fi
}

# Sync vault → site (vault is source of truth)
sync_vault_to_site() {
  log_info "Syncing from Obsidian vault to Hugo site..."
  echo "   Source: $SRC"
  echo "   Target: $DST"
  echo ""
  
  mkdir -p "$DST"
  
  # Sync with --delete (remove files in site if deleted from vault)
  rsync -av --delete "$SRC/" "$DST/"
  
  log_info "Sync complete! Changes from vault are now on the website."
}

# Sync site → vault (copy new projects back to Obsidian)
sync_site_to_vault() {
  log_warn "Syncing from Hugo site to Obsidian vault..."
  echo "   Source: $DST"
  echo "   Target: $SRC"
  echo ""
  
  # Sync WITHOUT --delete (don't remove vault files if they're missing in site)
  # This preserves vault files that might not be in the Hugo build
  rsync -av "$DST/" "$SRC/"
  
  log_info "Sync complete! New projects are now in your Obsidian vault."
  log_warn "Note: Check your Mac for the new files in Obsidian (might take a moment to sync via iCloud)"
}

# Show help
show_help() {
  cat << EOF
sync_content.sh - Sync Obsidian vault with Hugo site

USAGE:
  ./scripts/sync_content.sh              Sync vault → site (default, vault is source of truth)
  ./scripts/sync_content.sh --to-vault   Sync site → vault (push new projects back)
  ./scripts/sync_content.sh --both       Two-way sync (vault wins on conflicts)
  ./scripts/sync_content.sh --help       Show this help

WORKFLOWS:

  1. WORKFLOW: Edit in Obsidian, view on website
     $ nano/edit files in Obsidian on Mac
     $ ./scripts/sync_content.sh
     $ visit http://localhost:1313

  2. WORKFLOW: Create projects via automation, save to Obsidian
     $ python3 scripts/new_project.py "My Project"
     $ ./scripts/sync_content.sh --to-vault
     $ Check Obsidian on Mac (files should appear via iCloud)

  3. WORKFLOW: Two-way sync (be careful with conflicts!)
     $ ./scripts/sync_content.sh --both
     $ Vault changes overwrite site changes

VAULT PATHS:
  Default (Mac iCloud): /Users/awitten/Library/Mobile Documents/iCloud~md~obsidian/Documents/Project Vault
  Custom: VAULT_ROOT=/path/to/vault ./scripts/sync_content.sh

EOF
}

# Main
case "$MODE" in
  --to-vault)
    check_source
    sync_site_to_vault
    ;;
  --both)
    check_source
    log_info "Bidirectional sync (vault is source of truth for conflicts)"
    sync_vault_to_site
    sync_site_to_vault
    ;;
  --help|-h)
    show_help
    ;;
  vault-to-site|"")
    check_source
    sync_vault_to_site
    ;;
  *)
    log_error "Unknown mode: $MODE"
    show_help
    exit 1
    ;;
esac
