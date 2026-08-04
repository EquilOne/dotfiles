# AGENTS.md — OpenCode Config Repository

This is `~/.config/opencode` — OpenCode CLI configuration and plugin setup.
It is not a development project. Write no application code here.

## Repo Structure

| Path              | Purpose                                                                       |
| ----------------- | ----------------------------------------------------------------------------- |
| `opencode.json`     | Agent routing, models, `default_agent: "fixer"`                                 |
| `tui.json`          | Keybindings, theme (`rosepine`), UI config                                      |
| `agent_stack.md`    | Native agent routing reference                                             |
| `keybinds.md`       | Key reference (leader: `ctrl+x`)                                                |
| `agents/*.md`       | Primary and subagent Markdown definitions                                  |
| `skills/*/SKILL.md` | Reusable OpenCode skills and workflows |
| `templates/`        | Project templates                                     |
| `package.json`      | Plugin SDK dep: `@opencode-ai/plugin@1.18.11` (pinned)                           |

## Critical Quirks

- **`.gitignore` ignores `package.json`, `bun.lock`, and `node_modules`** — these are not committed. After clone, create/resolve `package.json` and run `npm install` to restore plugin deps.
- **`autoupdate: true`** in `opencode.json` — plugin versions currently use `@latest`; inspect the live config before changing update behavior.
- **Agents use explicit model overrides** — check `opencode.json` and `agents/*.md` before assuming a default model.

## Commands

| Action          | Command                        |
| --------------- | ------------------------------ |
| Install deps    | `npm install` (or `pnpm install`)  |
| Update deps     | `npm update`                     |
| Fetch live docs | Use `find-docs` skill (ctx7 CLI) |

No build, lint, test, or typecheck commands exist.

## Conventions

- Config files are kebab-case JSON. Validate against schema at `https://opencode.ai/config.json`.
- No source code files in this repo. Only OpenCode config, skill files, and agent configs.
- The `find-docs` skill uses `npx ctx7@latest` — prefer it over web search for library/API docs.
- The `skill-creator` skill exists for saving workflows as reusable skills.
- Keybind and agent-stack reference docs exist separately (`keybinds.md`, `agent_stack.md`) — do not duplicate them.

## Working Here

- Most changes touch `opencode.json`, `tui.json`, skills, or agent configs.
- If editing skills or agent configs, verify changes with OpenCode CLI after saving.
- `node_modules/` is gitignored — never modify it.
- The `opencode-notifier-state.json` file is a runtime state file, not config. Do not commit or hand-edit it.
- Theme in `tui.json` is `"rosepine"` — do not change to `"system"` (contradicts old AGENTS.md guidance).
