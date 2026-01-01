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

# Priority order (high to low priority):
path_prepend "$HOME/.local/bin"

# Lang pkg mngrs
path_prepend "$HOME/.cargo/bin"
path_prepend "$GOPATH/bin"
path_prepend "$HOME/.local/opt/go/bin"
path_prepend "$BUN_INSTALL/bin"
path_prepend "$PNPM_HOME"

# Clean up duplicates (zsh-only feature, must be guarded)
if [[ "$CURRENT_SHELL" == "zsh" ]]; then
	typeset -U path PATH
fi

# Bun completions (cross-shell compatible)
if [[ "$CURRENT_SHELL" == "zsh" && -s "$HOME/.bun/_bun" ]]; then
    source "$HOME/.bun/_bun"
fi

# Cleanup
unset -f path_prepend

# Debug output
if [[ -n "$SHELL_DEBUG" ]]; then
    echo "🔍 20_path.sh loaded - PATH has $(echo $PATH | tr ':' '\n' | wc -l) directories"
fi

