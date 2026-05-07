# AGENTS.md — Shell Configuration System

## What This Is

Modular Bash/Zsh dotfiles at `~/.config/shell` with deterministic, numbered loading.

## Architecture

- **Entry point**: `loader.sh`
- **Load order**: `00-89` core, `90-99` reserved for local/secrets (not tracked)
- **Numbering**:
  - `00-09`: Core env
  - `10-19`: Aliases, prompts
  - `15`: Function libraries (sourced as a directory)
  - `20-29`: PATH, completions
  - `30-39`: Tool initializations
- **Shell detection**: `$CURRENT_SHELL` is set from `$ZSH_VERSION`/`$BASH_VERSION` in `loader.sh`
- **Interactive guard**: `loader.sh` exits immediately if `[[ $- != *i* ]]`

## Critical Conventions

- **Add shell-specific guards**: Use `if [[ "$CURRENT_SHELL" == "zsh" ]]` for zsh-only syntax (e.g. `zstyle`, `compinit`). Some files like `21_zsh_completions.sh` are entirely guarded.
- **Graceful degradation**: Aliases and init scripts must check `command -v <tool>` before defining tool-specific aliases (e.g. `eza`, `bat`, `zoxide`, `fzf`). Do not assume tools are installed.
- **PATH dedup**: `20_path.sh` uses `typeset -U` for zsh and a manual `path_dedup` for bash. Use `path_prepend` helper for new entries.
- **No code in `90-99`**: Reserved for local overrides; keep it out of version control.

## Developer Commands

- **Run full test suite**: `~/.config/shell/test_config.sh`
- **Run single test module** (bash only): `source ~/.config/shell/tests/helpers.sh && load_config && source ~/.config/shell/tests/test_<module>.sh && summary`
- **Debug loading**: `export SHELL_DEBUG=1` then `source ~/.config/shell/loader.sh`
- **Test in a fresh shell**: `bash --login -c "type <command>"` or `zsh --login -c "type <command>"`

## Testing Framework

Custom bash assertions in `tests/helpers.sh`:
- `assert_set <VAR>` — env var non-empty
- `assert_command <cmd>` — function/alias/command exists
- `assert_file <path>` — file exists
- `assert_path_contains <str>` — PATH contains exact entry
- `load_config` — manually sources all config files in correct numeric order, sets `CURRENT_SHELL=bash`, enables `expand_aliases`
- `summary` — prints totals and exits non-zero on failure

**Important**: `load_config` skips the interactive guard and mirrors the loader’s numeric order. Use it when editing tests to avoid re-implementing load logic.

## References

- `README.md` — Full architecture, alias tables, tool inventory
- `KEYBINDINGS.md` — Function keybindings and tool shortcuts
