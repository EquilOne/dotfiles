# GFM Style Decisions

Platform-specific syntax rules for GitHub, GitLab, and other external renderers. Use this file when asked to prepare markdown that will be rendered outside Obsidian.

## Heading Hierarchy

- Use ATX (`#`) headings only. Avoid setext-style underlining (`===` or `---`); it is ambiguous and unsupported by some parsers.
- Do not skip levels: `##` → `###` is valid, but `##` → `####` is not.
- Use one top-level H1 per published file, matching the document title.
- Keep heading text short and front-loaded; it becomes the anchor ID and the TOC entry.

## Code Fence Language Tags

- Always specify a language tag on the opening fence so the renderer can apply syntax highlighting.
- Common tags: `bash`, `sh`, `json`, `yaml`, `markdown`, `python`, `javascript`, `typescript`, `html`, `css`, `sql`, `rust`, `go`.
- Use `text` or `plaintext` only when syntax highlighting adds no value.
- Prefer fenced blocks over indented blocks; indented blocks do not support language tags or copy buttons on most platforms.

## Link Formatting

- Use reference-style links `[text][id]` when a URL appears three or more times in the document.
- Use autolinks (`<url>`) for bare URLs that must stay clickable.
- Link text should describe the destination, not the action: `[API docs](url)`, not `[click here](url)`.
- Anchor IDs are derived from heading text. Use kebab-case and keep headings stable so links do not break.

## Table Syntax

- Use tables for structured comparisons of three or more items or for attribute/value mappings.
- Use bullet or numbered lists when the content is narrative, sequential, or too wide for a readable table.
- Align columns with colons (`:---`, `---:`, `:---:`) to communicate alignment intent.
- Keep tables narrow. Split very wide tables, convert them to lists, or move details under each item.
- Escape literal pipe characters (`|`) inside cells with a backslash (`\|`).

## List Indentation

- Indent nested list items with two spaces under the parent marker.
- Use `-` for unordered lists and `1.` for ordered lists. Do not mix `*`, `+`, and `-` markers.
- Do not mix ordered and unordered markers at the same hierarchy level.
- Separate consecutive lists with a blank line so they remain distinct lists.

## Emphasis

- Use bold (`**text**`) for key terms, UI labels, names of dialog boxes, and critical warnings.
- Use italic (`*text*`) sparingly, typically for new terms or mild emphasis.
- Do not nest bold inside italic.
- Avoid emphasizing whole sentences or multiple consecutive sentences; if everything is emphasized, nothing is.

## Line Length

- Write one sentence per line. This creates clean diffs and avoids hard-wrap debates.
- Do not hard-wrap prose at a fixed column width such as 80 or 120 characters.
- Let the viewing platform wrap text to the reader's viewport.

## Blank Lines

- Place a blank line before and after headings, lists, code fences, tables, blockquotes, and horizontal rules.
- Add a blank line between adjacent lists to keep them as separate lists.
- Do not depend on single newlines inside a paragraph; most renderers collapse them to a single space.

## Images

- Use standard image syntax `![alt text](url)` for external renderers.
- Write descriptive alt text; it is read by screen readers and used when the image fails to load.
- Avoid embed syntax (`![[file]]`) outside Obsidian.

## Frontmatter

- Use YAML frontmatter (`---`) for metadata when the target platform supports it.
- Common portable fields: `title`, `date`, `tags`, `status`.
- Remove Obsidian-only fields (`aliases`, `cssclass`) before publishing.

## Raw HTML

- Avoid raw HTML when possible; it renders differently across platforms.
- Use HTML only for features GFM does not provide, such as `<details>`/`<summary>` collapsible blocks.
- Keep HTML valid and self-contained; malformed HTML can break the rest of the document.
