#!/bin/bash
# =============================================================================
# YAZI INTEGRATION FUNCTIONS
# =============================================================================

if ! command -v yazi >/dev/null 2>&1; then
    return
fi

# FZF directory picker → open in Yazi
fy() {
    if ! command -v fzf >/dev/null 2>&1; then
        echo "FZF not installed"
        return 1
    fi
    
    local target
    target=$(fd --type d --hidden --follow --exclude .git 2>/dev/null | \
        fzf --preview 'eza --tree --level=2 --color=always {} 2>/dev/null || ls -la {}' \
            --preview-window=right:60% \
            --header='Select directory to open in Yazi')
    
    [[ -n "$target" ]] && yazi "$target"
}

# Zoxide + Yazi: Jump to frecent directory in Yazi
zy() {
    if ! command -v zoxide >/dev/null 2>&1; then
        echo "Zoxide not installed"
        return 1
    fi
    
    local target
    target=$(zoxide query -l -s | 
        awk '{$1=""; sub(/^ /, ""); print}' |
        fzf --height=40% --layout=reverse \
            --preview 'eza --tree --level=2 {} 2>/dev/null || ls -la {}' \
            --header='Zoxide history → Open in Yazi')
    
    [[ -n "$target" ]] && yazi "$target"
}

if [[ -n "$SHELL_DEBUG" ]]; then
    echo "🔍 15_functions/yazi_integration.sh loaded - fy, zy"
fi
