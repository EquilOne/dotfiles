---
name: customize-opencode-ext
description: >
  EXTENDS the built-in customize-opencode skill with local enhancements for this
  repo (~/.config/opencode). Built-in covers field shapes for opencode.json,
  agents, skills, plugins, MCP, and permissions. This extension adds: config
  triage framework with blast-radius ranking, repo-local guidance (Do NOT Load,
  NEVER Do, working-here rules), and a detailed field reference file. Use when
  editing opencode config ("edit opencode config", "fix opencode.json",
  "create opencode agent", "add a permission rule", "tune tui.json") — load
  ALONGSIDE the built-in, not instead of it.
---

# Customizing opencode — local extension

This skill extends the **built-in** `customize-opencode` skill with local
enhancements for this repository. Load it together with the built-in: the
built-in documents field shapes for `opencode.json`, agents, skills, plugins,
MCP servers, and permissions; this file adds config-triage judgment, repo-local
rules, and a detailed field reference.

## Do NOT Load

Use this extension ONLY when configuring opencode itself. Do NOT use when:

- The user is writing application code — that's the coder subagent's job
- The user wants to create/edit a skill — use the `skill-creator` skill
- The user wants to edit waybar/hyprland config — use the `omarchy` skill
- The user wants to commit changes — use the `commit-work` skill
- The user is editing chezmoi source — use the `chezmoi-sync` skill

## Config Triage Framework (Expert)

Before editing any opencode config, ask:

- **What changed?** Is this a model swap, agent route, permission rule, or plugin change?
- **Who depends on it?** Check `opencode.json` for `default_agent` and per-agent `model` overrides.
- **What's the rollback?** Can you revert by restoring one file, or does it cascade?

**Expert insight:** The most dangerous config change is a `permission` rule change because it affects ALL agents simultaneously. A permission rule that's too permissive exposes every agent to potentially dangerous operations. A rule that's too restrictive breaks workflows silently. Always test permission changes with a non-default agent first.

**Config change blast radius (smallest to largest):**

1. `tui.json` (keybindings, theme) — UI only
2. Single agent `.md` file — one subagent's behavior
3. `opencode.json` model override — one agent's model
4. `opencode.json` `default_agent` — affects all sessions
5. `opencode.json` permission/plugin changes — affects ALL agents

## Config Field Reference

**MANDATORY:** When editing a specific config field and uncertain about valid values or interactions, read [`references/config-reference.md`](references/config-reference.md) for detailed field documentation.

**Do NOT load** the config reference when: making a simple value change (e.g., swapping a model name), or when the user knows the exact field and value.

The authoritative full schema lives at `https://opencode.ai/config.json` — fetch it directly when the extension and the built-in do not cover a field.

## External References

**Load when needed:** If a config field's shape or valid values are unclear, fetch the schema:

```
https://opencode.ai/config.json
```

Only load when uncertain about a field — don't pre-fetch for every edit.

## Applying changes

Config is loaded once when opencode starts and is **not hot-reloaded**. After saving changes to `opencode.json`, an agent file, a skill, a plugin, or any other config-time file, **tell the user to quit and restart opencode** for the changes to take effect. The running session will keep using the already-loaded config until then.

## Repo-local working rules

- Most changes touch `opencode.json`, `tui.json`, `agents/*.md`, or `skills/*/SKILL.md` — prefer targeted edits over rewrites.
- Config files are kebab-case JSON; `opencode.json` tolerates JSONC (comments, trailing commas) but clean up stray artifacts in sections you touch.
- Agent files are authoritative for reasoning effort; `opencode.json` provider options are fallback for agents without files.
- After saving any config change, remind the user to quit and restart opencode.
- If the user's existing config is malformed, point them at the env-var escape hatches from the built-in skill (`OPENCODE_DISABLE_PROJECT_CONFIG=1`, etc.) so they can edit from inside opencode without breaking their session.

## NEVER Do

These are hard rules for this repo's config — violating them breaks startup or silently misroutes work:

- **NEVER guess a field shape** — opencode hard-fails on invalid config. If a field isn't documented and you're unsure, fetch `https://opencode.ai/config.json` and read the schema.
- **NEVER forget the restart note** — every config save must end with "quit and restart opencode."
- **NEVER put broad permission rules after narrow ones** — opencode evaluates the **last** matching rule. Broad rules first, narrow rules last.
- **NEVER inline long agent prompts in `opencode.json`** — for agents with >10 lines of prompt, use the file form (`agents/<name>.md`).
- **NEVER change the theme to `"system"`** — `tui.json` theme is `"rosepine"`; this repo intentionally keeps it.

## Pattern: Tool

This extension is a local delta over the built-in Tool-pattern skill: decision trees for config triage, repo-local rules, and a reference file for detailed field docs. The built-in owns the common surface area; this file owns only what is local to this repo.