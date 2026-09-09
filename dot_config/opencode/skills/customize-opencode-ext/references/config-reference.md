# opencode Config Field Reference

Detailed field documentation for `opencode.json` and `tui.json`. Use this when you are uncertain about valid values, shape, or interactions between fields.

## `opencode.json` fields

### `model`

Default model for the main agent when no per-agent override exists.

- **Type:** `string`
- **Required provider prefix:** Yes — always `"provider/model-id"`
- **Valid values:** e.g., `"anthropic/claude-sonnet-4-6"`, `"openai/gpt-4o"`, any provider/model pair supported by the configured providers
- **Cross-reference:** Overridden by `agent.<name>.model`. Does NOT affect subagents unless they inherit it and have no override.

### `default_agent`

Which agent runs when opencode starts a new chat session.

- **Type:** `string`
- **Valid values:** Name of any non-hidden, `mode: "primary"` agent
- **Cross-reference:** Must match a key in `agent` or a built-in primary agent. If the named agent is hidden or not primary, startup fails.

### `agents` (`agent` object)

Object keyed by agent name. Each value defines one agent.

- **Type:** `object`
- **Shape:** `{ "<agent-name>": { model, mode, description, permission, prompt | file } }`
- **Valid `mode` values:** `"primary"` | `"subagent"` | `"all"`
- **Cross-reference:**
  - `agent.<name>.model` overrides the top-level `model` for that agent only.
  - `agent.<name>.permission` overrides the top-level `permission` for that agent only.
  - `default_agent` must point to a non-hidden primary agent.

### `permission`

Controls which tools each agent may invoke without asking.

- **Top-level form:** `"allow"` | `"ask"` | `"deny"` | `{ [toolName]: action | { pattern: action } }`
- **Valid actions:** `"allow"` | `"ask"` | `"deny"`
- **Per-pattern object rules:**
  - Patterns are matched in object insertion order.
  - The **last** matching rule wins.
  - Put the broadest rule first (`"*": "ask"`) and narrow rules after it (`"git *": "allow"`).
- **Known tool keys:** `read`, `edit`, `glob`, `grep`, `list`, `bash`, `task`, `external_directory`, `todowrite`, `question`, `webfetch`, `websearch`, `lsp`, `doom_loop`, `skill`
- **Flat-only tools (no per-pattern object):** `todowrite`, `question`, `webfetch`, `websearch`, `doom_loop`, `skill`
- **Cross-reference:** A top-level string `"allow"` grants every tool to every agent. Per-agent `permission` overrides the global one. The `permission` rule change has the largest blast radius of any config change because it affects ALL agents.

### `autoupdate`

Whether opencode checks for and installs updates.

- **Type:** `boolean` | `"notify"`
- **Valid values:**
  - `true` — automatically install available updates
  - `false` — never check or install updates
  - `"notify"` — check and surface a notification, but do not install automatically
- **Common pinning setup:** Set `autoupdate: false` in global config and pin `plugin` versions manually (e.g., `opencode-foo@1.2.3`).

### `mcp`

Object keyed by MCP server name. Each server must declare a `type`.

- **Shape:** `{ "<server-name>": { type, command?, url?, enabled?, env?, headers? } }`
- **Valid `type` values:** `"local"` | `"remote"`
- **Required fields by type:**
  - `local` — `command: string[]` (array of strings, never a single shell string)
  - `remote` — `url: string`
- **Optional:** `enabled: boolean`, `env: object`, `headers: object`
- **Cross-reference:** Use `enabled: false` to disable a server inherited from a parent config without removing its definition.

## `tui.json` fields

The UI config lives separately from `opencode.json` and is loaded from `./tui.json` or `~/.config/opencode/tui.json`.

### `theme`

Color theme for the terminal interface.

- **Type:** `string`
- **Valid values:**
  - `"rosepine"` — bundled rose-pine theme
  - `"system"` — follow terminal/system colors
  - Custom hex: for theme authors, a string starting with `#` may be accepted by custom theme providers
- **Default guidance:** Use `"rosepine"` unless the user explicitly asks for system colors or a custom palette.

### `keybindings`

Custom key chords for TUI actions.

- **Type:** `object` mapping action names to key chords or arrays of key chords
- **Example:** `{ "quit": "ctrl+c", "submit": ["enter", "ctrl+j"] }`
- **Valid values:** Any key combination the underlying terminal input library can parse; always prefer modifier + key form for chords.

### Other UI settings

Additional fields may include font sizing hints, status-bar visibility, and scrollback limits. Refer to the published schema for exact names because UI fields change more often than core config fields.

- Verify unclear UI fields against `https://opencode.ai/config.json`.
- UI-only changes affect only terminal rendering and can be reverted by swapping `tui.json` back.

## Field cross-reference cheat sheet

| Field | Scope | Overridden by | Affected agents |
|-------|-------|---------------|-----------------|
| `model` | Global | `agent.<name>.model` | All without per-agent model |
| `default_agent` | Global | — | All new sessions |
| `agent.<name>.model` | Per-agent | — | One named agent |
| `agent.<name>.permission` | Per-agent | — | One named agent |
| `permission` | Global | Per-agent `permission` | All agents |
| `autoupdate` | Global | — | Update behavior only |
| `mcp` | Global or scoped | Same key in more-specific config | MCP tool availability |
| `theme` | TUI only | — | Rendering only |
| `keybindings` | TUI only | — | Input only |