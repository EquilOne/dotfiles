---
name: crafting-effective-readmes
description: Use when writing, updating, reviewing, or improving README files for any project type. Provides audience-matched templates for open-source libraries, personal projects, internal tools, and config directories. Triggers on: "write a README", "create a README", "document this project", "add documentation", "README is stale", "what sections should my README have?", "update the README", "review my README", "improve my README", "project needs a README".
---

# Crafting Effective READMEs

## Overview

READMEs answer questions your audience will have. Different audiences need different information - a contributor to an OSS project needs different context than future-you opening a config folder.

**Always ask:** Who will read this, and what do they need to know?

## Process

### Step 1: Identify the Task and Audience

**Ask these two questions first:**
1. "What README task are you working on?" (creating, adding, updating, reviewing)
2. "Who is the primary reader?" (contributors, future-you, teammates, users)

These two answers determine everything else. If unclear, **ask before drafting** — don't assume OSS defaults.

### Step 2: Task-Specific Questions

**Creating initial README:**
1. What type of project? (see Project Types below)
2. What problem does this solve in one sentence?
3. What's the quickest path to "it works"?
4. Anything notable to highlight?

**Adding a section:**
1. What needs documenting?
2. Where should it go in the existing structure?
3. Who needs this info most?

**Updating existing content:**
1. What changed?
2. Read current README, identify stale sections
3. Propose specific edits

**Reviewing/refreshing:**
1. Read current README
2. Check against actual project state (package.json, main files, etc.)
3. Flag outdated sections
4. Update "Last reviewed" date if present

### Step 3: Always Ask

After drafting, ask: **"Anything else to highlight or include that I might have missed?"**

## Loading References and Templates

**MANDATORY**: Based on identified project type, read the **entire** template file before drafting:

| Project Type | Load Template | Also Consider |
|--------------|---------------|---------------|
| Open Source | `templates/oss.md` | `references/standard-readme-spec.md` if user wants compliance |
| Personal    | `templates/personal.md` | — |
| Internal    | `templates/internal.md` | — |
| Config (XDG, dotfiles) | `templates/xdg-config.md` | — |

**Conditional references** (load only when triggered):
- `references/art-of-readme.md` — when user asks "what makes a README good?" or wants philosophy
- `references/make-a-readme.md` — when drafting a section and unsure what to include
- `references/standard-readme-spec.md` — when user mentions compliance, standardization, or OSS publication

**Do NOT load all references upfront.** Pick the one most relevant to the current sub-task. See `using-references.md` for the full guide.

## Project Types

| Type | Audience | Key Sections | Template |
|------|----------|--------------|----------|
| **Open Source** | Contributors, users worldwide | Install, Usage, Contributing, License | `templates/oss.md` |
| **Personal** | Future you, portfolio viewers | What it does, Tech stack, Learnings | `templates/personal.md` |
| **Internal** | Teammates, new hires | Setup, Architecture, Runbooks | `templates/internal.md` |
| **Config** | Future you (confused) | What's here, Why, How to extend, Gotchas | `templates/xdg-config.md` |

**Ask the user** if unclear. Don't assume OSS defaults for everything.

## Essential Sections (All Types)

Every README needs at minimum:

1. **Name** - Self-explanatory title
2. **Description** - What + why in 1-2 sentences  
3. **Usage** - How to use it (examples help)

## References

- `section-checklist.md` - Which sections to include by project type
- `style-guide.md` - Common README mistakes and prose guidance
- `using-references.md` - Guide to deeper reference materials
