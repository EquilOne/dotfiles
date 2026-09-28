# AGENTS.md — Shell Configuration System

Modular Bash/Zsh dotfiles at `~/.config/shell` (Omarchy/Hyprland), sourced by `loader.sh` in deterministic numeric order. Architecture: `README.md`; keybindings: `KEYBINDINGS.md`.

## Loading model (loader.sh)

- Entry: `source ~/.config/shell/loader.sh` from `.bashrc` / `$ZDOTDIR/.zshrc`.
- `$CURRENT_SHELL` is set (zsh/bash/unknown) in the loader from `$ZSH_VERSION`/`$BASH_VERSION`; gate all shell-specific syntax on it, never on `$SHELL`.
- **Interactive guard**: the loader returns immediately for non-interactive shells — bash via `[[ $- != *i* ]]`, zsh via `[[ ! -o interactive ]]`. Sourcing it inside a script or test does nothing.
- Files and whole directories matching `[0-8][0-9]*` (00–89) source in numeric order. **Files starting with `9x` never load** — the glob stops at 89.
- `env.local` is sourced last, after everything numbered.
- The loader supports a `${CURRENT_SHELL}_specific/` dir (`zsh_specific/`, `bash_specific/`) but none exist — files use `$CURRENT_SHELL` guards instead.

## Numbering

- `00-09` core env: `00_env`, `00_rose_pine_colors`, `01_theme`, `05_brew`, `09_omarchy`
- `10-19` aliases + `15_functions/` (sourced as a directory)
- `20-29` PATH/completions: `20_path`, `21_zsh_completions`, `22_alias_completions`, `25_completions/`
- `30-39` tool inits in `30_tools/`

`README.md`'s file tree is stale — several newer files aren't listed there. Trust the actual files.

## Conventions (follow when editing)

- **Shell guards first**: files with zsh-only syntax wrap everything in `if [[ "$CURRENT_SHELL" == "zsh" ]]` (e.g. `21_zsh_completions`, `22_alias_completions`) or `return` early for the wrong shell (`30_tools/05_zsh_vi_mode.sh`).
- **Graceful degradation**: `command -v <tool>` before defining tool aliases or eval-ing inits (see `10_aliases`, `30_tools/04_zoxide_init`, `22_alias_completions`). Never assume a tool is installed.
- **PATH edits stay in `20_path.sh`**: the `path_prepend`/`path_dedup` helpers are `unset` at the end of that file and unavailable in later files. Add PATH entries only inside `20_path.sh`.
- **Secrets / local state → `env.local`** (untracked, loaded last). Never put secrets in numbered files.
- Debug a load: `export SHELL_DEBUG=1 && source ~/.config/shell/loader.sh` (the loader unsets `SHELL_DEBUG` when done).

## Testing (bash-only harness)

- Full suite: `~/.config/shell/test_config.sh`
- Single module: `source ~/.config/shell/tests/helpers.sh && load_config && source ~/.config/shell/tests/test_<module>.sh && summary`
- Fresh-shell check: `bash --login -c "type <cmd>"` and `zsh --login -c "type <cmd>"`
- Assertions in `tests/helpers.sh`: `assert_set`, `assert_command`, `assert_file`, `assert_path_contains`; `summary` prints totals and exits non-zero on any failure.
- `load_config` bypasses the interactive guard on purpose: sets `CURRENT_SHELL=bash`, enables `expand_aliases`, and sources a **hardcoded list**, not the loader glob. New config files are therefore NOT covered by tests until added to that list in `tests/helpers.sh` plus `assert_file` in `tests/test_env.sh` — the list already lags the repo (missing `01_theme`, `09_omarchy`, and several `15_functions`/`25_completions`/`30_tools` files).
- Because tests force `CURRENT_SHELL=bash`, zsh-only branches never run at runtime; `test_zsh_completions.sh` checks the zsh file statically instead (grep/syntax).

## References

- `README.md` — architecture, alias tables, tool inventory
- `KEYBINDINGS.md` — keybindings
- Parent `~/.config/AGENTS.md` — after editing any tracked config here, run `chezmoi re-add <file>`
