# Dispatchers & Bind Types

> Loaded via MANDATORY trigger in SKILL.md when writing keybindings. Not for other tasks.

## Bind types — which to use

| Type | Behavior | Use when |
|------|----------|----------|
| `bind` | Fires on keypress | Standard actions (exec, workspace, toggles) |
| `binde` | Fires repeatedly while held | Actions that must repeat (e.g. volume, brightness, workspace paging) |
| `bindm` | Mouse binding | Mouse button actions (move/resize windows) |
| `bindl` | Fires even while the session is locked | Media keys while locked |
| `bindr` | Fires on key RELEASE | Actions that must trigger after the key lets go |

Always `unbind` an existing key before re-binding it. Define `$mainMod` once at
the top of the config and reuse it.

## Dispatcher reference

Dispatchers are the actions binds call. Names and arguments shift between
Hyprland releases — verify against this table AND the live docs before writing.

### Workspace management
| Dispatcher | Effect |
|-----------|--------|
| `workspace N` | Switch to workspace N |
| `workspace name:NAME` | Switch to named workspace |
| `workspace silN` | Toggle special workspace N |
| `movetoworkspace N` | Move focused window to workspace N |
| `movetoworkspacesilent N` | Move without switching focus |
| `movetoworkspace silN` | Move window to special workspace N |

### Window management
| Dispatcher | Effect |
|-----------|--------|
| `togglefloating` | Toggle floating/tiling |
| `fullscreen [0\|1]` | 0 = current monitor, 1 = all monitors |
| `killactive` | Close focused window |
| `centerwindow` | Center a floating window |
| `movewindow` / `resizewindow` | Directional args (l/u/r/d) |
| `swapwindow` | Swap with window in direction |
| `cyclenext` | Cycle focus to next window |

### Toggles & misc
| Dispatcher | Effect |
|-----------|--------|
| `toggleopaque` | Toggle opaque on floating window |
| `exec` / `execr` | Launch command (execr = once per reload, verify) |
| `exit` | Quit the compositor |
| `splith` / `splitv` | Change split direction (dwindle) |
| `togglegroup` / `changegroupactive` | Window grouping controls |

## Anti-patterns

- NEVER write a dispatcher name from memory — a renamed dispatcher produces a
  bind that silently does nothing.
- NEVER bind a key without checking conflicts first (grep the config for that
  key/modifier combination).
- NEVER put a release-only action on `bind` — use `bindr` or the action fires
  on press.
