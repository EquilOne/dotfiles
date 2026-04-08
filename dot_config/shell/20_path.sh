#!/bin/bash
# =============================================================================
# 20_PATH MANAGEMENT (cross-shell compatible)
# =============================================================================

# Helper function to safely prepend to PATH
path_prepend() {
    if [[ -d "$1" && ":$PATH:" != *":$1:"* ]]; then
        export PATH="$1:$PATH"
    fi
}

# Remove duplicate PATH entries, preserving first-occurrence order.
# Bash lacks zsh's `typeset -U`; this provides equivalent behaviour.
path_dedup() {
    local new_path="" entry
    while IFS= read -r entry; do
        [[ -z "$entry" ]] && continue
        if [[ ":$new_path:" != *":$entry:"* ]]; then
            new_path="${new_path:+$new_path:}$entry"
        fi
    done <<< "$(echo "$PATH" | tr ':' '\n')"
    export PATH="$new_path"
}

# Priority order (high to low priority):
path_prepend "$HOME/.local/bin"

# Lang pkg mngrs
path_prepend "$HOME/.cargo/bin"
path_prepend "$GOPATH/bin"
path_prepend "$HOME/.local/opt/go/bin"
path_prepend "$BUN_INSTALL/bin"
path_prepend "$PNPM_HOME"

# Clean up duplicates after all path modifications
if [[ "$CURRENT_SHELL" == "zsh" ]]; then
    typeset -U path PATH   # zsh built-in dedup
else
    path_dedup             # bash: manual dedup (zsh has typeset -U above)
fi

# Bun completions (cross-shell compatible)
if [[ "$CURRENT_SHELL" == "zsh" && -s "$HOME/.bun/_bun" ]]; then
    source "$HOME/.bun/_bun"
fi

# Cleanup
unset -f path_prepend path_dedup

# Debug output
if [[ -n "$SHELL_DEBUG" ]]; then
    echo "🔍 20_path.sh loaded - PATH has $(echo $PATH | tr ':' '\n' | wc -l) directories"
fi

