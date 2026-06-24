---
name: waybar-taskbar-icon
description: >
  Fix a missing, generic, or wrong icon for a window in waybar's hyprland
  workspace-taskbar on Omarchy/Hyprland. Use when a taskbar entry shows a
  blank/placeholder/"unknown" icon, especially for Chrome/Electron PWAs (class
  like `chrome-<host>__-Default`). Triggers: "add an icon for X in waybar",
  "X shows wrong/unknown icon in waybar", "PWA icon generic in taskbar",
  "waybar taskbar icon not working", "fix waybar icon".
---

# Waybar Taskbar Icon

**Do NOT load** this skill for waybar styling/CSS, waybar module config, system
icon theme changes, or non-taskbar icon issues. This skill covers
workspace-taskbar icon resolution only.

## How waybar actually resolves a taskbar icon (verified against Waybar 0.15.0 source)

This is the mechanism. Internalize it before doing anything — every prior
"drop a PNG in the theme" assumption is wrong on its own.

`hyprland/workspaces` → `workspace-taskbar` resolves each window's icon in
`src/util/icon_loader.cpp` (called from `src/modules/hyprland/workspace.cpp`):

1. **Find a desktop entry for the window** via `get_app_info_from_app_id_list(window_class)`.
   It tries, in order, to construct a `Gio::DesktopAppInfo`:
   1. the **exact app_id** (window class)
   2. the **lowercased** app_id
   3. the substring **after the last `.`**
   4. the substring **before the first `-`**
   Each attempt first looks for a desktop file whose **filename == that string**
   (`create_from_filename` over prefixes `""`, `~/.local/share/`, `/usr/share/`,
   `/usr/local/share/` × folders `applications/` etc. × suffix `.desktop`). If no
   filename matches, it runs `g_desktop_app_info_search(app_id)` and accepts a hit
   only if that entry's `StartupWMClass` **equals** the app_id.
2. **If no desktop entry is found, `app_info` is NULL** → the icon name becomes
   `"unknown"` → waybar loads **`image-missing`** = the generic placeholder. (This
   is the usual cause of a blank PWA icon.)
3. **If a desktop entry IS found**, waybar picks the icon name:
   - first it tries the entry's **`StartupWMClass` as an icon name** in the theme;
   - else it uses the entry's **`Icon=`** value.
   Then it `load_icon`s that name; on failure it tries the name as a file path;
   else `image-missing`.
4. **Which theme?** The per-module **`icon-theme`** from your waybar config
    (`custom_icon_themes_`) is consulted FIRST, then a fallback default theme.

Omarchy's `omarchy-webapp-install` names `.desktop` files by app title
(e.g. `Perplexity AI.desktop`) and sets `StartupWMClass` only when Chrome
provides it during PWA install. If the field is absent, open the PWA and
derive the class from `hyprctl clients` (Step 1), then add
`StartupWMClass=<class>` before renaming.

**Chrome PWA URL normalization:** Chrome derives the window class from the
full URL. `https://www.perplexity.ai/` → class `chrome-www.perplexity.ai__-Default`;
`https://perplexity.ai/` → `chrome-perplexity.ai__-Default`. If the Exec URL in the
desktop file differs from the URL used to install the PWA (e.g. `www.` prefix), the
class won't match and the icon won't resolve. Ensure the Exec URL, `StartupWMClass`,
and filename all agree on the same URL form. When in doubt, check the live class with
`hyprctl clients` (Step 1) while the PWA is open.

## ⚠️ Do NOT switch the system icon theme to Papirus-Dark on this setup

Setting `gsettings org.gnome.desktop.interface icon-theme 'Papirus-Dark'` (or
pointing Omarchy's `~/.config/omarchy/current/theme/icons.theme` at it) triggers a
**GTK4 segfault that crashes Ghostty and every TUI launched inside it** (and the
walker launcher). Cause: SVG icon themes route through `glycin`, and Ghostty's
bundled `fontconfig` symbol-interposes with the system one → unbounded recursion
→ SIGSEGV (Ghostty 1.3.1, GTK 4.22, libadwaita 1.9; see ghostty discussions
#12555 / #12630). PNG-only themes (e.g. `Yaru-blue`) don't trigger it. The
taskbar's own `icon-theme` (above) is independent of the system theme, so you
never need to touch the system theme anyway.

## Diagnose first

**Key principle:** For an icon to appear you need BOTH: (a) a desktop entry waybar
can map the window to — ideally a file whose **filename == the app_id** — and
(b) an icon that resolves in the configured theme (either named like the
`StartupWMClass`, or the desktop `Icon=` value). If either is missing, you get
the generic placeholder.

Before touching anything, answer these three questions in order:

1. **PWA or native app?** Run `hyprctl clients -j | jq -r '.[] | .class'` while
   the window is open. Class starts with `chrome-` → PWA. Otherwise → native.
2. **Does a desktop file named after the app_id exist?** Check
   `~/.local/share/applications/<app_id>.desktop` and
   `/usr/share/applications/<app_id>.desktop`. If neither exists → the fix is
   renaming/creating the desktop file (Step 3B), NOT installing an icon.
3. **What icon theme does the taskbar actually use?** Check
   `~/.config/waybar/config.jsonc` under `workspace-taskbar` → `icon-theme`.
   Do NOT assume the system theme.
4. **Verify BEFORE installing.** Use the `gjs` snippet (Step 4) to check whether
   the icon name already resolves. Never install an icon without confirming it's
   actually missing — the name may come from `StartupWMClass`, not the class you expect.

| Symptom | Likely cause | Action |
|---|---|---|
| One PWA (class `chrome-…__-Default`) is generic | No desktop file named after the app_id | Step 3B |
| ALL PWAs generic, native apps fine | PWA desktop files are named by title, not app_id | Step 3B (bulk) |
| A native app is generic | `Icon=`/class name doesn't resolve in the configured theme | Step 3A |
| Window shows terminal icon (e.g. ghostty) for a TUI | Class is `com.mitchellh.ghostty` (Ghostty ignores non-reverse-domain `--class`) | Fix launch class: `omarchy-launch-tui X` or `uwsm-app -- xdg-terminal-exec --app-id=org.omarchy.X` |
| PWA icon works from one launcher but not another | Exec URL differs between launchers (e.g. `www.` prefix) → Chrome assigns different class | Step 1: compare live classes; fix Exec URL to match |

## Steps

**1. Get the exact window class (app_id)**
```bash
hyprctl clients -j | jq -r '.[] | "\(.class)\t\(.title)"'
```

**2. Read the taskbar's configured icon-theme(s)** — this is the theme waybar uses, not the system one:
```bash
grep -n -A8 'workspace-taskbar' ~/.config/waybar/config.jsonc
```

**3. Decide the fix by whether a desktop file is named after the app_id**
```bash
APPID="chrome-perplexity.ai__-Default"   # from step 1
ls ~/.local/share/applications/"$APPID.desktop" \
   /usr/share/applications/"$APPID.desktop" 2>/dev/null \
   || echo "NO desktop file named after app_id  -> PWA case (Step 3B)"
```

**3A. Native app, desktop file exists but icon is generic** — make its icon resolve in the configured theme. Find the name it will use:
```bash
# the Icon= value waybar falls back to:
grep -h '^Icon=' /usr/share/applications/"$APPID.desktop" ~/.local/share/applications/"$APPID.desktop" 2>/dev/null
```
Then verify/install that icon in the configured theme (see "Installing an icon into a theme").

**3B. PWA (no app_id-named desktop file)** — **rename** Omarchy's own file so its filename == app_id. Walker indexes by `Name=` (not filename), so one launcher entry is preserved; no `NoDisplay` dependency:
```bash
APPID="chrome-perplexity.ai__-Default"   # from step 1
SRC=$(grep -rl "StartupWMClass=$APPID" ~/.local/share/applications/ 2>/dev/null | head -1)
mv "$SRC" ~/.local/share/applications/"$APPID.desktop"
update-desktop-database ~/.local/share/applications
omarchy restart waybar
```

**Bulk: rename every Omarchy PWA at once (current + future):**
```bash
cd ~/.local/share/applications
for f in *.desktop; do
  grep -q 'omarchy-launch-webapp' "$f" || continue
  wmclass=$(grep -oP '^StartupWMClass=\K.*' "$f")
  [ -n "$wmclass" ] && [ ! -e "$wmclass.desktop" ] || continue
  mv "$f" "$wmclass.desktop"
  echo "renamed: $f -> $wmclass.desktop"
done
update-desktop-database ~/.local/share/applications
omarchy restart waybar
```

**Verify after renaming:** launch the PWA from walker AND from any hyprland
keybind, then run `hyprctl clients -j | jq -r '.[] | .class' | grep chrome-`
for each. Both must show the same class. If they differ, the Exec URL in the
desktop file doesn't match the URL used to install the PWA — fix the Exec to
use the installed URL (check with `hyprctl clients` while the PWA is open
from the keybind).

Note: if `StartupWMClass` is missing from a PWA's desktop file, open the
PWA, find its class with `hyprctl clients` (Step 1), add
`StartupWMClass=<class>` to the file, then rename. Renaming ensures walker
shows exactly one entry; reinstalling the PWA via Omarchy recreates the
title-named file, which needs re-renaming. `omarchy-webapp-remove` still
works — it scans by `Exec=` pattern, not filename.

**4. Verify the icon name resolves (ground truth, no guessing)** — use `gjs`
(GTK3), since `python-gi` is often absent. Replace the theme with your config's:
```bash
gjs -c 'imports.gi.versions.Gtk="3.0"; const {Gtk}=imports.gi; Gtk.init(null);
const t=new Gtk.IconTheme(); t.set_custom_theme("Papirus-Dark");
for (const n of ["chrome-perplexity.ai__-Default","perplexity"]) {
  let i=t.lookup_icon(n,20,0); print(n+" => "+(i?i.get_filename():"NOT FOUND")); }'
```
`get_filename()` printing a path = resolvable. `NOT FOUND` = install the icon.

**5. Reload**
```bash
omarchy restart waybar
```

## Installing an icon into a theme (only if step 4 says NOT FOUND)

Install under the name waybar will request (the desktop `Icon=` value, or the
`StartupWMClass`) into the theme from step 2. Themes like Papirus-Dark have no
`scalable/` apps dir, so convert SVG → PNG into a fixed-size dir.

```bash
ls /usr/share/icons/<THEME>/ | grep '^[0-9]'        # available sizes; 48x48 is a safe target
# SVG source (prefer a light/white logo variant for dark bars):
rsvg-convert -w 48 -h 48 /path/icon-light.svg \
  | sudo tee /usr/share/icons/<THEME>/48x48/apps/<icon-name>.png > /dev/null
# PNG source (ImageMagick v7 uses `magick`, NOT the deprecated `convert`):
magick /path/icon.png -resize 48x48 PNG32:/tmp/i.png \
  && sudo cp /tmp/i.png /usr/share/icons/<THEME>/48x48/apps/<icon-name>.png
sudo gtk-update-icon-cache -f /usr/share/icons/<THEME>/
omarchy restart waybar
```
Tip: a user-level icon in `~/.local/share/icons/hicolor/48x48/apps/<name>.png`
is also found (GTK searches user dirs), and needs no sudo.

## Anti-patterns (learned the hard way)

- **Changing the system gsettings icon theme to fix a taskbar icon.** The taskbar
  uses its own `icon-theme` from `config.jsonc`. Changing the system theme is
  unnecessary — and switching it to Papirus-Dark crashes Ghostty + all TUIs (see the dedicated section above for the technical cause).
- **Dropping a PNG named after the window class into a theme and expecting it to
  show, when no desktop entry maps the window.** If `app_info` is NULL, waybar
  loads `image-missing` and never reaches the theme lookup. For PWAs you must
  first create the app_id-named desktop file (Step 3B).
- **Assuming the icon name is the class with `org.omarchy.` stripped.** That's not
  how taskbar resolution works; the name comes from the matched desktop entry
  (`StartupWMClass` or `Icon=`).
- **Duplicating a desktop file (copy + NoDisplay) instead of renaming the
  original.** A second file creates duplicate launcher entries in walker.
  Rename (`mv`) Omarchy's own file so the filename == app_id; walker indexes
  by `Name=` so one entry is preserved with no `NoDisplay` reliance.
- **Using `convert`** — deprecated in ImageMagick v7; use `magick`.
- **Guessing instead of verifying.** Confirm name resolution with the `gjs`
  snippet (Step 4) before installing anything.
- **Restarting waybar after installing an icon without running `gtk-update-icon-cache`.**
  GTK reads from the compiled icon cache, not raw files. Without rebuilding the
  cache, the new icon is invisible to waybar. Always run `sudo gtk-update-icon-cache -f`
  before `omarchy restart waybar`.
