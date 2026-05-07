#!/bin/bash
# =============================================================================
# 30_ZOXIDE INTEGRATION
# =============================================================================

if ! command -v zoxide >/dev/null 2>&1; then
    return
fi

# Shell-specific initialization
if [[ "$CURRENT_SHELL" == "bash" ]]; then
    eval "$(zoxide init bash)"
elif [[ "$CURRENT_SHELL" == "zsh" ]]; then
    eval "$(zoxide init zsh)"
fi

# Interactive zoxide with FZF preview (fixed to strip scores)
if command -v fzf >/dev/null 2>&1; then
    zi() {
        local result
        # Use awk to extract only the path (column 2 onwards)
        result=$(zoxide query -l -s | 
            fzf --height=40% \
                --layout=reverse \
                --preview 'eza --tree --level=2 --color=always {2..} 2>/dev/null || ls -la {2..}' \
                --preview-window=right:60% \
                --header='Zoxide history: Select directory' |
            awk '{$1=""; sub(/^ /, ""); print}')
        
        [[ -n "$result" ]] && cd "$result" && pwd
    }
fi

alias zz='z -'
alias zh='zoxide query -l -s'

if [[ -n "$SHELL_DEBUG" ]]; then
    echo "🔍 30_tools/zoxide_init.sh loaded - z, zi, zz, zh"
fi
