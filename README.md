# Project Hub

A lightweight, local-first Hugo website that renders a curated subset of your Obsidian vault. Everything runs on your home network—no public hosting, no cloud sync required.

## Overview

- **Obsidian Integration**: Syncs notes from your `Publish/` folder (via iCloud Drive or manual sync)
- **Local Serving**: Docker Compose runs Hugo in dev mode on `http://localhost:1313`
- **Safety First**: Only publishes files you explicitly place in `Publish/`
- **Project Management**: Built-in project creation tool with status tracking
- **No Secrets**: Guidance to keep credentials out of published content

## Quick Start

### Prerequisites
- Docker & Docker Compose
- Your Obsidian vault synced to `~/iCloudDrive/ObsidianVault` (or set `VAULT_ROOT` env var)

### 1. Clone/Set Up
```bash
cd Project-Hub
chmod +x scripts/*.sh
```

### 2. Run Hugo Server
```bash
docker compose up
```
Visit `http://localhost:1313` in your browser. The site hot-reloads when you save files.

### 3. Stop Server
```bash
docker compose down
```

## Daily Workflow

### Sync Notes from Your Vault
```bash
./scripts/sync_content.sh
```
This copies your `Publish/` folder contents to `site/content/`, preserving directory structure.

### Create a New Project
```bash
python scripts/new_project.py "My New Project"
```
This creates a template file in `site/content/Projects/` with frontmatter and sections:
- **Goal**: What are you building?
- **Notes**: Thoughts and research
- **Tasks**: Actionable items
- **Links**: Related references

Edit the file, save, and it appears on the Projects page (organized by status: idea → active → done).

### Add Regular Notes
Place Markdown files anywhere under `site/content/Notes/` and run the sync script. The Notes section will list them chronologically.

## Project Structure

```
Project-Hub/
├── docker-compose.yml          # Dev server config
├── README.md                   # This file
├── .gitignore                  # Excludes secrets, caches, iCloud
├── site/                       # Hugo source
│   ├── config.toml             # Hugo config
│   ├── content/                # Markdown files
│   │   ├── Projects/           # Project pages
│   │   │   └── _index.md       # Projects list page
│   │   └── Notes/              # Regular notes
│   │       └── _index.md       # Notes list page
│   └── layouts/                # HTML templates
└── scripts/
    ├── sync_content.sh         # Sync from vault to site/content
    └── new_project.py          # Create new project template
```

## Wikilink Support

The site includes basic wikilink conversion (`[[Note Name]]` → `/Note-Name/`). For best results:
- Use `[[Link]]` syntax in your notes
- Or use standard Markdown: `[Link](../path-to-file)`

## Safety & Privacy

### ⚠️ DO NOT PUBLISH SECRETS

**Keep all credentials out of the `Publish/` folder.** This repo will be shared/backed up; assume anything in `site/content/` is visible.

**Best practices:**
1. Use separate folders in Obsidian:
   - `Publish/` → Safe to publish (projects, notes, ideas)
   - `Private/` → Credentials, personal reflections (not synced here)
2. Before committing or sharing:
   - Check `.gitignore` rules (already excludes `.obsidian/`, `.DS_Store`)
   - Audit `site/content/` for accidental secrets
3. Add secrets to `.env` files (not tracked) if you need them for tooling

### Git Ignore Rules

The `.gitignore` prevents:
- `.obsidian/` — Obsidian app metadata
- `.DS_Store` — macOS system files
- `node_modules/` — Dependencies
- `*.log` — Log files
- iCloud sync folders (`.git/`, cache dirs)

## Configuration

### Custom Vault Path
If your vault isn't at `~/iCloudDrive/ObsidianVault`:
```bash
VAULT_ROOT=/path/to/your/vault ./scripts/sync_content.sh
```

### Hugo Server Port
Edit `docker-compose.yml` to change the port:
```yaml
ports:
  - "8080:1313"  # Access at http://localhost:8080
```

### Change Base URL
Edit `site/config.toml`:
```toml
baseURL = "http://my-home-server:1313/"
```

## Troubleshooting

### "Port 1313 already in use"
```bash
docker compose down  # Stop any running instance
docker compose up
```

### Sync script: "Publish folder not found"
```bash
# Set correct path to your vault
VAULT_ROOT=/Users/yourname/path/to/vault ./scripts/sync_content.sh
```

### Wikilinks not working
Use standard Markdown instead: `[Note Name](../note-name/)`

### Hugo build errors
Check `site/content/` YAML frontmatter:
```yaml
---
title: My Page
date: 2026-02-26
---
```

## Advanced: GitHub Setup

Initialize a git repo and push to GitHub:
```bash
cd Project-Hub
git init
git add .
git commit -m "Initial commit: Project Hub"
git remote add origin https://github.com/YOUR_USER/project-hub.git
git branch -M main
git push -u origin main
```

Add a collaborator:
```bash
gh repo collaborators add andywitt1 --permission push
```

## Extending

- **Add custom theme**: Replace layouts in `site/layouts/`
- **Custom CSS**: Edit `site/layouts/_default/baseof.html` and add `<style>` blocks
- **Hugo themes**: Place in `site/themes/` and update `config.toml`
- **Static files**: Add to `site/static/` (images, PDFs, etc.)

## License

Use this however you like. Attribution appreciated.

---

**Questions?** Check Hugo docs: https://gohugo.io/documentation/
