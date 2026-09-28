# Hyprland Configuration - Agent Guidelines

## Configuration Validation Commands

This is a Hyprland Wayland compositor configuration for PineTab2 tablet. Validation and testing:

```bash
# Validate Hyprland configuration syntax
hyprctl keyword version

# Test configuration reload
hyprctl reload

# Test keybindings list
hyprctl binds

# Test monitor configuration
hyprctl monitors

# Test workspace configuration
hyprctl workspaces

# Test script syntax
shellcheck scripts/autorotate.sh

# Test autorotate script manually
bash -x scripts/autorotate.sh

# Restart Hyprland services
pkill -USR1 hyprland

# Reload specific configs
hyprctl dispatch exec "hyprctl reload"
```

## Code Style Guidelines

### Configuration Format
- Use Hyprland configuration syntax with consistent spacing
- Group related settings with descriptive comment headers
- Format: `keyword = value` or `keyword = value1, value2, value3`
- Comment sections: `### SECTION NAME ###`

### Naming Conventions
- Variables: Use `$variableName` format (e.g., `$terminal`, `$mainMod`)
- Colors: Use rgba() format with lowercase (e.g., `rgba(ea9a97ff)`)
- Modifiers: `$mainMod` for SUPER, `$altMod` for ALT
- Window rules: Use `windowrule` for single line, `windowrule {}` for multi-line

### Keybinding Patterns
- Format: `bind = modifier, key, dispatcher, arg1, arg2`
- Use `$mainMod` and `$altMod` variables instead of hardcoded keys
- Group related binds with comments
- Multimedia keys use `bindel` for repeat, `bindl` for toggle
- Mouse binds use `bindm` with button codes

### Configuration Organization
1. Monitor settings (top for hardware context)
2. Program variables ($terminal, $menu, etc.)
3. Autostart applications
4. Environment variables
5. General/decoration/animations settings
6. Input/touch device configuration
7. Keybindings (grouped by function)
8. Window/workspace rules

## Hardware Context - PineTab2 Tablet

### Critical Device Settings
- Primary monitor: `DSI-1` (internal display)
- Transform setting: `transform, 3` (90° counter-clockwise rotation)
- Scale: `1.25`
- Touch device must match monitor transform
- Auto-rotation via `monitor-sensor` daemon

### Touch Device Configuration
```bash
touchdevice {
    transform = 3  # Must match monitor transform
    output = DSI-1 # Must match monitor name
}
```

### Autorotate Script Integration
- Script path: `scripts/autorotate.sh`
- Must be started via `exec-once` in hyprland.conf
- Transforms: normal=0, right-up=1, bottom-up=2, left-up=3
- Uses `hyprctl keyword monitor` for live updates

## Theme and Aesthetics

### Color Scheme - Rose Pine Moon
- Background: `rgba(393552ff)` (inactive border)
- Accent: `rgba(ea9a97ff)` (active border)
- Surface: `rgb(2a273f)` (lock screen)
- Text: `rgb(e0def4)`
- Rose: `rgb(ea9a97)`

### Typography
- Lock screen font: `JetBrainsMono Nerd Font`
- Terminal: `foot`
- Cursor themes: `BreezeX-RosePine-Linux` / `rose-pine-hyprcursor`
- Cursor size: 24

### Visual Settings
- Gaps: `gaps_in = 3`, `gaps_out = 6`
- Border: `border_size = 2`
- Rounding: `rounding = 6`, `rounding_power = 2`
- Opacity: `active_opacity = 0.97`, `inactive_opacity = 0.95`
- Animations: Disabled for performance
- Blur: Disabled for performance

## Critical Requirements

### Required Variables
- `$terminal = foot`
- `$fileManager = nautilus`
- `$menu = fuzzel`
- `$browser = qutebrowser`
- `$mainMod = SUPER`
- `$altMod = ALT`

### Required Autostart Applications
- `waybar` - Status bar
- `mako` - Notification daemon
- `hypridle` - Idle/power management
- `hyprpaper` - Wallpaper manager
- `hyprctl setcursor` - Cursor initialization
- `autorotate.sh` - Screen rotation

### Keyboard Layout
- Layout: `us`
- Caps Lock: mapped to Escape (`caps:escape`)

### Workspace Configuration
- 10 workspaces (0-9)
- Workspace 1-3: persistent on DSI-1
- Special workspace: `magic` (Mod+S toggle)

### Multimedia Integration
- Audio: `wpctl` (WirePlumber)
- Brightness: `brightnessctl`
- Media: `playerctl`

## Window Rules Patterns

### Floating Windows
```bash
windowrule = match:float true, match:class ^(squeekboard)$
windowrule = match:pin true, match:class ^(squeekboard)$
```

### Suppress Maximize
Use windowrule block with `suppress_event = maximize` for all windows

### XWayland Fixes
Special windowrule for fixing drag issues with empty class/title XWayland windows

## Integration Points

### Hypridle (hypridle.conf)
- Lock timeout: 300s (5 minutes)
- Dim timeout: 150s (2.5 minutes)
- Screen off: 330s (5.5 minutes)
- Suspend: 600s (10 minutes)

### Hyprlock (hyprlock.conf)
- Blurs current screen as background
- Password input field centered
- Time display centered
- Rose Pine Moon colors

### Hyprpaper (hyprpaper.conf)
- Monitor: DSI-1
- Path: `~/Pictures/wallpapers/fav-wallpapers`
- Timeout: 18000s (5 hours)
