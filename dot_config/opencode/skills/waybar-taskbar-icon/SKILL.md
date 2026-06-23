---
name: waybar-taskbar-icon
description: >
  Install a custom icon for a window in waybar's workspace-taskbar on Omarchy Linux.
  Use when a window shows a question mark, unknown, or wrong icon (e.g. ghostty icon)
  in waybar's workspace-taskbar. Fire on: "add an icon for X in waybar", "X shows wrong
  icon in waybar", "question mark icon in workspace-taskbar", "unknown icon for X",
  "add svg icon for waybar", "waybar taskbar icon not working", "fix waybar icon",
  "[app] shows ghostty icon in waybar", "install icon for [app] in taskbar".
---

# Waybar Taskbar Icon

## Before you start

Ask these questions before touching anything:

- **What class does the window actually have?** Run `hyprctl clients -j` and check. Do not
  assume — the class determines the icon name after prefix stripping.
- **Does a system icon already exist?** Check `find /usr/share/icons -name '<name>*'`
  before creating one. If it exists, the problem is elsewhere (class mismatch, wrong theme).
- **Is Papirus-Dark installed?** This skill assumes Papirus-Dark is the icon theme. Check
  the user's `icon-theme` in `~/.config/waybar/config.jsonc`. Adapt the target directory
  if a different theme is in use.

## How waybar resolves icons

This is the core knowledge that makes this skill work. The model does not know this.

waybar v0.15+ uses `Gio::DesktopAppInfo` + `Gtk::IconTheme::get_default()` to resolve
window icons. The resolution chain:

1. **Prefix stripping**: waybar strips `org.omarchy.` from the window class before lookup.
   Class `org.omarchy.opencode` becomes icon name `opencode`.
2. **System paths only**: `get_default()` uses the system icon theme (from gsettings), NOT
   the waybar `icon-theme` config. User directories (`~/.local/share/icons/`, `~/.icons/`)
   are silently ignored.
3. **No scalable/**: Papirus-Dark has no `scalable/` directory. SVG icons must be converted
   to PNG and placed in a fixed-size directory (`48x48/apps/`).

This means: to add an icon for class `org.omarchy.foo`, you install `foo.png` into
`/usr/share/icons/Papirus-Dark/48x48/apps/` with sudo. Nothing else works.

## Steps

**1. Confirm the window class**

```bash
hyprctl clients -j | jq '.[] | select(.workspace.name == "special:<name>") | {class}'
```

**2. Derive the icon name**

Strip `org.omarchy.` prefix from the class. That is the icon name waybar will search for.

| Class                  | Icon name  |
| ---------------------- | ---------- |
| `org.omarchy.opencode` | `opencode` |
| `org.omarchy.nvim`     | `nvim`     |
| `com.mitchellh.ghostty`| `com.mitchellh.ghostty` (no strip) |

**3. Choose the light variant**

Papirus-Dark has a dark background. If the logo SVG has a light variant (e.g.
`mark-light.svg`), use it. A dark logo on a dark background is invisible.

**4. Check available sizes and install**

```bash
ls /usr/share/icons/Papirus-Dark/ | grep '^[0-9]'
```

Use `48x48` as the primary target. Convert and install in one step:

```bash
rsvg-convert -w 48 -h 48 /path/to/icon-light.svg \
  | sudo tee /usr/share/icons/Papirus-Dark/48x48/apps/<icon-name>.png > /dev/null
```

**5. Update cache and restart**

```bash
sudo gtk-update-icon-cache /usr/share/icons/Papirus-Dark/
omarchy restart waybar
```

**6. Verify**

```bash
python3 -c "
import gi; gi.require_version('Gtk','3.0')
from gi.repository import Gtk
t = Gtk.IconTheme.new()
t.set_custom_theme('Papirus-Dark')
i = t.lookup_icon('<icon-name>', 48, 0)
print(i.get_filename() if i else 'NOT FOUND')
"
```

If NOT FOUND: check that `rsvg-convert` produced a valid PNG (`file <path>.png`).
If waybar still shows unknown: re-run step 1 to confirm the class matches.

## Anti-patterns

- **Installing in `~/.local/share/icons/` or `~/.icons/`** — waybar uses
  `Gtk::IconTheme::get_default()` which only searches system paths. User icon directories
  are silently ignored regardless of index.theme or gtk-update-icon-cache invocations.

- **Using the full class name as the icon name** — waybar strips `org.omarchy.` before
  lookup. Installing `org.omarchy.opencode.png` instead of `opencode.png` will never be
  found because waybar searches for the stripped name, not the full class.

- **Assuming `scalable/` exists** — Papirus-Dark uses fixed-size PNG directories only.
  Always check `ls /usr/share/icons/Papirus-Dark/` before installing. If you put an SVG
  in a non-existent directory, it silently does nothing.

- **Running `gtk-update-icon-cache` on user directories** — only the system theme cache
  matters. Updating `~/.local/share/icons/hicolor/` has zero effect on waybar because
  waybar never looks there.

- **Creating user desktop files to fix icon resolution** — `~/.local/share/applications/`
  desktop files are not picked up by waybar's icon lookup in this setup. The icon must
  exist in the system theme itself.

- **Using the dark logo variant on Papirus-Dark** — the dark background swallows dark
  logos. Always prefer the light/white variant of the logo if one exists.
