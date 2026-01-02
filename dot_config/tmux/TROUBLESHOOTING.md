# Troubleshooting Guide

Solutions for common issues specific to this tmux configuration.

## Installation Issues

### TPM Not Found
**Problem**: `run '~/.config/tmux/plugins/tpm/tpm'` fails

**Solution**:
```bash
# Install TPM
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

# Reload tmux
tmux source-file ~/.config/tmux/tmux.conf
# Or press: Ctrl+s r
```

### Plugins Not Installing
**Problem**: `Ctrl+s I` shows no activity

**Check TPM Installation**:
```bash
ls ~/.config/tmux/plugins/tpm
# Should show: README.md, tpm, etc.
```

**Reinstall TPM**:
```bash
rm -rf ~/.config/tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

**Verify Plugin Syntax**:
```bash
# Check tmux.conf for syntax errors
tmux source-file ~/.config/tmux/tmux.conf
```

## Theme and Display Issues

### Icons Not Displaying
**Problem**: Icons show as boxes or question marks

**Check Nerd Font Installation**:
```bash
# List installed fonts
fc-list | grep -i nerd

# Test font rendering
echo $'\uf028'  # Should show speaker icon
```

**Install Nerd Font**:
```bash
# Ubuntu/Debian
sudo apt install fonts-firacode-nerdfont

# macOS with Homebrew
brew tap homebrew/cask-fonts
brew install font-fira-code-nerd-font

# Manual download
# Download from https://www.nerdfonts.com/
```

**Configure Terminal**:
- Ensure terminal is using a Nerd Font
- Check terminal font settings
- Restart terminal after font changes

### Colors Look Wrong
**Problem**: Theme colors don't match Rose Pine palette

**Check Terminal Color Support**:
```bash
# Check tmux version (needs 3.5a+)
tmux -V

# Check terminal type
echo $TERM
# Should be "tmux-256color" or similar

# Test color support
tmux display-message -p "#{client_prefix}"
```

**Verify Terminal Configuration**:
```bash
# Check tmux color settings
tmux show-options -g default-terminal
tmux show-options -g terminal-overrides
```

**Fix Terminal Type**:
```bash
# Add to shell profile (.bashrc, .zshrc)
export TERM="tmux-256color"

# Or set in tmux.conf (already included)
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",xterm-256color:RGB"
```

### Status Bar Not Appearing
**Problem**: Status bar missing or corrupted

**Check Status Bar Settings**:
```bash
tmux show-options -g status
tmux show-options -g status-position
```

**Reload Theme**:
```bash
# Reload configuration
tmux source-file ~/.config/tmux/tmux.conf

# Or press: Ctrl+s r
```

**Check Rose Pine Plugin**:
```bash
ls ~/.config/tmux/plugins/tmux
# Should show rose-pine theme files
```

## Window Naming Issues

### Smart Naming Not Working
**Problem**: Windows show generic names instead of `command:directory`

**Check Automatic Rename Settings**:
```bash
tmux show-window-options -g automatic-rename
tmux show-window-options -g automatic-rename-format
```

**Verify Settings**:
```bash
# Should be enabled
setw -g automatic-rename on

# Should show format
setw -g automatic-rename-format '#{pane_current_command}:#{b:pane_current_path}'
```

**Manual Rename Test**:
```bash
# Test manual rename
Ctrl+s ,

# Check if rename prompt appears
```

### Window Names Not Updating
**Problem**: Window names stuck on old values

**Check Event Hooks**:
```bash
tmux list-hooks | grep refresh-client
```

**Force Refresh**:
```bash
# Manual refresh
tmux refresh-client -S

# Or trigger window change
Ctrl+s Tab  # Switch to last window, then back
```

## Neovim Integration Issues

### Escape Lag in Neovim
**Problem**: Delay when pressing Esc in Neovim

**Check Escape Time**:
```bash
tmux show-options -g escape-time
# Should be 0
```

**Fix Escape Time**:
```bash
# Set in tmux.conf (already included)
set -s escape-time 0

# Apply immediately
tmux set-option -s escape-time 0
```

### File Change Detection Not Working
**Problem**: Neovim doesn't detect external file changes

**Check Focus Events**:
```bash
tmux show-options -g focus-events
# Should be "on"
```

**Enable Focus Events**:
```bash
# Set in tmux.conf (already included)
set -g focus-events on

# Apply immediately
tmux set-option -g focus-events on
```

**Verify Neovim Configuration**:
```lua
-- Add to Neovim config
vim.opt.termguicolors = true
vim.o.autoread = true

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  callback = function()
    vim.cmd("checktime")
  end,
})
```

## Clipboard Issues

### Copy to System Clipboard Not Working
**Problem**: `y` in copy mode doesn't copy to system clipboard

**Check System Dependencies**:
```bash
# Linux: Check for xsel or xclip
which xsel || which xclip

# macOS: Check for reattach-to-user-namespace
which reattach-to-user-namespace
```

**Install Dependencies**:
```bash
# Ubuntu/Debian
sudo apt install xsel
# OR
sudo apt install xclip

# macOS
brew install reattach-to-user-namespace

# Arch Linux
sudo pacman -S xsel
```

**Test tmux-yank**:
```bash
# Check if plugin is loaded
tmux list-keys | grep yank

# Test copy operation
Ctrl+s [  # Enter copy mode
# Select text and press 'y'
```

### Paste Not Working
**Problem**: `Ctrl+s ]` doesn't paste or pastes wrong content

**Check Clipboard Contents**:
```bash
# Check tmux buffers
tmux list-buffers

# Check system clipboard (Linux)
xsel -b -o
# OR
xclip -selection clipboard -o
```

**Clear Buffers**:
```bash
# Clear all tmux buffers
tmux delete-buffer -a

# Clear specific buffer
tmux delete-buffer -b 0
```

## Navigation Issues

### Vim-Tmux Navigator Not Working
**Problem**: `Ctrl+h/j/k/l` doesn't navigate between Vim and tmux

**Check Plugin Installation**:
```bash
ls ~/.config/tmux/plugins/vim-tmux-navigator
```

**Check Keybindings**:
```bash
tmux list-keys | grep "select-pane"
```

**Test Navigation**:
```bash
# Test outside of Vim
Ctrl+s h  # Should move left

# Test inside Vim
# Open Vim and try Ctrl+h/j/k/l
```

**Vim Configuration Required**:
```vim
" Add to Vim/Neovim config
let g:tmux_navigator_no_mappings = 0
let g:tmux_navigator_save_on_switch = 1
let g:tmux_navigator_disable_when_zoomed = 1
```

### Pane Navigation Not Working
**Problem**: `Ctrl+s h/j/k/l` doesn't move between panes

**Check Keybindings**:
```bash
tmux list-keys | grep "select-pane"
```

**Verify Mouse Support**:
```bash
tmux show-options -g mouse
# Should be "on"
```

**Test with Mouse**:
```bash
# Click in different panes to verify they work
# If mouse works but keys don't, check keybinding conflicts
```

## Performance Issues

### Tmux Running Slow
**Problem**: Commands laggy, status bar updates slowly

**Check Status Interval**:
```bash
tmux show-options -g status-interval
# Should be 1 (already optimized)
```

**Check History Limit**:
```bash
tmux show-options -g history-limit
# Should be 50000 (reasonable for modern systems)
```

**Reduce History if Needed**:
```bash
# Reduce for older systems
set -g history-limit 10000
```

### High CPU Usage
**Problem**: tmux process using excessive CPU

**Check for Plugin Issues**:
```bash
# Temporarily disable plugins
# Comment out all @plugin lines in tmux.conf
# Reload and test performance
```

**Check Event Hooks**:
```bash
tmux list-hooks
# Look for excessive or misconfigured hooks
```

## Plugin-Specific Issues

### Rose Pine Theme Not Loading
**Problem**: Theme looks like default tmux

**Check Plugin Installation**:
```bash
ls ~/.config/tmux/plugins/tmux
```

**Check Theme Settings**:
```bash
tmux show-options -g @rose_pine_variant
# Should be "moon"
```

**Reinstall Theme**:
```bash
rm -rf ~/.config/tmux/plugins/tmux
# Press: Ctrl+s I to reinstall
```

### Mode Indicator Not Showing
**Problem**: No color indicator when pressing prefix

**Check Plugin Installation**:
```bash
ls ~/.config/tmux/plugins/tmux-mode-indicator
```

**Check Mode Indicator Settings**:
```bash
tmux show-options -g @mode_indicator_prefix_mode_style
```

**Test Mode Indicator**:
```bash
# Press and hold Ctrl+s
# Should see red color in status bar
```

## Configuration Issues

### Changes Not Applying
**Problem**: Modified tmux.conf but changes don't take effect

**Reload Configuration**:
```bash
# Method 1: Keybinding
Ctrl+s r

# Method 2: Command line
tmux source-file ~/.config/tmux/tmux.conf

# Method 3: Restart tmux
tmux kill-server
tmux
```

**Check Configuration Syntax**:
```bash
# Test configuration file
tmux source-file ~/.config/tmux/tmux.conf
# Look for error messages
```

### Configuration Lost After Restart
**Problem**: Settings reset after system reboot

**Check Configuration Location**:
```bash
# Verify config is in correct location
ls -la ~/.config/tmux/tmux.conf

# Check if tmux is reading correct config
tmux show-options -g | head
```

**Set Default Config Path**:
```bash
# Add to shell profile (.bashrc, .zshrc)
export TMUX_CONFIG="$HOME/.config/tmux/tmux.conf"

# Or create symlink
ln -sf ~/.config/tmux/tmux.conf ~/.tmux.conf
```

## Debug Commands

### General Debugging
```bash
# Show tmux version
tmux -V

# Show all options
tmux show-options -g

# Show window options
tmux show-window-options -g

# List all keybindings
tmux list-keys

# List all hooks
tmux list-hooks

# Show session information
tmux display-message -p "#{session_name}"
```

### Plugin Debugging
```bash
# Check installed plugins
ls ~/.config/tmux/plugins/

# Test specific plugin
tmux run-shell "~/.config/tmux/plugins/plugin-name/script.sh"

# Check plugin keybindings
tmux list-keys | grep plugin-name
```

### Performance Debugging
```bash
# Check tmux process
ps aux | grep tmux

# Check memory usage
top -p $(pgrep tmux)

# Check for zombie processes
ps aux | grep defunct
```

## Getting Help

### Command Line Help
```bash
# tmux manual
man tmux

# List all commands
tmux list-commands

# Get help for specific command
tmux command-prompt "help command-name"
```

### Community Resources
- [tmux GitHub](https://github.com/tmux/tmux)
- [TPM Issues](https://github.com/tmux-plugins/tpm/issues)
- [Rose Pine Theme Issues](https://github.com/rose-pine/tmux/issues)

### Creating Bug Reports
When reporting issues, include:
1. tmux version (`tmux -V`)
2. Terminal type (`echo $TERM`)
3. Operating system
4. Relevant configuration sections
5. Exact error messages
6. Steps to reproduce

---

**Note**: Most issues in this configuration are related to plugin installation or system dependencies. Always check plugin installation first when troubleshooting.