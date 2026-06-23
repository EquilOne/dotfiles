# Skill: waybar-taskbar-icon

Install a custom icon for a window in waybar's workspace-taskbar on Omarchy Linux.

## When to use

Window shows a question mark, unknown, or wrong icon (e.g. ghostty icon) in waybar's
workspace-taskbar. User says things like: "add an icon for X in waybar", "X shows wrong
icon in waybar", "question mark icon in workspace-taskbar", "unknown icon for X", "add
svg icon for waybar", "waybar taskbar icon not working", "fix waybar icon",
"[app] shows ghostty icon in waybar", "install icon for [app] in taskbar".

## How waybar resolves icons

waybar's workspace-taskbar strips the `org.omarchy.` prefix from the window class, then
looks up the resulting name in the **system** Papirus-Dark icon theme only. User icon
directories (`~/.local/share/icons/`, `~/.icons/`) are ignored entirely.

So for class `org.omarchy.opencode`, waybar looks for an icon named `opencode`.

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

**3. Check available sizes in Papirus-Dark**

```bash
ls /usr/share/icons/Papirus-Dark/
```

Papirus-Dark has NO `scalable/` directory. Use `48x48` as the primary target.

**4. Convert the SVG to PNG**

```bash
rsvg-convert -w 48 -h 48 /path/to/icon.svg -o /tmp/icon-48.png
```

Use the light variant of the logo if one exists (Papirus-Dark has a dark background).

**5. Install into the system theme**

```bash
sudo cp /tmp/icon-48.png /usr/share/icons/Papirus-Dark/48x48/apps/<icon-name>.png
```

Or pipe directly without a temp file:

```bash
rsvg-convert -w 48 -h 48 /path/to/icon.svg \
  | sudo tee /usr/share/icons/Papirus-Dark/48x48/apps/<icon-name>.png > /dev/null
```

**6. Update the icon cache**

```bash
sudo gtk-update-icon-cache /usr/share/icons/Papirus-Dark/
```

**7. Restart waybar**

```bash
omarchy restart waybar
```

## Anti-patterns

- **Installing in `~/.local/share/icons/` or `~/.icons/`** — waybar only searches system paths.
  User icon directories are silently ignored regardless of index.theme or cache updates.

- **Using the full class name as the icon name** — waybar strips `org.omarchy.` before lookup.
  Installing `org.omarchy.opencode.png` instead of `opencode.png` will never be found.

- **Assuming `scalable/` exists** — Papirus-Dark uses fixed-size PNG directories only.
  Always check `ls /usr/share/icons/Papirus-Dark/` before installing.

- **Running `gtk-update-icon-cache` on user directories** — only the system theme cache matters.
  Updating `~/.local/share/icons/hicolor/` has no effect on waybar.

- **Creating user desktop files to fix icon resolution** — `~/.local/share/applications/` desktop
  files are not picked up by waybar's icon lookup in this setup.
