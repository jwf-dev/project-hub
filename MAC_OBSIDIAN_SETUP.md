# Mac Obsidian Setup Guide

## Your Vault Configuration

Your Obsidian vault is synced via iCloud and located at:

```
/Users/awitten/Library/Mobile Documents/iCloud~md~obsidian/Documents/Project Vault/
```

The Project Hub is configured to automatically use this path.

---

## Folder Structure Expected

```
~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Project Vault/
├── Publish/                    ← ONLY this folder syncs to website
│   ├── Projects/
│   │   ├── _index.md
│   │   ├── landing-page-design.md
│   │   ├── setup-home-lab.md
│   │   └── learn-hugo.md
│   └── Notes/
│       ├── _index.md
│       └── Getting Started.md
├── Private/                    ← NOT published (keep secrets here)
├── Archive/                    ← NOT published (old stuff)
└── (Other folders)             ← NOT published
```

**Only files in `Publish/` appear on the website.**

---

## Daily Workflow on Mac

### 1. Add a New Project

**Option A: Create in Obsidian (Recommended)**
```
1. Obsidian on Mac → Open "Project Vault"
2. Create new file: Publish/Projects/my-new-project.md
3. Add this frontmatter:
---
title: My New Project
date: 2026-02-26
status: idea
tags: [tag1, tag2]
summary: Short description
---

## Goal

## Notes

## Tasks

## Links
4. Save the file
5. Terminal: ./scripts/sync_content.sh
6. Visit http://localhost:1313/projects/ to see it!
```

**Option B: Create via Automation (Then Edit in Obsidian)**
```bash
# On Linux machine
python3 scripts/new_project.py "My New Project"

# Then sync back to Mac
./scripts/sync_content.sh --to-vault

# Wait 30 seconds for iCloud sync
# File appears in Obsidian on Mac!

# Edit in Obsidian
# Then sync again to website
./scripts/sync_content.sh
```

### 2. Edit Existing Project

**On Mac in Obsidian:**
```
1. Open Project Vault
2. Edit Publish/Projects/setup-home-lab.md
3. Save (Obsidian auto-saves)
4. iCloud syncs automatically (5-10 seconds)
```

**On Linux to view changes:**
```bash
./scripts/sync_content.sh
# Website updates instantly at http://localhost:1313
```

### 3. Add a Note

**On Mac in Obsidian:**
```
1. Create file: Publish/Notes/my-note.md
2. Add frontmatter:
---
title: My Note Title
date: 2026-02-26
tags: [tag1, tag2]
---

3. Write your content
4. Save
```

**On Linux to publish:**
```bash
./scripts/sync_content.sh
# Note appears at http://localhost:1313/notes/
```

---

## Sync Directions Explained

### Scenario 1: Editing in Obsidian, Viewing on Website

```
Mac (Obsidian)
    ↓ Edit file in Publish/
    ↓ Save (auto-saves)
    ↓ iCloud syncs (5-30 sec)
    
Linux VM
    $ ./scripts/sync_content.sh
    ↓ Copies from vault to site/content/
    ↓ Hugo rebuilds
    
Website
    → http://localhost:1313 updates!
```

**Command:**
```bash
./scripts/sync_content.sh    # or ./scripts/sync_content.sh vault-to-site (same thing)
```

### Scenario 2: Creating Projects on Linux, Viewing in Obsidian

```
Linux VM
    $ python3 scripts/new_project.py "Title"
    ↓ Creates site/content/Projects/title.md
    
    $ ./scripts/sync_content.sh --to-vault
    ↓ Copies from site/content/ to vault Publish/
    ↓ iCloud syncs file to Mac
    
Mac (Obsidian)
    → File appears in Publish/Projects/ after 10-30 sec
    → Reload vault if needed (Settings → Reload vault)
```

**Commands:**
```bash
# Create project
python3 scripts/new_project.py "My Project"

# Edit it
nano site/content/Projects/my-project.md

# Sync back to Obsidian
./scripts/sync_content.sh --to-vault
```

---

## Handling iCloud Sync Delays

**Problem:** File appeared on Linux but not in Obsidian on Mac yet.

**Why:** iCloud syncs asynchronously (5-30 second delay).

**Solutions:**

1. **Wait longer** (simplest)
   - Usually syncs within 10 seconds
   - Give it 30 seconds to be safe

2. **Force Obsidian to reload**
   - Obsidian menu → Settings (gear icon)
   - Click "Reload vault" button
   - File should appear

3. **Check iCloud Drive manually**
   - Open Finder → iCloud Drive → Mobile Documents → iCloud~md~obsidian/
   - Navigate to Documents/Project Vault/Publish/
   - File should be there

4. **Verify file synced to Mac**
   ```bash
   # On Mac in Terminal
   ls -la ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Project\ Vault/Publish/Projects/
   ```

---

## Using Wikilinks in Obsidian

Project Hub supports `[[Note Name]]` wikilinks!

**In Obsidian:**
```markdown
See also: [[Getting Started]] and [[setup-home-lab]]
```

**On Website:**
```html
<a href="/getting-started/">Getting Started</a> and <a href="/setup-home-lab/">setup-home-lab</a>
```

---

## Keeping Secrets Out

**Never put credentials in `Publish/` folder.**

**Good practice:**
```
Project Vault/
├── Publish/        ← SAFE (website-published)
│   ├── Projects/
│   └── Notes/
└── Private/        ← SECRET (not published)
    ├── Passwords.md
    ├── API Keys.md
    └── Personal Stuff.md
```

**Sync only Publish/, never Private/ or other folders.**

---

## Workflow Checklist

### Before Syncing
- [ ] File is in `Publish/` folder (not Private/, Archive/, etc.)
- [ ] Frontmatter has: title, date, (tags optional)
- [ ] File saved in Obsidian
- [ ] iCloud sync completed (give it 10-30 sec)

### Sync Command
- [ ] `./scripts/sync_content.sh` for vault → website (default)
- [ ] `./scripts/sync_content.sh --to-vault` for website → vault (after automation)
- [ ] Check website at http://localhost:1313

### After Sync
- [ ] Check website for new content
- [ ] Verify dark mode works
- [ ] Check mobile view (responsive design)
- [ ] Optional: `git commit` and `git push` to GitHub

---

## Troubleshooting

### File Created on Linux, Not Appearing in Obsidian

**Check these:**
1. File is in `site/content/Projects/` or `site/content/Notes/`
2. Run `./scripts/sync_content.sh --to-vault`
3. Wait 30 seconds for iCloud
4. Check Obsidian → Settings → Reload vault
5. Verify folder: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Project Vault/Publish/`

### File Edited in Obsidian, Not Appearing on Website

**Check these:**
1. File is in `Publish/` folder (not other folders)
2. iCloud sync completed (check in Obsidian status bar)
3. Run `./scripts/sync_content.sh`
4. Refresh http://localhost:1313

### Sync Script Says "Vault Not Found"

**Problem:** Script can't find Mac vault path.

**Solution:**
```bash
# Manually set path
export VAULT_ROOT="/Users/awitten/Library/Mobile Documents/iCloud~md~obsidian/Documents/Project Vault"

# Then run sync
./scripts/sync_content.sh
```

**Or verify path exists:**
```bash
ls "/Users/awitten/Library/Mobile Documents/iCloud~md~obsidian/Documents/Project Vault/"
```

---

## Advanced: Set Vault Path Permanently

Add to your shell config:

**For Zsh (default on recent Macs):**
```bash
echo 'export VAULT_ROOT="/Users/awitten/Library/Mobile Documents/iCloud~md~obsidian/Documents/Project Vault"' >> ~/.zshrc
source ~/.zshrc
```

**For Bash:**
```bash
echo 'export VAULT_ROOT="/Users/awitten/Library/Mobile Documents/iCloud~md~obsidian/Documents/Project Vault"' >> ~/.bash_profile
source ~/.bash_profile
```

Now you can use `./scripts/sync_content.sh` from anywhere!

---

## Git Integration

After syncing, commit your changes:

```bash
cd /home/openclaw/.openclaw/workspace/upload/Project-Hub

# See what changed
git status

# Stage and commit
git add site/content/
git commit -m "Add new projects from Obsidian"

# Push to GitHub
git push
```

This creates a history of your project and note changes!

---

## Summary

**The Easy Way:**

1. Edit in Obsidian on Mac (Publish/ folder)
2. Run `./scripts/sync_content.sh` on Linux
3. View at http://localhost:1313
4. Done! ✓

**For Creating Projects on Linux:**

1. Run `python3 scripts/new_project.py "Title"`
2. Edit the file
3. Run `./scripts/sync_content.sh --to-vault`
4. Wait 30 seconds
5. Check Obsidian on Mac (reload vault if needed)
6. Done! ✓

---

**Questions?** Check SYNC_GUIDE.md for detailed rsync mechanics!
