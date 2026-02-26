#!/usr/bin/env python3
"""
Create a new project note in Publish/Projects/.

Usage:
  python scripts/new_project.py "Project Title"

This creates a new Markdown file with frontmatter and template sections.
The file is automatically picked up by Hugo and displayed on the Projects page.
"""

import sys
import pathlib
import datetime
import os

def main():
    if len(sys.argv) < 2:
        print("Usage: python scripts/new_project.py \"Project Title\"")
        print("\nExample: python scripts/new_project.py \"Design Landing Page\"")
        sys.exit(1)
    
    title = sys.argv[1]
    
    # Determine paths
    script_dir = pathlib.Path(__file__).parent
    projects_dir = script_dir.parent / "site" / "content" / "Projects"
    projects_dir.mkdir(parents=True, exist_ok=True)
    
    # Create filename from title
    slug = title.lower().replace(" ", "-").replace("'", "")
    filename = f"{slug}.md"
    filepath = projects_dir / filename
    
    # Check if file already exists
    if filepath.exists():
        print(f"⚠️  File already exists: {filepath}")
        sys.exit(1)
    
    # Get current date in ISO format
    date = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d")
    
    # Create frontmatter and template
    content = f"""---
title: {title}
date: {date}
status: idea
tags: []
summary: 
---

## Goal

## Notes

## Tasks

## Links
"""
    
    # Write file
    filepath.write_text(content, encoding="utf-8")
    print(f"✅ Created project: {filepath}")
    print(f"   Edit the file to add details, then run 'docker compose up' to see it on the website.")

if __name__ == "__main__":
    main()
