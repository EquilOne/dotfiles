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

## Git Aliases

`g`, `gs`, `gsc`, `ga`, `gwd`, `gc`, `gcm`, `gst`, `gfo`, `gpsh`, `gpl`, `gl`, `gll`, `glg`, `glten`, `glgten`

## Chezmoi Aliases

`ch`, `cha`, `che`, `chd`, `chu`, `chst`, `chap`, `chz`

## Vi Mode (zsh-vi-mode + ble.sh)

Zsh uses [zsh-vi-mode](https://github.com/jeffreytse/zsh-vi-mode); bash uses [ble.sh](https://github.com/akinomyoga/ble.sh) (both start in insert mode).

| Key | Mode | Action |
|-----|------|--------|
| `Esc` | insert | Enter normal (vi) mode |
| `i` / `a` / `A` | normal | Re-enter insert mode |
| `v` | normal | Visual selection mode |
| `dd` / `dw` / `d$` | normal | Delete line / word / to end |
| `cc` / `cw` | normal | Change line / word |
| `yy` / `p` | normal | Yank line / paste |
| `u` / `Ctrl+r` | normal | Undo / redo |
| `0` / `$` / `^` | normal | Line start / end / first char |
| `w` / `b` / `e` | normal | Word forward / back / end |
| `Ctrl+r` | insert | History search (fzf) |
| `Ctrl+t` / `Alt+c` | insert | File / directory search (fzf) |
| `Tab` | insert | Complete (ble.sh bash only; no auto-popup) |

ble.sh extras (bash): syntax highlighting, mode-aware cursor (beam=insert, block=normal), shared history. Config in `30_tools/06_blesh.sh`; zsh config in `30_tools/05_zsh_vi_mode.sh`.

## Testing

| Command | Description |
|---------|-------------|
| `~/.config/shell/test_config.sh` | Full suite |
| `source tests/helpers.sh && load_config && source tests/test_env.sh && summary` | Single module |
| `export SHELL_DEBUG=1` | Enable debug mode |
| `source ~/.config/shell/loader.sh` | Reload configuration |