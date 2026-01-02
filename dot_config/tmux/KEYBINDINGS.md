# Keybindings Reference

Complete reference for all keybindings in this tmux configuration.

## Prefix

**Primary Prefix**: `Ctrl+s` (replaces default `Ctrl+b`)

### Prefix Behavior
- `Ctrl+s` - Send prefix (activates tmux command mode)
- `Ctrl+s Ctrl+s` - Send literal `Ctrl+s` to terminal (for nested sessions)

## Core Navigation

### Pane Navigation (Vi-Style)
| Keybinding | Action | Use Case |
|------------|--------|----------|
| `Ctrl+s h` | Move to left pane | Navigate left |
| `Ctrl+s j` | Move to down pane | Navigate down |
| `Ctrl+s k` | Move to up pane | Navigate up |
| `Ctrl+s l` | Move to right pane | Navigate right |

### Vim-Tmux Navigator Integration
| Keybinding | Action | Context |
|------------|--------|---------|
| `Ctrl+h` | Navigate left | Seamless Vim/tmux navigation |
| `Ctrl+j` | Navigate down | Seamless Vim/tmux navigation |
| `Ctrl+k` | Navigate up | Seamless Vim/tmux navigation |
| `Ctrl+l` | Navigate right | Seamless Vim/tmux navigation |
| `Ctrl+\` | Previous pane/ split | Toggle between last positions |

**How it works:** The vim-tmux-navigator plugin detects if you're in Vim/Neovim and routes navigation accordingly, creating a seamless experience between Vim splits and tmux panes.

### Window Navigation
| Keybinding | Action | Description |
|------------|--------|-------------|
| `Ctrl+s Tab` | Last window | Toggle between current and previous window |
| `Ctrl+s C-p` | Previous window | Move to previous window in sequence |
| `Ctrl+s C-n` | Next window | Move to next window in sequence |
| `Ctrl+s 0-9` | Go to window | Direct jump to window number |
| `Ctrl+s w` | List windows | Show interactive window list |

## Window Management

### Creation and Destruction
| Keybinding | Action | Notes |
|------------|--------|-------|
| `Ctrl+s c` | Create new window | Smart naming applied automatically |
| `Ctrl+s &` | Kill current window | Confirmation not required |
| `Ctrl+s ,` | Rename window | Manual override of smart naming |

### Window Manipulation
| Keybinding | Action | Description |
|------------|--------|-------------|
| `Ctrl+s .` | Move window | Prompts for new position |
| `Ctrl+s m` | Mark window | Mark current window for later reference |
| `Ctrl+s M` | Last marked | Jump to last marked window |

## Pane Management

### Creation and Splitting
| Keybinding | Action | Special Feature |
|------------|--------|-----------------|
| `Ctrl+s |` | Horizontal split | Maintains current directory |
| `Ctrl+s -` | Vertical split | Maintains current directory |
| `Ctrl+s %` | Vertical split | Default tmux binding (still available) |
| `Ctrl+s "` | Horizontal split | Default tmux binding (still available) |

### Pane Destruction
| Keybinding | Action | Safety Level |
|------------|--------|--------------|
| `Ctrl+s x` | Kill current pane | No confirmation (frequent operation) |
| `Ctrl+s X` | Kill window/session | Smart confirmation based on window count |
| `Ctrl+s C-x` | Kill server | Always requires confirmation |

### Pane Manipulation
| Keybinding | Action | Description |
|------------|--------|-------------|
| `Ctrl+s {` | Swap pane left | Move current pane left |
| `Ctrl+s }` | Swap pane right | Move current pane right |
| `Ctrl+s !` | Break pane to window | Convert pane to new window |
| `Ctrl+s ;` | Last active pane | Toggle between last active panes |
| `Ctrl+s o` | Rotate panes | Rotate through panes in window |

### Pane Resizing
| Keybinding | Action | Default tmux |
|------------|--------|--------------|
| `Ctrl+s C-↑` | Resize up | `resize-pane -U` |
| `Ctrl+s C-↓` | Resize down | `resize-pane -D` |
| `Ctrl+s C-←` | Resize left | `resize-pane -L` |
| `Ctrl+s C-→` | Resize right | `resize-pane -R` |

## Copy Mode

### Entering and Exiting
| Keybinding | Action | Context |
|------------|--------|---------|
| `Ctrl+s [` | Enter copy mode | Start text selection |
| `Ctrl+s ]` | Paste from clipboard | Paste tmux clipboard |
| `Escape` | Exit copy mode | Cancel selection |

### Copy Mode Navigation (Vi-Style)
| Keybinding | Action | Description |
|------------|--------|-------------|
| `h/j/k/l` | Move cursor | Basic cursor movement |
| `w/b` | Word forward/back | Jump by words |
| `0/$` | Line start/end | Jump to line boundaries |
| `gg/G` | File start/end | Jump to file boundaries |
| `/` | Search forward | Find text |
| `?` | Search backward | Find text backwards |
| `n` | Next match | Jump to next search result |
| `N` | Previous match | Jump to previous search result |

### Text Selection
| Keybinding | Action | Result |
|------------|--------|--------|
| `Space` | Start selection | Begin text selection |
| `Enter` | Copy selection | Copy to tmux buffer |
| `y` | Copy to system | Copy to system clipboard (tmux-yank) |

### Copy Mode Scrolling
| Keybinding | Action | Description |
|------------|--------|-------------|
| `PageUp` | Scroll up page | Move up one page |
| `PageDown` | Scroll down page | Move down one page |
| `C-u` | Scroll up half | Move up half page |
| `C-d` | Scroll down half | Move down half page |

## Session Management

### Session Creation and Attachment
| Keybinding | Action | Shell Command |
|------------|--------|---------------|
| `tmux new -s name` | New named session | Create session with name |
| `tmux attach -t name` | Attach to session | Connect to existing session |
| `tmux ls` | List sessions | Show all sessions |
| `tmux kill-session -t name` | Kill session | Terminate specific session |

### Session Switching (Within tmux)
| Keybinding | Action | Description |
|------------|--------|-------------|
| `Ctrl+s s` | Session menu | Interactive session selection |
| `Ctrl+s $` | Rename session | Change current session name |
| `Ctrl+s d` | Detach session | Leave session running |
| `Ctrl+s D` | Detach client | Detach specific client |

## Configuration and Management

### Configuration
| Keybinding | Action | Result |
|------------|--------|--------|
| `Ctrl+s r` | Reload config | Apply configuration changes |
| `Ctrl+s :` | Command prompt | Enter tmux command mode |
| `Ctrl+s ?` | List keybindings | Show all keybindings |

### Plugin Management (TPM)
| Keybinding | Action | Description |
|------------|--------|-------------|
| `Ctrl+s I` | Install plugins | Install plugins from config |
| `Ctrl+s U` | Update plugins | Update all installed plugins |
| `Ctrl+s alt+u` | Clean plugins | Remove unused plugins |

### Information and Status
| Keybinding | Action | Information |
|------------|--------|-------------|
| `Ctrl+s q` | Display panes | Show pane numbers temporarily |
| `Ctrl+s t` | Show clock | Display large clock |
| `Ctrl+s ~` | Show messages | Display message log |

## Buffer Management

### Buffer Operations
| Keybinding | Action | Description |
|------------|--------|-------------|
| `Ctrl+s #` | List buffers | Show all paste buffers |
| `Ctrl+s =` | Choose buffer | Select buffer to paste |
| `Ctrl+s -` | Delete buffer | Delete current buffer |
| `Ctrl+s +` | Delete all buffers | Clear all paste buffers |

## Layout Management

### Layout Switching
| Keybinding | Action | Layout Type |
|------------|--------|-------------|
| `Ctrl+s Space` | Next layout | Cycle through layouts |
| `Ctrl+s M-1` | Even horizontal | All panes equal height |
| `Ctrl+s M-2` | Even vertical | All panes equal width |
| `Ctrl+s M-3` | Main horizontal | One main pane, others stacked |
| `Ctrl+s M-4` | Main vertical | One main pane, others stacked |
| `Ctrl+s M-5` | Tiled | Grid layout |

### Zoom and Focus
| Keybinding | Action | Effect |
|------------|--------|--------|
| `Ctrl+s z` | Zoom pane | Toggle zoom current pane |
| `Ctrl+s !` | Break pane | Convert pane to window |

## Advanced Features

### Synchronized Panes
| Keybinding | Action | Description |
|------------|--------|-------------|
| `Ctrl+s :setw synchronize-panes` | Toggle sync | Send input to all panes |

### Client Management
| Keybinding | Action | Description |
|------------|--------|-------------|
| `Ctrl+s c` | New client | Create new client for session |
| `Ctrl+s &` | Kill client | Close current client |

## Custom Keybinding Patterns

### Mnemonic Design
- **Splits**: `|` for vertical, `-` for horizontal (visual representation)
- **Navigation**: `h/j/k/l` matches Vi/Vim muscle memory
- **Destruction**: `x` for pane, `X` for window, `C-x` for server (progressive danger)
- **Configuration**: `r` for reload (common abbreviation)

### Safety Levels
1. **No Confirmation**: `x` (pane kill) - too frequent to confirm
2. **Smart Confirmation**: `X` (window/session) - confirms only if it would kill session
3. **Always Confirmation**: `C-x` (server) - most destructive operation

## Integration with Other Tools

### Vim/Neovim Integration
The vim-tmux-navigator plugin provides seamless integration:
- Detects when you're in Vim/Neovim automatically
- Routes navigation commands appropriately
- Works with nested tmux sessions
- Configurable detection patterns

### System Clipboard
tmux-yank plugin integration:
- `y` in copy mode copies to system clipboard
- Works across Linux/macOS with appropriate dependencies
- Maintains separate tmux and system clipboards

## Troubleshooting Keybindings

### Common Issues
1. **Prefix not working**: Check if another application is using `Ctrl+s`
2. **Vim navigation not working**: Ensure vim-tmux-navigator is installed
3. **Copy to clipboard not working**: Install `xsel`/`xclip` (Linux) or `reattach-to-user-namespace` (macOS)

### Debug Commands
```bash
# List all current keybindings
tmux list-keys

# Check specific keybinding
tmux list-keys | grep "split-window"

# Show prefix key
tmux show-options -g prefix
```

---

**Note**: This reference covers all keybindings in the current configuration. Default tmux keybindings not explicitly overridden remain available.