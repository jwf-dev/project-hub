# Project Hub

A professional, local-first Hugo website that renders a curated subset of your Obsidian vault. Everything runs on your home network—no public hosting, no cloud sync required.

## Overview

- **Obsidian Integration**: Syncs notes from your `Publish/` folder (via iCloud Drive or manual sync)
- **Professional Design**: Responsive layouts with modern styling (card-based UI, status badges, dark mode support)
- **Local Serving**: Docker Compose runs Hugo in dev mode on `http://localhost:1313` with live reload
- **Safety First**: Only publishes files you explicitly place in `Publish/`
- **Project Management**: Built-in automation for creating and organizing projects by status
- **No Secrets**: Guidance to keep credentials out of published content
- **Config as Code**: Hugo config/_default/ pattern for easy customization

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
├── docker-compose.yml          # Dev server config (Hugo on port 1313)
├── README.md                   # This file
├── .gitignore                  # Excludes secrets, caches, iCloud
├── site/                       # Hugo source directory
│   ├── config/
│   │   └── _default/
│   │       ├── hugo.toml       # Main Hugo configuration
│   │       └── params.toml     # Site parameters & metadata
│   ├── content/                # Markdown files (synced from vault)
│   │   ├── Projects/           # Project pages
│   │   │   ├── _index.md       # Projects list page
│   │   │   └── landing-page-design.md  # Example project
│   │   └── Notes/              # Regular notes (synced from Publish/)
│   │       └── _index.md       # Notes list page
│   ├── layouts/                # Custom HTML templates
│   │   ├── _default/
│   │   │   ├── baseof.html     # Base template (header/footer/nav)
│   │   │   ├── section.html    # Section pages (Projects, Notes lists)
│   │   │   ├── single.html     # Individual page layout
│   │   │   └── taxonomy.html   # Tag pages
│   │   └── index.html          # Home page
│   └── static/
│       └── css/
│           └── style.css       # Responsive styling
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

## Design & Styling

### Layout
- **Responsive**: Mobile-friendly design that works on phones, tablets, and desktops
- **Sticky Header**: Navigation bar stays at top while scrolling
- **Card-based UI**: Projects displayed as attractive cards with hover effects
- **Status Badges**: Visual indicators for project status (idea, active, done)

### Color Scheme
- **Primary**: #3498db (bright blue) — links and accents
- **Secondary**: #2c3e50 (dark gray) — headers and main text
- **Success**: #2ecc71 (green) — "done" status
- **Light**: #ecf0f1 (light gray) — backgrounds and borders

### Dark Mode
The site supports dark mode (respects system `prefers-color-scheme`). CSS automatically adjusts colors for readability.

### Customization
Edit `site/static/css/style.css` to:
- Change colors (update `:root` variables)
- Modify fonts (update `body` font-family)
- Adjust spacing (update margin/padding utilities)
- Add new components (add CSS classes and styles)

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
