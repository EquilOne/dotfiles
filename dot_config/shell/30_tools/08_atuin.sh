# ATUIN — shell history search (Ctrl-R), local-only (no sync)
# https://docs.atuin.sh/
# Bash + zsh. Up-arrow stays with ble.sh / zsh defaults; Atuin is Ctrl-R only.
# Config: ~/.config/atuin/config.toml (auto_sync = false, fuzzy, full style)

if ! command -v atuin >/dev/null 2>&1; then
  [[ -n "${SHELL_DEBUG:-}" ]] && echo "[DEBUG] 30_tools/08_atuin.sh skipped - atuin not found"
  return 2>/dev/null || exit 0
fi

# ---------------------------------------------------------------------------
# bash — must run AFTER 06_blesh.sh attach (Atuin binds C-r via readline;
# ble.sh wraps readline widgets at attach, so late binding wins and is
# still widget-wrapped by ble.sh).
# ---------------------------------------------------------------------------
if [[ "$CURRENT_SHELL" == "bash" ]]; then
  eval "$(atuin init bash --disable-up-arrow --disable-ai)"
fi

# ---------------------------------------------------------------------------
# zsh — must run AFTER 05_zsh_vi_mode.sh and 07_zsh_autosuggestions.sh so the
# autosuggest wrapper widgets already exist and Atuin wraps *those* (keeps
# ghost-suggestion suppression correct) and vi binds are untouched.
# ---------------------------------------------------------------------------
if [[ "$CURRENT_SHELL" == "zsh" ]]; then
  eval "$(atuin init zsh --disable-up-arrow --disable-ai)"
fi

[[ -n "${SHELL_DEBUG:-}" ]] && echo "[DEBUG] 30_tools/08_atuin.sh loaded - atuin active for $CURRENT_SHELL"
