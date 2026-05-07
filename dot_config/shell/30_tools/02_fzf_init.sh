#!/bin/bash
# =============================================================================
# 30_FZF INTEGRATION (keybindings, defaults, functions)
# =============================================================================

if ! command -v fzf >/dev/null 2>&1; then
    return
fi

# Use fd as the default finder
if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# Enhanced preview settings
if command -v bat >/dev/null 2>&1; then
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}' --preview-window=right:60%:wrap --bind 'ctrl-/:toggle-preview'"
    export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {} 2>/dev/null || tree -C {} 2>/dev/null || ls -la {}' --preview-window=right:60%"
else
    export FZF_CTRL_T_OPTS="--preview 'head -100 {}' --preview-window=right:60%"
    export FZF_ALT_C_OPTS="--preview 'ls -la {}' --preview-window=right:60%"
fi

# Shell-specific keybindings
if [[ "$CURRENT_SHELL" == "bash" ]]; then
    eval "$(fzf --bash)"
    bind -x '"\C- ": fzf-file-widget'   # Ctrl+Space (bash)
elif [[ "$CURRENT_SHELL" == "zsh" ]]; then
    eval "$(fzf --zsh)"
    bindkey '^ ' fzf-file-widget   # Ctrl+Space (zsh)
fi

if [[ -n "$SHELL_DEBUG" ]]; then
    echo "🔍 30_tools/fzf_init.sh loaded - Ctrl+T, Ctrl+R, Alt+C active"
fi
