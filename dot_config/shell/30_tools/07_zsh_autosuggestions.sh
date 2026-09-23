#!/usr/bin/env zsh
# =============================================================================
# ZSH-AUTOSUGGESTIONS INITIALIZATION (zsh-only)
# =============================================================================
# Fish-style ghost text autosuggestions for zsh.
# https://github.com/zsh-users/zsh-autosuggestions
#
# Install: pacman (zsh-autosuggestions) or git clone into
# ~/.local/share/zsh-autosuggestions
#
# Keybindings mirror 06_blesh.sh (ble.sh auto-complete accepts):
#   -> / End / vi-mode equivalents = accept whole suggestion
#   M-f / forward-word widgets     = partial accept (next word)
#   C-y                            = accept whole suggestion
#   Tab                            = accept next word, else normal completion
#
# Must run AFTER 05_zsh_vi_mode.sh (if installed, it re-binds keys on init).
# The plugin re-wraps widgets on every precmd, so late changes to the widget
# lists still take effect.
# =============================================================================

if [[ "$CURRENT_SHELL" != "zsh" ]]; then
    [[ -n "$SHELL_DEBUG" ]] && echo "[DEBUG] 07_zsh_autosuggestions.sh skipped - not zsh"
    return
fi

# ---------------------------------------------------------------------------
# Locate plugin: pacman path first, git-clone fallback second
# ---------------------------------------------------------------------------
typeset _zsh_as_plugin=""
for _zsh_as_plugin in \
    /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
    "$HOME/.local/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
do
    [[ -f "$_zsh_as_plugin" ]] && break
    _zsh_as_plugin=""
done

if [[ -z "$_zsh_as_plugin" ]]; then
    [[ -n "$SHELL_DEBUG" ]] && echo "[WARN] 07_zsh_autosuggestions.sh - plugin not found"
    return
fi

# ---------------------------------------------------------------------------
# Configuration (must be set BEFORE sourcing the plugin)
# ---------------------------------------------------------------------------
# Strategy order is first-match: history -> completion (built into the plugin,
# uses the compinit cache from 21_zsh_completions.sh) -> match_prev_cmd.
ZSH_AUTOSUGGEST_STRATEGY=(history completion match_prev_cmd)

# Explicit accept lists (includes plugin defaults + both keymaps), so
# suggestions behave identically in insert and normal vi mode.
typeset -ga ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(
    forward-char
    end-of-line
    vi-forward-char
    vi-end-of-line
    vi-add-eol
    vi-add-next
)
typeset -ga ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(
    forward-word
    emacs-forward-word
    vi-forward-word
    vi-forward-word-end
    vi-forward-blank-word
    vi-forward-blank-word-end
    vi-find-next-char
    vi-find-next-char-skip
    _autosuggest_accept_next_word
)

# Tab: accept next word of the suggestion; with no suggestion showing, fall
# back to normal Tab completion (ble.sh parity: _blesh_accept_word_or_complete).
function _autosuggest_accept_next_word() {
    if [[ -n "$POSTDISPLAY" ]]; then
        zle .forward-word
    else
        zle expand-or-complete
    fi
}
zle -N _autosuggest_accept_next_word

# ---------------------------------------------------------------------------
# Source the plugin
# ---------------------------------------------------------------------------
source "$_zsh_as_plugin"

# C-y: accept whole suggestion (ble.sh: ble-bind -f C-y 'auto_complete/insert').
# Bound in both vi keymaps (main keymap is viins via `bindkey -v` in .zshrc).
bindkey -M viins '^Y' autosuggest-accept
bindkey -M vicmd '^Y' autosuggest-accept

# Tab in insert mode: partial accept / completion fallback.
bindkey -M viins '^I' _autosuggest_accept_next_word

unset _zsh_as_plugin

[[ -n "$SHELL_DEBUG" ]] && echo "[DEBUG] 07_zsh_autosuggestions.sh loaded - zsh-autosuggestions active"
