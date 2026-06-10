#!/usr/bin/env zsh
# =============================================================================
# ZSH-VI-MODE INITIALIZATION (zsh-only)
# =============================================================================
# A better and friendly vi(vim) mode plugin for ZSH.
# https://github.com/jeffreytse/zsh-vi-mode
#
# Arch Linux install location: /usr/share/zsh/plugins/zsh-vi-mode/
#
# IMPORTANT: This file must run AFTER fzf_init.sh (02) and zoxide_init.sh (04)
# because zsh-vi-mode overwrites keybindings on init. We re-bind them via
# zvm_after_init hook.
# =============================================================================

if [[ "$CURRENT_SHELL" != "zsh" ]]; then
    [[ -n "$SHELL_DEBUG" ]] && echo "[DEBUG] 35_zsh_vi_mode.sh skipped - not zsh"
    return
fi

# Check plugin is installed
if [[ ! -f /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh ]]; then
    [[ -n "$SHELL_DEBUG" ]] && echo "[WARN] 35_zsh_vi_mode.sh - plugin not found"
    return
fi

# ---------------------------------------------------------------------------
# Configuration (called by plugin before init)
# ---------------------------------------------------------------------------
function zvm_config() {
    # Always start in insert mode (like the old bindkey -v behavior)
    ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT

    # Cursor styles: beam in insert, block in normal
    ZVM_CURSOR_STYLE_ENABLED=true
    ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM
    ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
    ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
    ZVM_VISUAL_LINE_MODE_CURSOR=$ZVM_CURSOR_BLOCK
    ZVM_APPEND_MODE_CURSOR=$ZVM_CURSOR_UNDERLINE

    # Use the newer NEX readkey engine (default)
    ZVM_READKEY_ENGINE=$ZVM_READKEY_ENGINE_NEX

    # System clipboard integration (enabled, auto-detects pbcopy/wl-copy/xclip)
    ZVM_SYSTEM_CLIPBOARD_ENABLED=true

    # Surround mode: classic (ys/ci/di style)
    ZVM_VI_SURROUND_BINDKEY=classic

    # Key timeout: 0.4s default, escape timeout: 0.03s default
    # ZVM_KEYTIMEOUT=0.4
    # ZVM_ESCAPE_KEYTIMEOUT=0.03
}

# ---------------------------------------------------------------------------
# Post-init hook: re-bind keybindings that zsh-vi-mode overwrites
# ---------------------------------------------------------------------------
function zvm_after_init() {
    # Re-initialize fzf keybindings (Ctrl+T, Ctrl+R, Alt+C)
    if command -v fzf >/dev/null 2>&1; then
        eval "$(fzf --zsh)"
        bindkey '^ ' fzf-file-widget
    fi

    # Re-initialize zoxide cd hook
    if command -v zoxide >/dev/null 2>&1; then
        eval "$(zoxide init zsh)"
    fi

    # Re-initialize carapace completions (if needed - mostly zstyle/compinit)
    if command -v carapace >/dev/null 2>&1; then
        source <(carapace _carapace)
    fi

    [[ -n "$SHELL_DEBUG" ]] && echo "[DEBUG] zvm_after_init - fzf/zoxide/carapace re-bound"
}

# ---------------------------------------------------------------------------
# Post-lazy-keybindings: custom normal/visual mode bindings
# ---------------------------------------------------------------------------
function zvm_after_lazy_keybindings() {
    # Example: bind Ctrl+E in normal mode to a custom widget
    # zvm_bindkey vicmd '^E' my_custom_widget

    [[ -n "$SHELL_DEBUG" ]] && echo "[DEBUG] zvm_after_lazy_keybindings executed"
}

# ---------------------------------------------------------------------------
# Mode indicator: update Starship custom module via ZVM_CURRENT_MODE
# ---------------------------------------------------------------------------
function zvm_after_select_vi_mode() {
    case $ZVM_MODE in
        $ZVM_MODE_NORMAL)
            export ZVM_CURRENT_MODE="Normal"
            ;;
        $ZVM_MODE_INSERT)
            export ZVM_CURRENT_MODE="Insert"
            ;;
        $ZVM_MODE_VISUAL)
            export ZVM_CURRENT_MODE="Visual"
            ;;
        $ZVM_MODE_VISUAL_LINE)
            export ZVM_CURRENT_MODE="V-Line"
            ;;
        $ZVM_MODE_REPLACE)
            export ZVM_CURRENT_MODE="Replace"
            ;;
        *)
            export ZVM_CURRENT_MODE="Insert"
            ;;
    esac
}

# Source the plugin (must be LAST in this file)
source /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# Initialize mode indicator for first prompt (insert mode default)
export ZVM_CURRENT_MODE="Insert"

if [[ -n "$SHELL_DEBUG" ]]; then
    echo "[DEBUG] 35_zsh_vi_mode.sh loaded - zsh-vi-mode v0.12.0 active"
fi
