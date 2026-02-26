# Bidirectional Sync Guide

## How the Sync Works

Your Project Hub can now sync **both ways** with your Obsidian vault on Mac.

### What is Rsync?

`rsync` is a file synchronization tool that copies files intelligently:
- Only transfers **changed** files (fast)
- Can mirror directories (one-way or two-way)
- Preserves permissions, timestamps, and structure

**Analogy:** Think of it like photocopying files from Folder A to Folder B, but it only copies pages that changed.

---

## Setup: Mac Obsidian Vault Path

Your vault is at:
```
/Users/awitten/Library/Mobile Documents/iCloud~md~obsidian/Documents/Project Vault/
```

The sync script automatically detects this path. If it doesn't work, set it manually:

```bash
export VAULT_ROOT="/Users/awitten/Library/Mobile Documents/iCloud~md~obsidian/Documents/Project Vault"
./scripts/sync_content.sh
```

Or add to your shell config (`~/.zshrc` or `~/.bash_profile`):
```bash
export VAULT_ROOT="/Users/awitten/Library/Mobile Documents/iCloud~md~obsidian/Documents/Project Vault"
```

---

## Sync Workflows

### 1. Vault → Website (Default)
**Scenario:** You edit notes in Obsidian on Mac, view them on the website.

```bash
./scripts/sync_content.sh
```

**What happens:**
```
~/Library/Mobile Documents/iCloud~.../Project Vault/Publish/
  ↓ (rsync -av --delete)
Project-Hub/site/content/
  ↓ (Hugo rebuilds)
http://localhost:1313 (updates instantly)
```

**Syntax breakdown:**
```bash
rsync -av --delete "$SRC/" "$DST/"
  -a  = archive (preserve timestamps/permissions)
  -v  = verbose (show what's copied)
  --delete = remove files in $DST if gone from $SRC (keeps them in sync)
  "$SRC/"  = source with trailing slash (= copy contents)
  "$DST/"  = destination with trailing slash (= into folder)
```

### 2. Website → Vault (Sync Back)
**Scenario:** You create projects via `new_project.py`, sync back to Obsidian on Mac.

```bash
./scripts/sync_content.sh --to-vault
```

**What happens:**
```
Project-Hub/site/content/
  ↓ (rsync -av, NO --delete)
~/Library/Mobile Documents/iCloud~.../Project Vault/Publish/
  ↓ (iCloud sync)
Obsidian on Mac (files appear after a moment)
```

**Why no `--delete` here?**
- Vault files might not be in the Hugo build (drafts, private notes, etc.)
- We copy new projects TO the vault, don't remove existing files

### 3. Bidirectional Sync (Both Ways)
**Scenario:** You want everything in sync both directions.

```bash
./scripts/sync_content.sh --both
```

**What happens:**
```
1. Vault → Website (with --delete, vault wins conflicts)
2. Website → Vault (adds new files)
```

**⚠️ Warning:** If you edit the same file in both places, vault version wins.

---

## Daily Workflow Example

### Morning: Edit in Obsidian, View on Website

On your Mac:
1. Open Obsidian → Project Vault
2. Edit `Publish/Projects/setup-home-lab.md`
3. Save in Obsidian

On your Linux machine:
```bash
cd Project-Hub
./scripts/sync_content.sh          # Pull changes from Mac

# Open browser
http://localhost:1313/projects/setup-home-lab/
# See your updated project!
```

### Afternoon: Create New Project on Website, Sync Back to Mac

On your Linux machine:
```bash
cd Project-Hub

# Create new project via automation
python3 scripts/new_project.py "Build Mobile App"

# Edit the new project
nano site/content/Projects/build-mobile-app.md

# Sync back to Obsidian on Mac
./scripts/sync_content.sh --to-vault
```

Wait 10-30 seconds for iCloud to sync, then on your Mac:
```
Obsidian → Publish → Projects → build-mobile-app.md ✓ appears!
```

---

## Understanding Sync Direction

### One-Way Sync: Vault → Website (Safest)
```bash
rsync -av --delete vault/Publish/ site/content/
```
- **Source:** `vault/Publish/` (Obsidian on Mac)
- **Target:** `site/content/` (Hugo)
- **Result:** Vault is "source of truth"
- **Safety:** `--delete` removes old files from Hugo
- **Use case:** Obsidian is your main editor

### One-Way Sync: Website → Vault (Add Only)
```bash
rsync -av site/content/ vault/Publish/
```
- **Source:** `site/content/` (Hugo)
- **Target:** `vault/Publish/` (Obsidian on Mac)
- **Result:** Adds new files, doesn't delete
- **Safety:** NO `--delete` preserves vault files
- **Use case:** Sync projects created via automation back to Obsidian

### Two-Way Sync: Both Directions (Careful!)
```bash
rsync -av --delete vault/Publish/ site/content/   # Vault wins
rsync -av site/content/ vault/Publish/             # Add to vault
```
- **Result:** Everything is synced, vault wins on conflicts
- **Safety:** Requires discipline not to edit the same file in both places
- **Use case:** Full bidirectional publishing

---

## Troubleshooting

### Sync Script Not Finding Vault

**Error:**
```
❌ Error: Publish folder not found at /Users/awitten/...
```

**Solution 1: Set VAULT_ROOT**
```bash
export VAULT_ROOT="/Users/awitten/Library/Mobile Documents/iCloud~md~obsidian/Documents/Project Vault"
./scripts/sync_content.sh
```

**Solution 2: Check vault path**
On your Mac in Terminal:
```bash
ls "/Users/awitten/Library/Mobile Documents/iCloud~md~obsidian/Documents/Project Vault/Publish/"
```

If the path is different, update it in the script.

### Files Not Appearing in Obsidian After Sync

**Problem:** You synced files to Mac, but Obsidian doesn't show them.

**Why:** iCloud takes 10-30 seconds to sync files on Mac.

**Solution:**
1. Wait 30 seconds
2. Or force Obsidian to refresh: Settings → Reload
3. Or check Obsidian's vault folder manually in Finder

### Files Disappeared After Sync

**Problem:** You synced vault → site with `--delete`, and old files vanished.

**Reason:** `--delete` removes files in the target that don't exist in source.

**Solution:**
1. Don't use `--delete` when syncing site → vault
2. Use `--to-vault` mode (no delete)
3. If needed, restore from git: `git checkout site/content/`

### Sync is Slow

**Problem:** Syncing takes too long.

**Why:** rsync scans all files each time.

**Optimization:** Use a tool like `lsyncd` for real-time sync (advanced setup).

---

## Git Integration

Synced files should be committed:

```bash
# After syncing
./scripts/sync_content.sh

# Check what changed
git status

# Commit changes
git add site/content/
git commit -m "Sync latest from vault"
git push
```

---

## Advanced: Custom Sync Script

If you want to automate syncing on a schedule, create a cron job:

```bash
# Open crontab editor
crontab -e

# Sync every 5 minutes during work hours
*/5 9-17 * * * cd /path/to/Project-Hub && ./scripts/sync_content.sh
```

---

## Summary

| Mode | Command | Direction | Delete? | Use Case |
|------|---------|-----------|---------|----------|
| Default (Safe) | `./scripts/sync_content.sh` | Vault → Site | Yes | Obsidian is main editor |
| Sync Back | `./scripts/sync_content.sh --to-vault` | Site → Vault | No | Add projects to vault |
| Bidirectional | `./scripts/sync_content.sh --both` | Both ways | Yes on 1st | Full sync (careful!) |
| Help | `./scripts/sync_content.sh --help` | — | — | Show all options |

---

**Tips:**
- Default mode is safest (vault is source of truth)
- Use `--to-vault` after creating projects via automation
- Use `--both` only if you're disciplined about not editing conflicts
- Always commit before big syncs
- Test with a small change first
