#!/usr/bin/env zsh
# =============================================================================
# ZSH-SYNTAX-HIGHLIGHTING INITIALIZATION (zsh-only)
# =============================================================================
# Fish-style live syntax highlighting as you type: green = valid command,
# red = invalid/unknown, underline = valid path, etc.
# https://github.com/zsh-users/zsh-syntax-highlighting
#
# Install: pacman (zsh-syntax-highlighting) or git clone into
#   ~/.local/share/zsh-syntax-highlighting
#
# MUST LOAD LAST of the ZLE plugins: it wraps all ZLE widgets at source time,
# so it runs after 05_zsh_vi_mode.sh, 07_zsh_autosuggestions.sh, and
# 08_atuin.sh — its wrappers must sit on top of theirs. (File number 09 is
# deliberately last in 30_tools; check for new higher-numbered files before
# assuming.)
# =============================================================================

if [[ "$CURRENT_SHELL" != "zsh" ]]; then
    [[ -n "$SHELL_DEBUG" ]] && echo "[DEBUG] 09_zsh_syntax_highlighting.sh skipped - not zsh"
    return
fi

# Locate plugin: pacman path first, git-clone fallback second.
typeset _zsh_sh_plugin=""
for _zsh_sh_plugin in \
    /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
    "$HOME/.local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
do
    [[ -f "$_zsh_sh_plugin" ]] && break
    _zsh_sh_plugin=""
done

if [[ -z "$_zsh_sh_plugin" ]]; then
    [[ -n "$SHELL_DEBUG" ]] && echo "[WARN] 09_zsh_syntax_highlighting.sh - plugin not found (pacman -S zsh-syntax-highlighting)"
    return
fi

# Highlighter set: main (command/path/option validity) is the core; brackets
# and pattern are cheap extras. Keep it lean — every highlighter adds ZLE cost.
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

source "$_zsh_sh_plugin"

unset _zsh_sh_plugin

[[ -n "$SHELL_DEBUG" ]] && echo "[DEBUG] 09_zsh_syntax_highlighting.sh loaded - zsh-syntax-highlighting active"