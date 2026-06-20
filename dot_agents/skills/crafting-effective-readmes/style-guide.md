# README Style Guide

## Common Mistakes (Surface Level)

- **No install steps** — readers abandon when they can't run it
- **No examples** — "show, don't tell" applies to APIs
- **Wall of text** — no headers, tables, or lists means no one scans it
- **Stale content** — unmaintained READMEs signal abandoned projects
- **Generic tone** — "a library for doing X" without specifics

## Expert Anti-Patterns (Things Only Experienced Maintainers Notice)

**NEVER lead with features before the one-liner.** Readers decide in 5 seconds whether to keep reading. If the first paragraph is a bullet list of features, you've lost them. The description comes first, period.

**NEVER write an AI-tone README.** Symptoms: vague descriptions ("a powerful tool for managing data"), no concrete examples, no specific numbers, no opinionated voice. AI-tone READMEs signal "placeholder content" and contributors skip the repo. If you can't say what makes it different from the 50 alternatives, the README is broken.

**NEVER add a Roadmap section you won't maintain.** An abandoned roadmap signals dead project more loudly than no roadmap at all. Either commit to updating it or delete the section.

**NEVER badge-spam.** Badges that don't add decision-relevant info are noise. GitHub stars: fine. "Code style: prettier": noise. "Last commit": fine. "Tweet button": noise. If removing a badge wouldn't change a reader's decision, remove it.

**NEVER write "This project is a [X] for [Y]" without saying what makes it different.** That sentence pattern produces dozens of identical-looking READMEs every day. The "different from alternatives" clause is load-bearing.

**NEVER use screenshots from a different project (or stock screenshots).** A misleading screenshot destroys credibility instantly. If you don't have a real one, use no screenshot.

**NEVER bury "how to extend" inside a long Contributing section.** For libraries, this is the second most important section after Installation. New users want to know: "can I customize this?"

## Prose Quality

For general writing advice — clear prose, Strunk's rules, and AI patterns to avoid — use the `writing-clearly-and-concisely` skill.
