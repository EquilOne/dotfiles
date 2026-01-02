# Configuration Guide

This document explains the reasoning behind specific configuration choices in this tmux setup.

## Core Settings Philosophy

### Neovim-First Optimization

The configuration is built around Neovim workflow with these critical settings:

```bash
set -s escape-time 0          # Eliminates Esc lag in Neovim
set -g focus-events on       # Enables file change detection
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",xterm-256color:RGB"
```

**Why these matter:**
- `escape-time 0` removes the delay when pressing Esc in Neovim, making it feel native
- `focus-events` allows Neovim to detect when files are changed externally
- True color support ensures themes render exactly as intended

### Indexing Strategy

```bash
set -g base-index 1          # Windows start at 1
set -g pane-base-index 1     # Panes start at 1
set -g renumber-windows on  # Re-index when windows close
```

**Rationale:** Starting at 1 matches keyboard layout and muscle memory, while automatic renumbering prevents gaps in window numbering.

## Prefix Choice: Ctrl+s

### Why Not Ctrl+b?
- **Ergonomics**: Ctrl+s is easier to press than Ctrl+b
- **Conflict Resolution**: Ctrl+s doesn't conflict with common shell shortcuts
- **Muscle Memory**: Easier to reach from home row

### Implementation
```bash
unbind C-b                   # Remove default prefix
set -g prefix C-s            # Set new prefix
bind C-s send-prefix         # Allow Ctrl+s Ctrl+s for nested sessions
```

## Theme Configuration: Rose Pine Moon

### Variant Selection
```bash
set -g @rose_pine_variant 'moon'
```

**Why Moon over Dawn/Dusk:**
- **Moon**: Dark theme, easy on eyes during long coding sessions
- **Dawn**: Light theme, can be harsh in low-light environments
- **Dusk**: Alternative dark, but Moon has better contrast for code

### Background Strategy
```bash
set -g @rose_pine_bar_bg_disable 'on'
set -g @rose_pine_bar_bg_disabled_color_option 'default'
```

**Why disable background:**
- Creates a "floating" appearance that's less visually intrusive
- Integrates better with terminal transparency
- Reduces visual clutter, focusing attention on content

## Window Naming System

### Built-in vs Plugin Choice

**Chosen:** Built-in tmux automatic-rename
**Rejected:** tmux-auto-rename plugin

**Reasoning:**
```bash
setw -g automatic-rename on
setw -g automatic-rename-format '#{pane_current_command}:#{b:pane_current_path}'
```

- **Desired Format**: `command:directory` provides more context than just directory
- **Performance**: Built-in is faster than plugin-based solutions
- **Reliability**: No plugin dependencies or potential conflicts

### Format Breakdown
- `#{pane_current_command}`: Shows the running program (nvim, bash, git, etc.)
- `#{b:pane_current_path}`: Shows the basename of current directory
- **Result**: `nvim:config`, `bash:projects`, `git:my-repo`

## Plugin Selection Rationale

### Essential Plugins (Must-Have)

1. **TPM** - Plugin Manager
   - Non-negotiable for plugin management
   - Industry standard with reliable updates

2. **Rose Pine Theme** - Visual Consistency
   - Matches other development tools
   - Maintains aesthetic consistency across workflow

3. **tmux-yank** - Clipboard Integration
   - Essential for modern development workflow
   - Eliminates friction in copy-paste operations

4. **vim-tmux-navigator** - Seamless Navigation
   - Critical for Vim/Neovim users
   - Eliminates context switching between Vim splits and tmux panes

5. **tmux-mode-indicator** - Visual Feedback
   - Provides clear indication of current tmux mode
   - Prevents confusion during complex operations

### Intentionally Excluded Plugins

**tmux-auto-rename**: Replaced by built-in functionality
**tmux-uptime**: Adds minimal value, increases status bar clutter
**tmux-resurrect**: Session management handled by system/terminal

## Performance Optimizations

### Event-Driven Updates
```bash
set -g status-interval 1
set-hook -g after-select-window 'refresh-client -S'
set-hook -g after-select-pane 'refresh-client -S'
set-hook -g window-layout-changed 'refresh-client -S'
```

**Why this approach:**
- **Responsive**: Updates happen instantly on user actions
- **Efficient**: No unnecessary polling or periodic updates
- **Battery-Friendly**: Reduces CPU usage on laptops

### History Management
```bash
set -g history-limit 50000
```

**Why 50,000 lines:**
- **Sufficient**: Covers days of development history
- **Performance**: Still fast to search and navigate
- **Storage**: Minimal memory impact on modern systems

## Keybinding Philosophy

### Vi-Mode Consistency
```bash
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
```

**Rationale:** Maintains consistency with Vim/Neovim navigation, reducing cognitive load.

### Ergonomic Splits
```bash
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
```

**Design Choices:**
- **Visual Mnemonic**: `|` for vertical split, `-` for horizontal split
- **Path Preservation**: Maintains current directory context
- **Workflow Efficiency**: Reduces directory navigation after splits

### Safety-First Kill Operations
```bash
bind x kill-pane                    # No confirmation (frequent, low-risk)
bind X if-shell '[ #{window_count} -gt 1 ]' 'kill-window' 'confirm-before -p "kill-session #S? (y/n)" "kill-session"'
bind C-x confirm-before -p "kill-server? (y/n)" "kill-server"
```

**Tiered Safety Approach:**
1. **Pane**: No confirmation (too frequent)
2. **Window/Session**: Smart confirmation based on context
3. **Server**: Always confirmation (most destructive)

## Mode Indicator Configuration

### Color Psychology
```bash
set -g @mode_indicator_prefix_mode_style 'bg=default,fg=#eb6f92'  # Love (red)
set -g @mode_indicator_copy_mode_style 'bg=default,fg=#f6c177'    # Gold (yellow)
set -g @mode_indicator_sync_mode_style 'bg=default,fg=#c4a7e7'     # Iris (purple)
set -g @mode_indicator_empty_mode_style 'bg=default,fg=#908caa'    # Subtle (gray)
```

**Color Rationale:**
- **Love (Red)**: Commands are important, need attention
- **Gold (Yellow)**: Copy mode is active, data manipulation
- **Iris (Purple)**: Sync mode affects multiple panes
- **Subtle (Gray)**: Default state, minimal visual intrusion

## Status Bar Design

### Minimal Information Architecture
```bash
set -g @rose_pine_host 'on'
set -g @rose_pine_hostname_short 'on'
set -g @rose_pine_directory 'off'
```

**Information Hierarchy:**
1. **Essential**: Mode indicator, window names
2. **Context**: Hostname (for remote sessions)
3. **Excluded**: Directory (redundant with window names), username (usually known)

### Icon Strategy
Custom Nerd Font icons provide visual context without text clutter:
- `` Session icon - indicates tmux session context
- `` Current window - highlights active workspace
- `󰒋` Hostname - system context for remote work

## Customization Guide

### Adding New Plugins

1. **Add to plugin list:**
   ```bash
   set -g @plugin 'username/plugin-name'
   ```

2. **Install:** `Ctrl+s I`
3. **Configure:** Add plugin-specific settings
4. **Test:** Verify functionality

### Modifying Theme Colors

1. **Identify color variable** in Rose Pine palette
2. **Update mode indicator colors:**
   ```bash
   set -g @mode_indicator_prefix_mode_style 'bg=default,fg=#your_color'
   ```
3. **Reload:** `Ctrl+s r`

### Adjusting Window Naming

```bash
# Change format
setw -g automatic-rename-format '#{pane_current_command} [#{b:pane_current_path}]'

# Adjust maximum length
setw -g window-status-format '#I:#W#F'
setw -g window-status-current-format '#I:#W#F'
```

## Migration from Other Configurations

### From Default tmux
1. **Backup current config:** `cp ~/.tmux.conf ~/.tmux.conf.backup`
2. **Replace with this config:** `cp tmux.conf ~/.tmux.conf`
3. **Install TPM:** Follow installation instructions
4. **Install plugins:** `Ctrl+s I`

### From Other Custom Configs
1. **Identify key differences:** Compare with your current config
2. **Migrate custom keybindings:** Add them to the keybindings section
3. **Preserve custom plugins:** Add them to plugin list
4. **Test incrementally:** Reload after each major change

---

This configuration prioritizes performance, ergonomics, and visual consistency while maintaining flexibility for customization.