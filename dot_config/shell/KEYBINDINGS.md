# Keybindings Quick Reference

## Shell Functions

| Command | Description |
|---------|-------------|
| `rgf` | Content search with ripgrep + FZF |
| `fgb` | Git branch switcher with FZF |
| `fy` | FZF directory picker → open in Yazi |
| `zy` | Zoxide + Yazi integration |
| `y` | Change shell directory with Yazi |
| `yz` | Simple Yazi launcher |
| `yw` | Open Yazi in workspace directory |
| `yah` | Open Yazi in last command's directory |

## FZF (Fuzzy Finder)

| Key | Action | Description |
|-----|--------|-------------|
| `Ctrl+T` | File search | Find files in current directory tree |
| `Alt+C` | Directory search | Change to a directory (fuzzy) |
| `Ctrl+R` | History search | Search command history |
| `Ctrl+Space` | Enhanced file widget | Advanced file selection |

## Zoxide (Directory Jumper)

| Command | Description |
|---------|-------------|
| `z <query>` | Jump to directory (frecency-based) |
| `zi` | Interactive directory picker with FZF |
| `zz` | Jump to previous directory |
| `zh` | List all zoxide history |

## Yazi (File Manager)

| Command | Description |
|---------|-------------|
| `yazi` | Open Yazi (standard) |
| `y` | Open Yazi with auto-cd on exit |
| `fy` | Open Yazi via FZF directory picker |
| `zy` | Open Yazi via Zoxide history |

### Inside Yazi

| Key | Action |
|-----|--------|
| `q` | Quit |
| `j/k` | Navigate down/up |
| `h/l` | Parent directory / Enter directory |
| `Space` | Select file |
| `/` | Search |

## Debugging

| Command | Description |
|---------|-------------|
| `export SHELL_DEBUG=1` | Enable debug mode |
| `source ~/.config/shell/loader.sh` | Reload configuration |
| `~/.config/shell/test_config.sh` | Run configuration tests |