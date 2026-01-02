# Tmux Configuration - Rose Pine Moon

A highly optimized tmux setup featuring Rose Pine Moon theme, seamless Neovim integration, and intelligent window naming.

## Quick Start

```bash
# Install TPM (Plugin Manager)
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

# Start tmux and install plugins
tmux
# Press: Ctrl+s I (install plugins)

# Reload configuration
# Press: Ctrl+s r
```

## Key Features

- **Rose Pine Moon Theme**: Beautiful dark theme with minimal floating design
- **Neovim Optimized**: Zero escape time, focus events, true color support
- **Smart Window Naming**: `command:directory` format (e.g., `nvim:config`, `bash:projects`)
- **Vim Integration**: Seamless navigation between Vim splits and tmux panes
- **System Clipboard**: Native clipboard integration via tmux-yank

## Active Plugins

| Plugin | Purpose | Key Feature |
|--------|---------|-------------|
| `tmux-plugins/tpm` | Plugin Manager | Install/update/manage plugins |
| `rose-pine/tmux` | Theme | Rose Pine Moon color scheme |
| `MunifTanjim/tmux-mode-indicator` | Mode Display | Visual indicators for Prefix/Copy/Sync modes |
| `tmux-plugins/tmux-yank` | Clipboard | System clipboard integration |
| `christoomey/vim-tmux-navigator` | Navigation | Seamless Vim/tmux pane navigation |

## Essential Keybindings

**Prefix**: `Ctrl+s` (replaces default `Ctrl+b`)

### Daily Essentials
- `Ctrl+s |` - Horizontal split (maintains current directory)
- `Ctrl+s -` - Vertical split (maintains current directory)
- `Ctrl+s h/j/k/l` - Navigate panes (vi-style)
- `Ctrl+h/j/k/l` - Vim/tmux seamless navigation
- `Ctrl+s Tab` - Toggle between current and previous window
- `Ctrl+s r` - Reload configuration

### Copy & Paste
- `Ctrl+s [` - Enter copy mode
- `y` - Copy selection to system clipboard
- `Ctrl+s ]` - Paste from clipboard

### Window Management
- `Ctrl+s c` - Create new window (smart naming)
- `Ctrl+s &` - Kill current window
- `Ctrl+s x` - Kill current pane

## Window Naming System

Built-in tmux automatic renaming provides intelligent window names:

- **Editor windows**: `nvim:config` (program:directory)
- **Shell windows**: `bash:projects` (program:directory)
- **Git operations**: `git:repository` (program:directory)

Format: `#{pane_current_command}:#{b:pane_current_path}`

## Theme Details

### Rose Pine Moon Configuration
- **Variant**: Moon (dark theme)
- **Status Position**: Top of screen
- **Design**: Minimal floating pills with clean separators
- **Background**: Disabled for transparent look

### Mode Indicators
| Mode | Color | Meaning |
|------|-------|---------|
| Prefix Mode | Love (#eb6f92) | `Ctrl+s` pressed, ready for command |
| Copy Mode | Gold (#f6c177) | Currently in copy mode |
| Sync Mode | Iris (#c4a7e7) | Panes synchronized |
| Empty Mode | Subtle (#908caa) | Default state |

### Status Bar Layout
- **Left**: Mode indicator with current window icon
- **Center**: Window list with smart names
- **Right**: Hostname (shortened)

## Neovim Integration

### Critical Optimizations
- **Zero Escape Time**: `set -s escape-time 0` eliminates lag
- **Focus Events**: `set -g focus-events on` enables file change detection
- **True Color**: RGB support for accurate theme rendering

### Recommended Neovim Settings
```lua
-- Enable true color support
vim.opt.termguicolors = true

-- Focus events for autoread
vim.o.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  callback = function()
    vim.cmd("checktime")
  end,
})
```

## Requirements

- **tmux** 3.5a+
- **Nerd Font** (for icon display)
- **System dependencies**:
  - Linux: `xsel` or `xclip` for clipboard support
  - macOS: `reattach-to-user-namespace`

## Maintenance

### Plugin Management
- `Ctrl+s I` - Install plugins
- `Ctrl+s U` - Update all plugins
- `Ctrl+s alt+u` - Clean unused plugins

### Configuration Updates
After modifying `tmux.conf`:
- `Ctrl+s r` - Reload configuration
- Or: `tmux source-file ~/.config/tmux/tmux.conf`

## File Structure

```
~/.config/tmux/
├── tmux.conf              # Main configuration
├── plugins/               # TPM plugin directory
│   ├── tpm/              # Plugin manager
│   ├── tmux/             # Rose Pine theme
│   ├── tmux-mode-indicator/
│   ├── tmux-yank/
│   └── vim-tmux-navigator/
├── README.md             # This file
├── CONFIGURATION.md      # Detailed configuration guide
├── KEYBINDINGS.md        # Complete keybinding reference
└── TROUBLESHOOTING.md    # Common issues and solutions
```

---

**Last Updated**: December 2025  
**Tmux Version**: 3.5a+  
**Primary Theme**: Rose Pine Moon  
**Prefix**: `Ctrl+s`