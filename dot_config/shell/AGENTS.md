# AGENTS.md - Shell Configuration Repository Guidelines

This repository is a modular, numbered shell configuration system supporting both Bash and Zsh with XDG Base Directory compliance. It lives at `~/.config/shell/` and is sourced at shell startup via `loader.sh`.

## Repository Structure

```
~/.config/shell/
├── loader.sh                        # Main entry point - sources all numbered files
├── 00_env.sh                        # Core env vars (XDG paths, editors, tool homes)
├── 00_rose_pine_colors.sh           # Rose Pine Moon theme color variables
├── 05_brew.sh                       # Homebrew configuration
├── 10_aliases.sh                    # Cross-shell aliases (ls, git, chezmoi, etc.)
├── 15_functions/                    # Custom shell functions (sourced as a directory)
│   ├── 01_starship.sh               # Starship prompt initialization
│   ├── 02_yazi_shell_wrapper.sh     # Yazi with auto-cd on exit
│   ├── fzf_functions.sh             # rgf (rg+fzf), fgb (git branch switcher)
│   └── yazi_integration.sh         # fy (fzf→yazi), zy (zoxide→yazi)
├── 20_path.sh                       # PATH management via path_prepend helper
├── 21_zsh_completions.sh            # Zsh-specific completion setup
├── 22_alias_completions.sh          # Completion wrappers for aliases
├── 25_completions/                  # Additional completion scripts
│   └── carapace.sh                  # Carapace multi-shell completion bridge
├── 30_tools/                        # External tool initializations
│   ├── direnv_init.sh               # Direnv hook
│   ├── fzf_init.sh                  # FZF keybindings + Rose Pine colors
│   └── zoxide_init.sh               # Zoxide init + zi alias
└── test_config.sh                   # Configuration validation script
```

## Numbering System

Files load in strict numerical order. Use this scheme for new files:

| Range | Purpose |
|-------|---------|
| 00-09 | Core environment setup (must load first) |
| 10-19 | User conveniences (aliases, prompts) |
| 15    | Function libraries (directory) |
| 20-29 | System configuration (PATH, completions) |
| 30-39 | External tool initializations |
| 90-99 | Reserved for local/secret configurations |

## Testing

There is no CI. Validate configuration manually:

```bash
# Run the full test suite (checks tools, files, env vars, functions, PATH)
~/.config/shell/test_config.sh

# Enable debug mode to trace exactly which files load and in what order
export SHELL_DEBUG=1
source ~/.config/shell/loader.sh

# Verify a specific tool or alias loaded correctly in each shell
bash --login -c "type zi"
zsh --login -c "type zi"

# Check loader syntax without executing
bash -n ~/.config/shell/loader.sh

# Check a specific file's syntax
bash -n ~/.config/shell/20_path.sh
```

There is no concept of a "single test" - `test_config.sh` runs all checks atomically. To isolate a specific concern, source the relevant file directly in a subshell:

```bash
bash --norc -c "source ~/.config/shell/15_functions/fzf_functions.sh; type rgf"
```

## Code Style Guidelines

### File Headers

Every file must start with a descriptive banner comment following this exact format:

```bash
#!/bin/bash
# =============================================================================
# SECTION_NAME DESCRIPTION (cross-shell compatible)
# =============================================================================
```

Omit the shebang line for files that are always sourced and never executed directly (e.g., `00_env.sh`).

### Indentation and Formatting

- Use **2 spaces** for indentation inside `if`/`for` blocks in most files
- The loader itself uses a mix of tabs and spaces - prefer 4 spaces for new files
- One blank line between logical sections; two blank lines are acceptable between major sections
- Keep lines under ~100 characters where practical

### Naming Conventions

- **Environment variables**: `UPPER_SNAKE_CASE` (e.g., `XDG_CONFIG_HOME`, `ROSE_PINE_BASE`)
- **Local variables inside functions**: `lower_snake_case` declared with `local`
- **Functions**: `lower_snake_case` (e.g., `path_prepend`, `check_var`)
- **Files**: `NN_descriptive_name.sh` with two-digit numeric prefix
- **Aliases**: short, mnemonic abbreviations (e.g., `gs`, `gst`, `ll`, `lla`)

### Variable Declarations

Always use `local` for function-scoped variables to avoid polluting the shell environment:

```bash
my_function() {
    local target
    local branch
    target=$(some_command)
    [[ -n "$target" ]] && do_something "$target"
}
```

Always quote variable expansions: `"$VAR"`, not `$VAR`.

Use default value syntax for optional env vars: `export EDITOR="${EDITOR:-nvim}"`.

### Tool Availability Guards

Never assume a tool is installed. Guard every tool-dependent block:

```bash
if command -v fzf >/dev/null 2>&1; then
    # fzf-dependent code
fi

# Or for early-return pattern in function files:
if ! command -v fzf >/dev/null 2>&1; then
    return
fi
```

### Shell Compatibility Guards

Code must work in both Bash and Zsh unless explicitly guarded:

```bash
# Zsh-only feature guard
if [[ "$CURRENT_SHELL" == "zsh" ]]; then
    typeset -U path PATH
fi

# Bash-only feature guard
if [[ "$CURRENT_SHELL" == "bash" ]]; then
    shopt -s nullglob
fi
```

Use `[[ ]]` (double brackets) for all conditionals - not `[ ]` or `test`. Use `(( ))` for arithmetic.

### Error Handling

- Use `|| continue` or `|| return` for recoverable errors in loops/functions
- Redirect stderr to `/dev/null` when failure is expected: `command -v tool >/dev/null 2>&1`
- Return meaningful exit codes from functions: `return 1` on failure with an error message
- Never use `set -e` globally - handle errors explicitly

```bash
fgb() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Not in a git repository"
        return 1
    fi
    # ... rest of function
}
```

### Debug Output

Every file must emit a debug line at the bottom when `$SHELL_DEBUG` is set:

```bash
if [[ -n "$SHELL_DEBUG" ]]; then
    echo "🔍 filename.sh loaded - brief description of what was registered"
fi
```

### PATH Management

Always use the `path_prepend` helper (defined in `20_path.sh`) rather than manipulating `$PATH` directly. It guards against duplicates and non-existent directories.

### Cleanup

Unset helper functions and temporary variables when they are no longer needed:

```bash
unset -f path_prepend
unset SHELL_DEBUG CONFIG_DIR item file
```

### Comments

- Use section comments (`# Category`) to group related aliases or exports
- Explain *why*, not *what*, for non-obvious logic
- Keep inline comments brief and on the same line

### Adding New Configuration

1. Choose the appropriate numeric range for the file's purpose
2. Name the file `NN_descriptive_name.sh`
3. Add the standard file header banner
4. Guard shell-specific code with `$CURRENT_SHELL` checks
5. Guard tool-dependent code with `command -v` checks
6. Add a `$SHELL_DEBUG` trace line at the bottom
7. Verify with `test_config.sh` and debug mode

### XDG Compliance

All tool config paths must use XDG variables, never hardcoded `~/.config` paths:

```bash
export YAZI_CONFIG_DIR="$XDG_CONFIG_HOME/yazi"   # correct
export YAZI_CONFIG_DIR="$HOME/.config/yazi"       # wrong
```

XDG variables are set in `00_env.sh` and guaranteed to be available to all subsequent files.
