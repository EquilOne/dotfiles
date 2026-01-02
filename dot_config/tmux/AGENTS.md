# TMUX Configuration - Agent Guidelines

## Build/Test Commands

This is a tmux configuration repository with no traditional build system. Testing and validation:

```bash
# Test configuration syntax
tmux source-file ~/.config/tmux/tmux.conf

# Test plugin installation
tmux run-shell '~/.config/tmux/plugins/tpm/tpm'

# Test individual plugins (from plugin dirs)
cd plugins/tpm && bash tests/test_plugin_update.sh

# Test vim-tmux-navigator integration
tmux list-keys | grep navigator

# Test clipboard functionality
tmux list-keys | grep yank
```

## Code Style Guidelines

### Configuration Format
- Use tmux configuration syntax (`set -g`, `bind`, etc.)
- Group related settings with comment headers
- Use consistent spacing: `set -g option value`

### Naming Conventions
- Plugin options: `@plugin_name_option_name`
- Custom variables: lowercase with underscores
- Keybindings: descriptive, single character where standard

### Organization
1. Core settings first (escape-time, terminal, colors)
2. Keybindings section
3. Plugin declarations
4. Theme configuration
5. Initialize TPM at the end

### Critical Requirements
- Always set `escape-time 0` for Neovim compatibility
- Enable `focus-events on` for editor integration
- Use `tmux-256color` terminal with RGB override
- Maintain 1-based indexing for windows/panes

### Plugin Management
- Declare all plugins before theme settings
- Use TPM for installation/updates
- Test plugin functionality after changes

### Active Plugins
- TPM (plugin manager)
- Rose Pine theme
- tmux-mode-indicator
- tmux-yank (clipboard)
- vim-tmux-navigator (seamless navigation)