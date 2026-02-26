# Quick Start — Project Hub

Welcome! Your local Obsidian publishing site is ready.

## 🚀 Get Started (30 seconds)

### 1. The Site is Already Running
```bash
# Visit in your browser:
http://localhost:1313
```

The Hugo server is running in Docker and reloads automatically when you make changes.

### 2. Sync Notes from Obsidian
Your notes live in: `~/iCloudDrive/ObsidianVault/Publish/`

To sync to the website:
```bash
cd /home/openclaw/.openclaw/workspace/upload/Project-Hub
./scripts/sync_content.sh
```

The site will instantly rebuild.

### 3. Create a New Project
```bash
python3 scripts/new_project.py "My Cool Project"
```

This creates a markdown file in `site/content/Projects/` with a template. Edit it and save—the site updates automatically.

## 📝 Folder Structure

**Your Obsidian Vault:**
```
~/iCloudDrive/ObsidianVault/Publish/
├── Projects/           ← Your projects (auto-synced)
│   ├── landing-page-design.md
│   ├── setup-home-lab.md
│   └── learn-hugo.md
└── Notes/              ← Your notes (auto-synced)
    ├── Getting Started.md
    └── (your notes here)
```

**Website Project:**
```
/home/openclaw/.openclaw/workspace/upload/Project-Hub/
├── docker-compose.yml  ← Start/stop the server
├── site/               ← Hugo source
│   ├── config/_default/← Settings
│   ├── content/        ← Synced notes (read-only, refresh via ./scripts/sync_content.sh)
│   ├── layouts/        ← HTML templates
│   └── static/css/     ← Styling
└── scripts/
    ├── sync_content.sh ← Sync from vault
    └── new_project.py  ← Create new projects
```

## 🎨 Customization

### Change Colors
Edit `site/static/css/style.css` → look for `:root` section.

### Change Site Title
Edit `site/config/_default/hugo.toml` → change `title = "Project Hub"`

### Add More Sections
1. Create a folder under `site/content/` (e.g., `site/content/Tutorials/`)
2. Add `_index.md` for the list page
3. Add markdown files for content
4. Hugo auto-rebuilds

## 🌙 Dark Mode

The site automatically respects your system's dark mode preference. No settings needed.

## ⚠️ Important

- **Only edit files in `~/iCloudDrive/ObsidianVault/Publish/`** — this syncs to the website
- **Keep secrets out of `Publish/`** — use a different folder (e.g., `Private/`)
- **The `site/content/` folder is synced** — changes here are overwritten on sync

## 🚀 Running the Server

```bash
cd /home/openclaw/.openclaw/workspace/upload/Project-Hub

# Start the server
docker compose up

# Stop the server (in another terminal)
docker compose down

# Rebuild the site
docker compose restart
```

## 📤 Push Changes to GitHub

```bash
cd /home/openclaw/.openclaw/workspace/upload/Project-Hub

# See your changes
git status

# Stage and commit
git add -A
git commit -m "Update projects and notes"

# Push to GitHub
git push
```

GitHub: https://github.com/jwf-dev/project-hub

## 🆘 Troubleshooting

### Site won't load at localhost:1313
```bash
docker compose restart
docker logs project-hub
```

### Sync script fails
```bash
# Check that your vault exists:
ls ~/iCloudDrive/ObsidianVault/Publish/

# If it doesn't, set a custom path:
VAULT_ROOT=/path/to/vault ./scripts/sync_content.sh
```

### Projects not appearing
1. Make sure project files are in `~/iCloudDrive/ObsidianVault/Publish/Projects/`
2. Run `./scripts/sync_content.sh`
3. Refresh your browser

---

**Enjoy your personal knowledge hub!** 🎉

For more details, see [README.md](README.md)
