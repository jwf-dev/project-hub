# System Architecture Diagram

## Complete Data Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                         YOUR ECOSYSTEM                              │
└─────────────────────────────────────────────────────────────────────┘

                            Mac (Your Laptop)
                            ═══════════════════════════════════════
                            
    ┌──────────────────────────────────────────────────────┐
    │  Obsidian App (Project Vault)                       │
    │  /Users/awitten/Library/Mobile Documents/...       │
    │  ├── Publish/          ← SYNCED TO WEBSITE         │
    │  │   ├── Projects/                                  │
    │  │   │   ├── landing-page-design.md               │
    │  │   │   ├── setup-home-lab.md                    │
    │  │   │   └── learn-hugo.md                        │
    │  │   └── Notes/                                    │
    │  │       └── Getting Started.md                    │
    │  └── Private/          ← NOT SYNCED (Secrets)      │
    └──────────────────────────────────────────────────────┘
              ↓
              │ (iCloud Drive)
              │
    ┌──────────────────────────────────────────────────────┐
    │  File System (synced via iCloud)                    │
    │  Acts as sync point between Mac & Linux            │
    └──────────────────────────────────────────────────────┘
              ↓
              │ (SSH/Mount)
              │
            ══════════════════════════════════════════════════════════════
            
                        Linux VM (Your Server)
                        ═══════════════════════════════════════════════════
            
    ┌──────────────────────────────────────────────────────┐
    │  Project Hub Repository                             │
    │  /home/openclaw/.../Project-Hub/                    │
    │                                                      │
    │  ├── site/content/            ← SYNCED FROM VAULT   │
    │  │   ├── Projects/                                  │
    │  │   │   ├── landing-page-design.md               │
    │  │   │   ├── setup-home-lab.md                    │
    │  │   │   └── learn-hugo.md                        │
    │  │   └── Notes/                                    │
    │  │       └── Getting Started.md                    │
    │  │                                                  │
    │  ├── site/layouts/            ← HTML Templates      │
    │  ├── site/config/             ← Hugo Config         │
    │  ├── site/static/css/         ← Shock Theme CSS     │
    │  │   └── shock-inspired.css                        │
    │  │                                                  │
    │  └── scripts/                 ← Automation          │
    │      ├── sync_content.sh      ← Bidirectional      │
    │      └── new_project.py       ← Create Projects     │
    └──────────────────────────────────────────────────────┘
              ↓
              │ (Docker)
              │
    ┌──────────────────────────────────────────────────────┐
    │  Hugo Static Site Generator                         │
    │  klakegg/hugo:latest-ext (Docker Container)        │
    │                                                      │
    │  Processes: Markdown → HTML                        │
    │  Rebuilds on file changes (live reload)            │
    │  Watches: site/content/, site/layouts/, config     │
    └──────────────────────────────────────────────────────┘
              ↓
              │
    ┌──────────────────────────────────────────────────────┐
    │  Local Web Server (Port 1313)                       │
    │  http://localhost:1313                             │
    │  Served on your home network                       │
    └──────────────────────────────────────────────────────┘
              ↓
              │
    ┌──────────────────────────────────────────────────────┐
    │  Your Browser                                        │
    │  Theme: Shock (Bootstrap-inspired)                 │
    │  Features:                                          │
    │  • Dark mode (auto)                                │
    │  • Responsive grid                                 │
    │  • Project status badges                           │
    │  • Tag pages                                       │
    │  • Print friendly                                  │
    └──────────────────────────────────────────────────────┘

            
            Also synced to:
            ═══════════════════════════════════════════════════════════════
            
    ┌──────────────────────────────────────────────────────┐
    │  GitHub Repository                                  │
    │  github.com/jwf-dev/project-hub (Public)           │
    │  Collaborators: andywitt1 (push access)            │
    │  History: All commits synced                       │
    └──────────────────────────────────────────────────────┘
```

---

## Sync Modes Explained

### Mode 1: Vault → Website (Default, Safe)

```
Mac Obsidian               Linux VM                Browser
─────────────────────────────────────────────────────────────

┌─────────┐     iCloud      ┌──────────┐      Hugo      ┌────────┐
│ Edit in │  ─────sync───→  │ Sync to  │  ──rebuild──→  │ View   │
│Obsidian │    (5-30 sec)    │  site/   │   (instant)    │ on web │
│ Publish/│                  │ content/ │                │        │
└─────────┘                  └──────────┘                └────────┘
                             
                             $ ./scripts/sync_content.sh

When to use:
  • Obsidian on Mac is your main editor
  • Vault is "source of truth"
  • Safe: old files deleted, keeps clean state
  
Safety: HIGH (vault controls website)
```

### Mode 2: Website → Vault (Add Only)

```
Linux VM                   iCloud              Mac Obsidian
─────────────────────────────────────────────────────────────

┌──────────────┐    Rsync (no    ┌────────┐    iCloud     ┌─────────┐
│Create project│  ──delete)───→  │ Sync to│  ──sync───→  │ Appears │
│via automation│  (10-30 sec)      │ vault/ │  (5-30 sec)   │ in Obs. │
│site/content/ │                  │Publish/│              │         │
└──────────────┘                  └────────┘              └─────────┘
                             
              $ ./scripts/sync_content.sh --to-vault

When to use:
  • Created projects via automation on Linux
  • Want to edit them in Obsidian
  • Safe: NO --delete, so vault files never disappear
  
Safety: VERY HIGH (vault files preserved)
```

### Mode 3: Bidirectional (Both Ways)

```
Mac Obsidian               Linux VM            Browser/Website
─────────────────────────────────────────────────────────────

Step 1: Vault → Website
┌────────────┐ rsync --delete  ┌──────────┐  Hugo rebuild  ┌────────┐
│  Publish/  │───────────────→ │ content/ │─────────────→  │ View   │
│ (wins!)    │   (vault wins)   │          │   (instant)    │ on web │
└────────────┘                  └──────────┘                └────────┘

Step 2: Website → Vault  
┌──────────┐  rsync (no del)   ┌────────────┐  iCloud sync  ┌────────┐
│ content/ │────────────────→  │  Publish/  │─────────────→ │ Obs.   │
│          │   (add new)        │ (add only) │  (5-30 sec)   │ Reload │
└──────────┘                    └────────────┘               └────────┘

              $ ./scripts/sync_content.sh --both

When to use:
  • Want full bidirectional sync
  • Edit in both places
  • Vault changes win on conflicts
  
Safety: MEDIUM (discipline required: don't edit same file in both places)
```

---

## File Flow Examples

### Example 1: Edit Project in Obsidian

```
1. On Mac
   Obsidian → open "setup-home-lab.md"
   Edit: Add new task "Configure backups"
   Save: Cmd+S (auto-saves)

2. iCloud syncs (5-30 sec)
   ~/Library/Mobile Documents/.../Publish/Projects/setup-home-lab.md
   (Updated file)

3. On Linux VM
   $ ./scripts/sync_content.sh
   Output: Syncing from /Users/awitten/Library/.../Publish
           ✓ Copying Projects/setup-home-lab.md
           ✓ Sync complete!

4. Hugo rebuilds (automatic)
   source changed WRITE /src/content/Projects/setup-home-lab.md
   Built in 5 ms

5. In browser
   http://localhost:1313/projects/setup-home-lab/
   (Shows updated task in HTML)
```

### Example 2: Create Project on Linux

```
1. On Linux VM
   $ python3 scripts/new_project.py "Design System"
   ✓ Created /site/content/Projects/design-system.md
   
   $ nano site/content/Projects/design-system.md
   (Edit frontmatter and content)

2. Sync back to Obsidian
   $ ./scripts/sync_content.sh --to-vault
   rsync: Copying site/content/Projects/ → vault Publish/Projects/
   ✓ design-system.md synced

3. iCloud syncs to Mac (10-30 sec)
   ~/Library/Mobile Documents/.../Publish/Projects/design-system.md
   (New file appears)

4. On Mac in Obsidian
   Projects folder refreshes
   design-system.md now visible
   (May need: Settings → Reload vault)
   
   Can now edit in Obsidian!

5. Next sync pulls changes back
   $ ./scripts/sync_content.sh
   Website shows latest version
```

---

## Conflict Resolution

### What if I edit the same file in both places?

```
SCENARIO: design-system.md edited on Mac AND Linux

Mac Obsidian (Version A)
  ## Goal
  Create a reusable component system
  
  ## Tasks
  - [x] Set up foundation
  - [ ] Design buttons        ← You added this
  
vs.

Linux site/content (Version B)
  ## Goal
  Create a design system
  
  ## Tasks
  - [x] Set up foundation
  - [ ] Design forms          ← You added this

SOLUTION 1: Default mode (vault → website)
  $ ./scripts/sync_content.sh
  → Mac version (A) wins
  → Linux loses "Design forms" task
  
SOLUTION 2: Website → vault
  $ ./scripts/sync_content.sh --to-vault
  → Linux version (B) wins
  → Obsidian loses "Design buttons" task
  
SOLUTION 3: Manual merge
  $ git diff                  → see what changed
  $ Manually edit the file
  $ Choose what to keep from both
  
BEST PRACTICE: Avoid this!
  • Edit in ONE place per file
  • Sync FROM that place
  • Don't edit simultaneously in both locations
```

---

## Internet Connectivity Flow

```
No Internet on Linux VM? No problem!

┌─────────────────────────────────────────────────────────────┐
│ Obsidian on Mac still works (all local)                     │
└─────────────────────────────────────────────────────────────┘
              ↓
          iCloud stores file (local copy on Mac HD)
              ↓
┌─────────────────────────────────────────────────────────────┐
│ When Linux VM reconnects:                                   │
│ $ ./scripts/sync_content.sh                                │
│ → Pulls updated files from Mac (via mounted iCloud)        │
│ → Hugo rebuilds                                            │
│ → Website updates                                          │
└─────────────────────────────────────────────────────────────┘

Everything is LOCAL first, synced later!
```

---

## Performance Considerations

```
Sync Speed:
  • Default (vault → site): ~1-2 sec (only changed files)
  • Website → vault: ~1-2 sec (same)
  • Bidirectional: ~2-3 sec (2 syncs)
  
Hugo Rebuild:
  • Small changes: 5-10 ms
  • First load: 50-100 ms
  • Browser refresh: instant (live reload)

iCloud Sync:
  • Small files (<1 MB): 5-10 sec
  • Batch files: 10-30 sec
  • Unreliable WiFi: up to 60 sec

Bottleneck: Usually iCloud sync, not rsync or Hugo!
```

---

## Backup & Recovery

```
Accidental deletion?

Step 1: Git to the rescue
  $ git status
  (Shows deleted files)
  
  $ git checkout site/content/Projects/deleted-project.md
  (Restores from last commit)

Step 2: Commit the recovery
  $ git add site/content/
  $ git commit -m "Recover deleted project"
  $ git push

Your file is back!
No time machine needed.
```

---

## Summary Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                   PROJECT HUB ECOSYSTEM                          │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  INPUT SOURCES:                                                  │
│  • Obsidian on Mac (main)        → iCloud Drive                 │
│  • Automation on Linux           → Direct to site/content/      │
│  • Manual editing anywhere       → Sync script                  │
│                                                                  │
│  PROCESSING:                                                     │
│  • rsync (bidirectional)         → Copies files smart           │
│  • Hugo (static generator)       → Markdown → HTML              │
│  • Docker (containerized)        → Runs locally                 │
│                                                                  │
│  OUTPUT:                                                         │
│  • Website (port 1313)           → Your browser                 │
│  • GitHub (public)               → Shareable & backed up        │
│  • Obsidian (vault)              → Edited on Mac                │
│                                                                  │
│  FEATURES:                                                       │
│  • Bidirectional sync            → Edit anywhere, sync anytime  │
│  • Shock theme styling           → Professional look (aao.fyi)  │
│  • Dark mode                      → Automatic                   │
│  • Responsive design             → Mobile friendly              │
│  • Git history                   → Full version control         │
│  • Local-first                   → Works without internet       │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## Quick Decision Tree

```
Do you want to...

Edit in Obsidian on Mac?
  YES → ./scripts/sync_content.sh (vault → website)
  
Add a project on Linux?
  YES → python3 scripts/new_project.py "Title"
     → nano site/content/Projects/...
     → ./scripts/sync_content.sh --to-vault
     
Keep everything perfectly synced?
  YES → ./scripts/sync_content.sh --both
  (But don't edit same file in both places!)
  
See all options?
  → ./scripts/sync_content.sh --help
  
Understand rsync in detail?
  → Read SYNC_GUIDE.md
  
Mac Obsidian workflows?
  → Read MAC_OBSIDIAN_SETUP.md
```

---

**Your system is optimized for:**
- ✅ Writing in Obsidian on Mac
- ✅ Publishing to a local website
- ✅ Syncing both directions as needed
- ✅ Keeping a full git history
- ✅ Sharing via GitHub
- ✅ Working without internet (mostly)
- ✅ Beautiful Shock theme styling
