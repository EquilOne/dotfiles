#!/bin/bash
# =============================================================================
# FZF FUNCTIONS (Yazi-aware - only what Yazi can't do)
# =============================================================================

if ! command -v fzf >/dev/null 2>&1; then
    return
fi

# Content search with ripgrep (jump to specific line)
if command -v rg >/dev/null 2>&1; then
    rgf() {
        rg --color=always --line-number --no-heading --smart-case "${*:-}" |
            fzf --ansi \
                --delimiter : \
                --preview 'bat --color=always {1} --highlight-line {2}' \
                --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
                --bind 'enter:become(${EDITOR:-vim} {1} +{2})'
    }
fi

# Git branch switcher
if command -v git >/dev/null 2>&1; then
    fgb() {
        if ! git rev-parse --git-dir >/dev/null 2>&1; then
            echo "Not in a git repository"
            return 1
        fi
        
        local branch
        branch=$(git branch --all | grep -v HEAD | 
            fzf --preview 'git log --oneline --graph --color=always {1}' \
                --preview-window=right:60%)
        
        [[ -n "$branch" ]] && git checkout $(echo "$branch" | sed 's/^[ *]*//' | sed 's#remotes/[^/]*/##')
    }
fi

if [[ -n "$SHELL_DEBUG" ]]; then
    echo "🔍 15_functions/fzf_functions.sh loaded - rgf, fgb"
fi
