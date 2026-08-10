# Window Rules Reference

> Loaded via MANDATORY trigger in SKILL.md when configuring window rules. Not for other tasks.

## Rule form

Old `windowrule` and the later `windowrulev2` merged across Hyprland versions;
the modern single form is:

windowrule = <RULE>, <MATCH>

## Matching fields

| Field | Matches | Use for |
|-------|---------|---------|
| `class` | X11 class (legacy compat) | X11 apps (Spotify, Steam) |
| `app_id` | Native Wayland app id | Wayland-native apps (kitty, foot, ghostty) |
| `title` | Window title (supports regex) | Per-tab / per-title windows |
| `initialTitle` / `initialClass` | Value at spawn time | Rules that apply before the window maps |
| `xwayland:1` | Flag for XWayland windows | Split X11 vs native behavior |

Order matters: rules evaluate in order and later rules can override earlier
ones. Put the most specific rule last.

## Common rules

| Rule | Effect |
|------|--------|
| `float` / `tile` | Force floating / tiling |
| `size WxH` | Set floating window size |
| `workspace N` | Send window to workspace (or `name:NAME`, `silN`) |
| `opacity A.B A.B` | Active / inactive opacity |
| `animation name,style,duration,curve` | Per-window animation override |
| `fullscreenstate 0 1` | Fullscreen state flags |
| `noinitialfocus` | Don't steal initial focus |
| `nomaxsize` | Ignore max-size hints (X11) |

## Anti-patterns

- NEVER write rules from memory — matching fields and rule names shift between
  releases and a stale rule silently no-ops.
- NEVER guess a window's class: run `hyprctl clients` and copy the exact value.
  Regex belongs in `title`, not `class`.
- NEVER apply a Wayland-native field to an X11-only app — check whether the app
  reports `app_id` or only `class` first.
