---
name: hyprland
description: >
  Portable Hyprland Wayland compositor configuration skill, independent of any
  distro or window-manager wrapper. Use when the user needs to (1) create or edit
  hyprland.conf or split source files, (2) configure keybinds, window rules,
  monitors, animations, input devices, or decorations, (3) troubleshoot Hyprland
  config, or (4) look up valid variables, keywords, dispatchers, or syntax.
  Triggers: "hyprland config", "add a keybind", "window rule", "monitor layout",
  "gaps/borders/blur/animations", "hyprctl", "hyprland not applying",
  "hyprland.conf", "hyprls". On omarchy systems, defer live config edits to the
  omarchy skill instead.
---

# Hyprland Configuration Skill

Portable Hyprland config support. Works on any machine running Hyprland as the
compositor, regardless of distro or wrapper.

## Pattern: Tool

**Why Tool:** One wrong window rule or variable silently breaks Hyprland. Exact
syntax, current variables, and validation commands are the value. Low freedom.

**Freedom calibration:** discovery and validation are low freedom (exact
`hyprctl` commands — not optional). Config composition is low-medium: follow
the user's existing layout, don't impose one. Aesthetic values (gap sizes,
animation curves, colors) are medium freedom — user taste decides.

## NEVER Do

- **NEVER write Hyprland syntax from memory.** Hyprland changes variables,
  keywords, and rule formats between versions (`windowrule` →
  `windowrulev2`, `.conf` vs the newer `.lua` config work-in-progress). Old
  syntax silently does nothing with no error. ALWAYS confirm current syntax via
  find-docs before writing.
- **NEVER assert whether config is `.conf` or `.lua`** as a fixed fact — the
  Lua config path is under active development and adoption depends on version.
  Verify the target machine's Hyprland version (`hyprctl version`) and confirm
  the supported format from live docs.
- **NEVER hardcode omarchy-style config layout** (`monitors.conf`,
  `bindings.conf`, etc.) or omarchy commands. Those are omarchy-specific. This
  skill is generic: source-file splitting is a user's choice, not a default.
- **NEVER repeat the omarchy skill's content.** On a machine with
  `~/.config/omarchy/` present, hand live config edits to the omarchy skill.
- **NEVER set monitor names, positions, or scales from memory.** Read
  `hyprctl monitors` first — a wrong name is silently ignored and the display
  stays unconfigured.
- **NEVER leave a config while `hyprctl configerrors` returns output.** A
  clean configerrors read is the only proof a reload actually applied; leaving
  errors means later edits compound silently on top of a broken base.
- **NEVER `source` a file that does not exist** or add a `bind`/`windowrule`
  without checking it against this machine's release docs — both fail silently
  with no error.

## Fetch Current Docs FIRST

**MANDATORY:** Load the `find-docs` skill (uses `npx ctx7@latest`) to pull
current Hyprland documentation for the specific topic (binds, window rules,
monitors, animations, variables).

If ctx7 has no good Hyprland source, fetch the official wiki directly:
- Variables: `https://wiki.hypr.land/Configuring/Variables/`
- Keywords: `https://wiki.hypr.land/Configuring/Keywords/`
- Binds: `https://wiki.hypr.land/Configuring/Binds/`
- Dispatchers: `https://wiki.hypr.land/Configuring/Dispatchers/`
- Window Rules: `https://wiki.hypr.land/Configuring/Window-Rules/`
- Monitors: `https://wiki.hypr.land/Configuring/Monitors/`
- Animations: `https://wiki.hypr.land/Configuring/Animations/`

Confirm variable names and rule syntax against these before producing config.

## Determine the Target Machine

1. Does `~/.config/omarchy/` exist (or identifiable omarchy system)? →
   **STOP.** Live config edits belong to the `omarchy` skill. This skill may
   still explain generic Hyprland concepts.
2. Non-omarchy machine → proceed here. Check `hyprctl version` for the exact
   Hyprland version, since syntax and supported config format depend on it.

## Core Syntax (verify against live docs)

```conf
$variable = value
section {
    key = value
}
# Root-level keyword
bind = SUPER, Return, exec, kitty
```

Common root keywords: `monitor`, `bind`, `binde`, `bindm`, `bindl`/`bindr`,
`exec`, `env`, `source`, `windowrule`.

## Common Tasks

### Keybindings
**MANDATORY:** When writing or modifying binds, read
[`references/dispatchers.md`](references/dispatchers.md) for the bind-type
decision table and dispatcher reference.
**Do NOT load** it for non-bind tasks (monitors, decorations, animations).

Use `$mainMod` for consistency. Re-binding an existing key → `unbind` first.
Types differ: `bind` (press), `binde` (repeat), `bindm` (mouse), `bindl`
(locked, takes effect when locked), `bindr` (release). Verify dispatcher names
against references/dispatchers.md, not memory.

### Window Rules
**MANDATORY:** When writing or modifying window rules, read
[`references/window-rules.md`](references/window-rules.md) for the matching
fields and rule commands.
**Do NOT load** it for non-rule tasks.

Use the current rule form (verify via docs — older `windowrule` vs
`windowrulev2` merged over versions). Get classes/identifiers with
`hyprctl clients` — never guess a class from memory.

### Monitors
Ask: laptop+external or desktop? Run `hyprctl monitors` for connected
displays, positions, scales. Decide the primary by usage (ask, don't assume).
Assign workspaces with `workspace = N, <monitor>` and
`workspace = name:NAME, <monitor>`; bind the common workspaces to the primary,
give the secondary a fixed workspace, and leave one workspace unassigned so
every monitor always shows content. Double-check the physical arrangement —
placing an external left of the internal when it's actually on the right
inverts mouse movement across screens. Format: `name, res@refresh, position,
scale`.

### Input / Decorations / Animations
Confirm variable names and current syntax from docs. Group settings in
sections (`input`, `decoration`, `animation`, `general`).

## Validation (any existing system)

```sh
hyprctl reload          # apply changes
hyprctl configerrors    # MANDATORY after every edit — fix any output
hyprctl monitors        # list connected displays
hyprctl clients         # list windows + classes
hyprctl version         # exact Hyprland version (syntax may differ)
```

After ANY config change, run `hyprctl reload` then `hyprctl configerrors`. Do
not leave broken config.

## Before Writing — Ask Yourself

- **Which release is this machine running?** `hyprctl version` decides which
  syntax and config format are valid. Never assume.
- **Which section owns this change?** `general`, `input`, `decoration`,
  `animation`, `misc`, or a root keyword. Writing a setting under the wrong
  section silently does nothing.
- **Does an omarchy wrapper exist here?** If yes, defer per the Target Machine
  section.

## Domain Operations

- **One-shot override without editing config:** `hyprctl keyword general:gaps_in 10`
  applies until reload — use it to test an uncertain value before committing it
  to the config file.
- **`source` ordering:** sourced files apply in order and later files override
  earlier ones. `source` lines run in place, so place them where the override
  relationship reads naturally. Only source files that exist.
- **Config split:** whether to split hyprland.conf into per-topic files is the
  user's organizational choice on generic systems. Follow their existing layout;
  do not impose one.
- **Comment discipline:** comment sections and non-obvious settings. The user
  must be able to read the config later without this session.

## Example Requests

| Request                         | Action                                                         |
| ------------------------------- | -------------------------------------------------------------- |
| "Add Mod+E for a file manager"  | Check bindings/unbind, fetch binds + dispatcher docs, add `bind` |
| "Two monitors, laptop on right" | `hyprctl monitors`, set monitor lines with correct positions     |
| "Make gaps smaller"             | Fetch Variables docs for `general` gaps, edit                    |
| "Window rule to float X app"    | `hyprctl clients` for class, verify rule syntax against docs     |
| "Hyprland ignores my config"    | `hyprctl reload` + `hyprctl configerrors`, verify syntax from docs |

## Out of Scope

- Omarchy systems (defer to the omarchy skill for live edits).
- Omarchy-specific config layout, commands, themes, hooks.
- Non-Hyprland components (waybar, walker, terminals).