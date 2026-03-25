# Shell Configuration System

Modern, modular shell configuration supporting both Bash and Zsh with XDG Base Directory compliance.

## 🏗️ Architecture

This configuration uses a **numbered loading system** for deterministic execution order:

```
~/.config/shell/
├── loader.sh                 # Main entry point
├── 00_env.sh                 # Core environment variables (XDG paths)
├── 00_rose_pine_colors.sh    # Rose Pine Moon theme colors
├── 05_brew.sh                # Homebrew configuration
├── 10_aliases.sh             # Common aliases (eza, ls, etc.)
├── 15_functions/             # Custom shell functions
│   ├── 01_starship.sh        # Starship prompt integration
│   ├── 02_yazi_shell_wrapper.sh  # Yazi shell wrapper
│   ├── fzf_functions.sh      # FZF utility functions
│   └── yazi_integration.sh   # Yazi file manager integration
├── 20_path.sh                # PATH management
├── 21_zsh_completions.sh     # Zsh completion system init
├── 22_alias_completions.sh   # Completion wrappers for aliases
├── 25_completions/           # Multi-shell completion bridge
│   └── carapace.sh           # Carapace completions
├── 30_tools/                 # Tool initializations
│   ├── direnv_init.sh        # Direnv hook
│   ├── fzf_init.sh           # FZF + keybindings
│   └── zoxide_init.sh        # Zoxide + aliases
├── tests/                    # Modular test suite
│   ├── helpers.sh            # Shared test helpers
│   ├── test_env.sh           # Environment tests
│   ├── test_functions.sh     # Function/Alias tests
│   └── test_path.sh          # PATH integrity tests
└── test_config.sh            # Test runner (delegates to tests/)
```

## 🔢 Numbering System

Files load in numerical order (00-89 for core, 90+ for future secrets):

- **00-09**: Core environment setup
- **10-19**: User conveniences (aliases, prompts)
- **15**: Function libraries
- **20-29**: System configuration (PATH, etc.)
- **30-39**: Tool initializations
- **90-99**: Reserved for local/secret configurations

## 🚀 How It Works

### Shell Startup Flow

1. **Bash**: `~/.bashrc` → `loader.sh` → numbered files
2. **Zsh**: `~/.zshenv` → `$ZDOTDIR/.zshrc` → `loader.sh` → numbered files

### Loader Features

- **Shell detection**: Uses `$ZSH_VERSION`/`$BASH_VERSION` for accurate detection
- **Conditional loading**: Only sources files appropriate for the current shell
- **Debug mode**: Set `export SHELL_DEBUG=1` to trace loading
- **Error resilience**: Skips missing files, continues on errors

## 🛠️ Integrated Tools

| Tool | Purpose | Config Location | Status |
|------|---------|-----------------|---------|
| **FZF** | Fuzzy finder | `30_tools/fzf_init.sh` | ✅ Active |
| **Zoxide** | Smart directory jumper | `30_tools/zoxide_init.sh` | ✅ Active |
| **Yazi** | Terminal file manager | `15_functions/` | ✅ Active |
| **Starship** | Cross-shell prompt | `15_functions/01_starship.sh` | ✅ Active |
| **Direnv** | Directory env loader | `30_tools/direnv_init.sh` | ✅ Active |
| **Carapace** | Multi-shell completion bridge | `25_completions/carapace.sh` | ✅ Active |
| **Vivid** | LS_COLORS generator | `00_rose_pine_colors.sh` | ✅ Optional |

### Key Functions

| Command | Source | Description |
|---------|--------|-------------|
| `rgf` | `15_functions/fzf_functions.sh` | Ripgrep + FZF content search |
| `fgb` | `15_functions/fzf_functions.sh` | Git branch switcher (FZF) |
| `zi` | `30_tools/zoxide_init.sh` | Interactive directory picker |
| `y` | `15_functions/02_yazi_shell_wrapper.sh` | Yazi with auto-cd |
| `fy` | `15_functions/yazi_integration.sh` | FZF → Yazi integration |
| `zy` | `15_functions/yazi_integration.sh` | Zoxide → Yazi integration |
| `set_starship_width` | `15_functions/01_starship.sh` | Set Starship config based on terminal width (COLUMNS < 40: minimal, < 80: narrow, else full) |

### Available Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `yz` | `yazi` | Standard yazi launcher |
| `yw` | `yazi "$WORKSPACE"` | Open yazi in workspace |
| `cat` | `bat` | Modern `cat` replacement (when `bat` is installed) |
| `..`, `...` | `z ..`, `z ../..` | Directory navigation (zoxide-based) |
| `~`, `home` | `z ~` | Jump to home directory |

#### Git Aliases
`g`, `gs`, `gsc`, `ga`, `gwd`, `gc`, `gcm`, `gst`, `gfo`, `gpsh`, `gpl`, `gl`, `gll`, `glg`, `glten`, `glgten`

#### Chezmoi Aliases
`ch`, `cha`, `che`, `chd`, `chu`, `chst`, `chap`, `chz`

#### File Listing (ls/eza)
- **Standard**: `ls`, `la`, `ll`, `lla`
- **Tree**: `lt`, `lta`, `ltl`, `ltla`
- **Smart**: `lzr` (recent), `lzs` (size), `lzg` (git), `lzgt` (git tree)

## 🎨 Theme: Rose Pine Moon

All tools use the Rose Pine Moon color scheme:
- Colors defined in: `00_rose_pine_colors.sh`
- Applied to: FZF, Yazi, shell prompt (via Starship)
- Color variables: `$ROSE_PINE_TEXT`, `$ROSE_PINE_FOAM`, etc.

## 🧪 Testing

Run the full test suite to verify configuration:
```bash
~/.config/shell/test_config.sh
```

Run a single test module:
```bash
source ~/.config/shell/tests/helpers.sh && load_config && source ~/.config/shell/tests/test_functions.sh && summary
```

Or enable debug mode:
```bash
export SHELL_DEBUG=1
source ~/.config/shell/loader.sh
```

## 🍺 Homebrew

The `05_brew.sh` script searches for the `brew` binary in multiple locations across Linux and macOS in priority order:
1. `/home/linuxbrew/.linuxbrew/bin/brew`
2. `$HOME/.linuxbrew/bin/brew`
3. `/opt/homebrew/bin/brew`
4. `$HOME/.homebrew/bin/brew`

## 🔧 Troubleshooting

### Shell doesn't load configuration
```bash
# Check if loader exists and is readable
ls -la ~/.config/shell/loader.sh

# Test manually
source ~/.config/shell/loader.sh
```

### Wrong shell detected
```bash
# Check detection
echo "Current: $CURRENT_SHELL"
echo "ZSH_VERSION: $ZSH_VERSION"
echo "BASH_VERSION: $BASH_VERSION"
```

### Tool not working
```bash
# Verify tool is installed
command -v fzf zoxide yazi eza bat

# Check if init file exists
ls -la ~/.config/shell/30_tools/
```

### FZF keybindings not working
```bash
# In bash:
bind -P | grep fzf

# In zsh:
bindkey | grep fzf
```

## 📚 Maintenance

### Adding New Configuration
1. Create file with appropriate number prefix (e.g., `35_newtool.sh`)
2. Ensure it has proper shell guards if shell-specific
3. Test with debug mode: `export SHELL_DEBUG=1`

### Modifying Existing Files
1. Always test changes in a new shell session
2. Use debug mode to trace issues
3. Keep backups in `~/.config/backups/`

### Updating Tools
After updating FZF, Zoxide, or other integrated tools:
```bash
bash --login -c "type zi"
zsh --login -c "type zi"
```

## 🔐 XDG Base Directory Compliance

All configurations respect XDG Base Directory specification:
- `XDG_CONFIG_HOME` = `~/.config`
- `XDG_DATA_HOME` = `~/.local/share`
- `XDG_CACHE_HOME` = `~/.cache`
- `XDG_STATE_HOME` = `~/.local/state`

## 🎓 References
- [Shell Keybindings](KEYBINDINGS.md) - Quick reference card
- [AI Context](LLM_CONTEXT.md) - Development assistance