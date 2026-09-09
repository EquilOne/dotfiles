---
name: markdown-writer
description: >
  Write, draft, and format markdown files with Obsidian compatibility. Use when
  the user says "write a markdown file", "format this markdown", "clean up this
  document", "fix the headings", "restructure this doc", "write documentation",
  "draft a guide", "make this into a doc", "polish this markdown", "fix the
  formatting", "markdown cleanup", "write a spec", "write a changelog", "write
  release notes", "create a guide", "format this doc", "this markdown looks messy",
  "standardize this doc", "prepare this for GitHub", "publish this doc". Covers
  Obsidian-aware style guidelines, drafting from rough content, reformatting existing
  markdown, and preparing documents for publication outside Obsidian. Does NOT handle
  READMEs (use crafting-effective-readmes skill) or code explanation (use explain-code
  skill).
---

# Markdown Writer

## Thinking Frame

Before, during, and after writing:

- **Before:** Who is the audience and where will this be read? This determines the base layer: Obsidian vault → wikilinks OK; GitHub → GFM only; Static site → check renderer.
- **During:** Am I optimizing for the source platform or the target platform? If the doc will be published outside Obsidian, write for the TARGET from the start — retroactive conversion is error-prone.
- **After:** Does this degrade gracefully? Test: strip all Obsidian features. If the meaning breaks, you used Obsidian features for structural purposes, not just formatting. Fix by restructuring.

**Expert insight:** The most common markdown failure is writing for ONE platform then discovering it needs to work on another. The degradation table exists to catch this BEFORE publishing, not after.

Format markdown for maximum compatibility with an Obsidian focus. The model
already knows standard markdown syntax — this skill covers the decisions that
matter: when to use Obsidian features, when to stick to GFM, and how to keep
documents portable.

## Pattern: Process

This skill follows the Process pattern because markdown writing is a multi-step workflow:
- **Phase 1:** Identify task (write/format/publish) — routes to the correct workflow
- **Phase 2:** Execute the workflow with checkpoints (draft → format → verify)
- **Phase 3:** Report changes

Medium freedom: GFM/Obsidian rules are constrained (low freedom for syntax), but content drafting is creative (high freedom). The three workflows provide structure without over-constraining.

**Why Process, not Tool:** Markdown writing has multiple entry points (write/format/publish) — a Tool pattern would collapse these into one rigid workflow. Process is correct because each workflow has its own phases with checkpoints. Not Mindset because the 3-workflow routing is structural, not just thinking.

**Pattern mapping:**
- Phased workflow: 3 workflows (write/format/publish) with distinct steps ✓
- Checkpoints: report after each workflow ✓
- Medium freedom: GFM rules constrained, content drafting free ✓
- ~250 lines (within Process range) ✓

## Core Philosophy

GFM as the base layer. Obsidian-native features only when they degrade gracefully.

| Layer    | What                                           | Fallback                              |
| -------- | ---------------------------------------------- | ------------------------------------- |
| Base     | GFM markdown (headings, lists, tables, code)   | Renders everywhere                    |
| Obsidian | Wikilinks, callouts, frontmatter, tags         | Degrades to plain text or blockquotes |
| Avoid    | Embeds (`![[`), Dataview, HTML, plugins          | Breaks outside Obsidian               |

**Rule of thumb:** If removing an Obsidian feature breaks the document's meaning,
don't use it. If it still makes sense as plain markdown, use it.

## Quick Reference: Which Workflow?

| User Request | Workflow | Key Consideration |
|--------------|----------|-------------------|
| "Write a new doc" / "draft a guide" | Writing Workflow | Start with outline, not prose |
| "Format this markdown" / "clean up this doc" | Formatting Workflow | Identify target platform first |
| "Prepare for publication" / "publish this" | Publishing Workflow | Check external rendering rules |
| "Clean up this doc" (existing) | Formatting Workflow | Preserve author's voice |

## Do NOT Load

This skill does NOT handle:
- **README files** → use `crafting-effective-readmes` skill
- **Code explanation** → use `explain-code` skill
- **Markdown generation from non-markdown sources** (e.g., converting a PDF to markdown) → that's format conversion, not writing
- **Obsidian plugin configuration** (Dataview queries, Templater templates) → this skill covers document content, not Obsidian setup

If the user asks for any of these, redirect to the appropriate skill or tool.

## Obsidian Feature Decisions

### Links — Wikilinks vs. Standard

The most impactful formatting decision. Use this tree:

- Link target is another note in the vault → `[[Page Name]]`
- Link target is external URL → `[text](url)`
- Document will be published outside Obsidian → standard links only

Wikilink variants:
- `[[Page Name]]` — basic link
- `[[Page Name|Display Text]]` — custom display
- `[[Page Name#Heading]]` — link to section

Standard link rules:
- Reference-style `[text][id]` when a link appears 3+ times

### Callouts vs. Blockquotes

Use callouts when the content is an admonition (note, warning, tip, important).
Use plain blockquotes for quoting sources.

```markdown
> [!warning] Title
> Body text.
```

**Degradation mapping** (how each type renders outside Obsidian):

| Callout     | Degrades? | Notes                                               |
| ----------- | --------- | --------------------------------------------------- |
| `note`        | Well      | Meaning preserved as blockquote                     |
| `tip`         | Well      | Meaning preserved                                   |
| `info`        | Well      | Meaning preserved                                   |
| `warning`     | Well      | Urgency preserved                                   |
| `danger`      | Well      | Urgency preserved                                   |
| `quote`       | Perfect   | Already a blockquote                                |
| `example`     | Poor      | Becomes generic blockquote, loses "example" meaning |
| `abstract`    | Poor      | Becomes generic blockquote, loses "summary" meaning |

**Decision:** If the document is Obsidian-only, use any type freely. If publishing
elsewhere, stick to `note`, `tip`, `info`, `warning`, `danger`, `quote`. Avoid
`example` and `abstract` — they lose meaning outside Obsidian.

### Frontmatter

Include frontmatter on new documents:

```yaml
---
title: Document Title
date: YYYY-MM-DD
tags: [topic, category]
status: draft|published|archived
---
```

Cross-tool compatibility: Hugo, Jekyll, and other static site generators also parse
YAML frontmatter. Use standard field names (`title`, `date`, `tags`, `status`) for
maximum portability.

Don't add frontmatter to existing files unless the user asks.

### Tags

- `#tag` inline for lightweight categorization
- Prefer frontmatter `tags:` for structured metadata

## Obsidian Expert Knowledge

These are patterns that only experienced Obsidian users know:

- **Graph view optimization:** Structure notes so the graph reveals relationships, not chaos. Use hub notes (notes that link to many related notes) as graph anchors. Avoid linking every note to every other note — dense graphs hide structure. Aim for a "small-world" graph: clusters of related notes connected by a few hub links.
- **Tag vs wikilink for discoverability:** Tags are for categorization (a note can have many tags). Wikilinks are for explicit connections (a note links to specific related notes). Use tags when a note belongs to a category. Use wikilinks when a note references a specific other note. Don't use tags where wikilinks belong — tags don't show direction or context.
- **MOC (Map of Content) patterns:** A MOC is a hub note that organizes links to related notes on a topic. Create MOCs for broad topics that have 5+ related notes. Update the MOC when you add a note in its scope. MOCs are not tables of contents — they include brief context for each link, explaining why it's related.
- **Backlinks panel usage:** The backlinks panel shows notes that link to the current note. Use it to discover forgotten connections and to find notes that should be updated when you change a referenced concept. If a note has zero backlinks, it's either new, orphaned, or misnamed.

## Expert Knowledge: Markdown Degradation Patterns

These failure modes only surface after cross-platform publishing:

- **Callout syntax in titles:** `> [!warning]` inside a heading breaks rendering on some platforms — the heading and callout compete for the block element.
- **Nested code in lists:** Indented code blocks inside list items need exactly 2 spaces (not 4) of indentation from the list marker on some renderers. Fenced code blocks are safer but may break list continuation.
- **Table escaping:** Pipes inside table cells need `\|` escaping. HTML entities (`&#124;`) work on GitHub but not in Obsidian preview. Use `<code>|</code>` for maximum compatibility.
- **Wikilink aliases in frontmatter:** `[[Note|Display]]` inside YAML frontmatter breaks parsing because `|` is a YAML flow-sequence delimiter. Use quoted strings: `"[[Note|Display]]"`.
- **Task list checkboxes:** `- [ ]` and `- [x]` render on GitHub but not all static site generators. If the target is unknown, use `☐` and `☑` Unicode characters instead.

## Style Decisions

Rules that differ between editors or matter for Obsidian compatibility:

- **Headings:** ATX (`#`) not setext (`===`). ATX is unambiguous; setext conflicts
  with horizontal rules.
- **Lists:** `-` for unordered. Standardize one marker across the vault.
- **Code blocks:** Fenced with language tag. Indented blocks don't support syntax
  highlighting.
- **Line breaks:** One sentence per line. Cleaner diffs, no hard-wrap debates.
- **Horizontal rules:** `---`. Works everywhere, doubles as frontmatter delimiter.

**MANDATORY**: When formatting for GitHub, GitLab, or any external platform, read [`references/gfm-style-decisions.md`](references/gfm-style-decisions.md) for platform-specific syntax rules and edge cases.

> **Note**: The model already knows standard GFM syntax. These rules exist only where Obsidian compatibility or editor differences create ambiguity. Don't re-explain basic markdown — focus on decisions.

## Writing Workflow

When drafting new content:

1. Identify document type (guide, spec, changelog, tutorial, reference)
2. Ask: "Who is the reader and what do they need to do after reading this?"
3. Draft:
   - Frontmatter (title, date, tags, status)
   - Title — what the doc covers
   - Overview — 1-2 sentences, what + why
   - Body — organized by reader's workflow, not by feature
   - Next steps — links to related notes via wikilinks
4. Apply Obsidian feature decisions
5. Report filename and word count

## Formatting Workflow

When reformatting existing content:

1. Read the file
2. Fix in this order:
   - Heading levels and ATX style
   - List marker standardization (`-` only)
   - Code block fencing and language tags
   - Link format (wikilinks for internal, standard for external)
   - Callout syntax (if admonitions exist)
   - Blank line consistency
   - Trailing whitespace
3. Preserve author voice — fix formatting, not prose
4. Report: file, changes made, word count

## Publishing Workflow

When preparing a document for publication outside Obsidian (GitHub, static site, etc.):

1. Convert wikilinks to standard links:
   - `[[Page Name]]` → `[Page Name](page-name.md)` or `[Page Name](url)`
   - `[[Page Name|Display]]` → `[Display](page-name.md)`
   - `[[Page Name#Heading]]` → `[Page Name](page-name.md#heading)`
2. Audit callouts:
   - Keep: `note`, `tip`, `info`, `warning`, `danger` — degrade to blockquotes
   - Convert to plain blockquote or remove: `abstract`, `example` — lose meaning
3. Check frontmatter:
   - Remove Obsidian-only fields (`aliases`, `cssclass`, etc.)
   - Keep standard fields: `title`, `date`, `tags`, `status`
4. Validate rendering in target platform
5. Report: links converted, callouts audited, platform compatibility notes

## Edge Cases

- **Mixed link types:** If a file has both wikilinks and standard links, keep both
  unless the user asks to standardize. Don't silently convert.
- **Conflicting styles:** If the existing style conflicts with these rules (e.g., uses
  `*` for lists), ask before changing. Vault convention overrides skill rules.
- **Already well-formatted:** If the file passes formatting checks, say so. Don't make
  changes for the sake of it.
- **Frontmatter conflicts:** If existing frontmatter uses non-standard fields, preserve
  them. Only add missing standard fields.
- **Malformed markdown:** If the file has broken syntax (unclosed code blocks, mismatched
  brackets), fix syntax before formatting. Flag the issues, don't silently fix.
- **Missing frontmatter:** If an existing file lacks frontmatter, don't add it unless
  the user asks. Only add on new documents.

## Common Mistakes

- **Over-formatting.** If every other word is bold, nothing is bold. Use emphasis sparingly — one or two key phrases per section, not a highlighter party.
- **Heading level jumps.** Going from `##` to `####` skips a level. Every heading must be exactly one level deeper than its parent.
- **Inconsistent list markers.** Mixing `-`, `*`, and `+` in the same file. Pick one and stick with it.
- **Hard-wrapping at 80 characters.** Let the editor handle line length. Hard wraps create noisy diffs and break when the viewer width changes.
- **Link text that says "click here."** The link text should describe the destination, not the action. `[API documentation](url)` not `[click here](url)`.

## Anti-Patterns

- NEVER use embeds (`![[file]]`) — breaks outside Obsidian, use links instead
- NEVER use Dataview queries or Obsidian plugins in shared docs
- NEVER use wikilinks in docs that will be published outside Obsidian
- NEVER rewrite prose during a formatting pass — formatting only
- NEVER add content the user didn't ask for — flag gaps, don't fill them
- NEVER silently convert link types — ask first if mixed
- NEVER handle READMEs — that's the crafting-effective-readmes skill's job
- NEVER add frontmatter to existing files without user consent
- NEVER use heading levels inconsistently — because: breaks the document outline and navigation. Every heading must be exactly one level deeper than its parent (## → ###, not ## → ####).
- NEVER mix ordered and unordered lists for the same hierarchy — because: it confuses the reader about the relationship between items. Pick one list type per hierarchy level.
