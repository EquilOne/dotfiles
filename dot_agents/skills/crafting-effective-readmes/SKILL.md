---
name: crafting-effective-readmes
description: Use when writing, updating, reviewing, or improving README files for any project type. Provides audience-matched templates for open-source libraries, personal projects, internal tools, and config directories. Triggers on: "write a README", "create a README", "document this project", "add documentation", "README is stale", "what sections should my README have?", "update the README", "review my README", "improve my README", "project needs a README".
---

# Crafting Effective READMEs

## Overview

READMEs answer questions your audience will have. Different audiences need different information - a contributor to an OSS project needs different context than future-you opening a config folder.

**Always ask:** Who will read this, and what do they need to know?

## Thinking Frame

Before drafting any README section, ask:
1. **Who is reading this right now?** (contributor evaluating the project, user trying to install, future-you debugging, new hire onboarding)
2. **What question brought them here?** (what does this do, how do I install, how do I contribute, why is this broken)
3. **What's the minimum info to answer that question?** (one paragraph, not a page)

Every section should pass this test: if a reader lands on this section from a search engine, can they answer their question without reading the rest of the README?

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

1. **Name** - Self-explanatory title. If the name doesn't describe what it does, add a one-line subtitle.
2. **Description** - What + why in 1-2 sentences. Not "a tool for X" but "Does X so that Y. Replaces Z because Z lacks W."
3. **Usage** - How to use it. One working example is worth ten paragraphs of explanation.

These three alone cover 80% of what a reader needs. Everything else is context-dependent — see the template for your project type.

## NEVER Do

- **NEVER assume OSS defaults for every project.** A config folder for dotfiles doesn't need a Contributing section or CI badges. A personal project doesn't need a License section. Match the template to the audience, not to "what READMEs usually have."
- **NEVER write a README longer than the codebase warrants.** A 200-line README for a 50-line utility is noise. If the project is simple, the README should be simple. Scale depth to complexity.
- **NEVER copy-paste boilerplate sections.** "This project uses the MIT License" without a link to the license file. "See CONTRIBUTING.md for details" when no CONTRIBUTING.md exists. Every section must be earned by the project, not inherited from a template.
- **NEVER list installation steps you haven't tested.** If the install command doesn't work on a clean environment, the README is worse than no README. Verify every command before documenting it.
- **NEVER use badges for the sake of badges.** A broken CI badge, an outdated version badge, or a "PRs welcome" badge on an unmaintained project erodes trust. Only include badges that are current and meaningful.
- **NEVER document what the code already says.** If the usage is self-evident from the code (e.g., `./my-tool --help`), don't write a paragraph explaining it. Point to the help command and move on.
- **NEVER skip the "What" and go straight to "How."** Before showing install commands, the reader needs to know what this thing does and why they'd want it. One sentence. Then install.

## References

- `section-checklist.md` - Which sections to include by project type
- `style-guide.md` - Common README mistakes and prose guidance
- `using-references.md` - Guide to deeper reference materials
