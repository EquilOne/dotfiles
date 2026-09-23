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
# Strategy order is first-match. 08_atuin.sh prepends atuin's strategy at
# runtime, so the effective order is: atuin -> history -> match_prev_cmd.
# The plugin's `completion` strategy is intentionally NOT used: it runs the
# completion system in a zpty worker per fetch (78-98 ms), and that worker
# crashes zsh 5.9.2 (SIGFPE, division-by-zero in printfmt() when the pty has
# 0 columns). Command-semantic completion is covered by the C-e/Shift-Tab
# menu (carapace-backed) below, which runs on the foreground shell.
ZSH_AUTOSUGGEST_STRATEGY=(history match_prev_cmd)

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
    autosuggest-accept-next-word
)

# Tab: accept next word of the suggestion; with no suggestion showing, fall
# back to normal Tab completion (ble.sh parity: _blesh_accept_word_or_complete).
# The widget name must NOT start with '_' or '.' — zsh-autosuggestions
# skips such widgets when re-binding on every precmd (its ignore list has
# '_\*' and '.\*' patterns), so the partial-accept wrapper would never be
# applied and Tab's forward-word would have nowhere to move (the suggestion
# lives in POSTDISPLAY, not BUFFER, so it could not advance the cursor).
function _autosuggest_accept_next_word() {
    if [[ -n "$POSTDISPLAY" ]]; then
        zle .forward-word
    else
        zle expand-or-complete
    fi
}
zle -N autosuggest-accept-next-word _autosuggest_accept_next_word

# ---------------------------------------------------------------------------
# Source the plugin
# ---------------------------------------------------------------------------
source "$_zsh_as_plugin"

# C-y: accept whole suggestion (ble.sh: ble-bind -f C-y 'auto_complete/insert').
# Bound in both vi keymaps (main keymap is viins via `bindkey -v` in .zshrc).
bindkey -M viins '^Y' autosuggest-accept
bindkey -M vicmd '^Y' autosuggest-accept

# Tab in insert mode: partial accept / completion fallback.
bindkey -M viins '^I' autosuggest-accept-next-word

# Shift+Tab (backtab): force the normal completion menu (listed options) even
# while a ghost suggestion is displayed. expand-or-complete IS wrapped by the
# plugin now (added to ZSH_AUTOSUGGEST_CLEAR_WIDGETS below — the wrapper only
# clears the ghost, never intercepts the menu). Not bound in vicmd (completion
# menu from normal mode is unexpected).
bindkey -M viins '\e[Z' expand-or-complete

# ---------------------------------------------------------------------------
# Completion menu (fish/blink-style) — C-e toggle, C-n/C-p item navigation
# ---------------------------------------------------------------------------
# zsh has no persistent menu-state API: the interactive menu exists only while
# zle runs the `menuselect` keymap (created by zsh/complist; requires menu
# select zstyle — set in 21_zsh_completions.sh). The conditional keymap layers
# give the fish/blink behavior emergently:
#
#   menu closed (viins)                menu open (menuselect)
#   C-e / C-n  expand-or-complete      ^E  send-break        (toggle off)
#              (opens menu, 1st item)  ^N  down-line-or-history (next item)
#   C-p        reverse-menu-complete   ^P  up-line-or-history   (prev item)
#              (opens menu, last item) ^M  accept-line          (accept item,
#   Enter      accept-line (execute)         returns to line, NO execute)
#   Tab        autosuggest-accept-     ^I  accept-line          (accept item)
#              next-word (existing)    ^Y  accept-line          (accept item)
#   C-y        autosuggest-accept      ^B/^F backward-char/forward-char (no
#              (existing, unchanged)         page scroll in zsh menus)
#
# Limitations vs ble.sh: no auto-popup (menu opens only via C-e/C-n/C-p/S-TAB),
# no description pane, no page scrolling, and huge candidate lists first show
# zsh's "do you wish to see all N possibilities?" prompt.
zmodload zsh/complist 2>/dev/null

# The ghost must clear when the menu opens: expand-or-complete /
# reverse-menu-complete are not in the plugin's default clear list (plugin
# source line 50), and it re-wraps widgets on every precmd, so appending here
# (after source) takes effect on the next precmd.
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(expand-or-complete reverse-menu-complete)

# viins: C-e opens the menu (toggle-on; the C-e close side lives in menuselect).
# The user navigates with vi `$`, so vicmd ^E (end-of-line) stays untouched.
bindkey -M viins '^E' expand-or-complete
bindkey -M viins '^N' expand-or-complete
bindkey -M viins '^P' reverse-menu-complete

# menuselect: all menu-open behavior. Defaults already give arrows (up/down =
# up/down-line-or-history item nav); C-n/C-p match them per the keymap table.
# Enter/C-y/Tab accept the highlighted item and return to the line without
# executing (accept-line semantics inside menu selection). send-break aborts
# the menu and restores the line (toggle-off). backward-char/forward-char keep
# ^B/^F from inserting junk; in zsh they only move the cursor/selection.
bindkey -M menuselect '^E' send-break
bindkey -M menuselect '^N' down-line-or-history
bindkey -M menuselect '^P' up-line-or-history
bindkey -M menuselect '^Y' accept-line
bindkey -M menuselect '^I' accept-line
bindkey -M menuselect '\e[Z' up-line-or-history
bindkey -M menuselect '^B' backward-char
bindkey -M menuselect '^F' forward-char

unset _zsh_as_plugin

[[ -n "$SHELL_DEBUG" ]] && echo "[DEBUG] 07_zsh_autosuggestions.sh loaded - zsh-autosuggestions active"
