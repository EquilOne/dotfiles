#!/bin/bash
# =============================================================================
# BREW CONFIGURATION (cross-shell compatible)
# =============================================================================

# Search known Homebrew locations in priority order:
# 1. System Linuxbrew (shared install)
# 2. User Linuxbrew
# 3. macOS Apple Silicon
# 4. macOS Intel / user fallback
BREW_PATHS=(
    "/home/linuxbrew/.linuxbrew/bin/brew"
    "$HOME/.linuxbrew/bin/brew"
    "/opt/homebrew/bin/brew"
    "$HOME/.homebrew/bin/brew"
)

for brew_path in "${BREW_PATHS[@]}"; do
    if [[ -x "$brew_path" ]]; then
        eval "$("$brew_path" shellenv)"
        break
    fi
done
unset brew_path BREW_PATHS

if [[ -n "$SHELL_DEBUG" ]]; then
    echo "[DEBUG] 05_brew.sh loaded - $(command -v brew 2>/dev/null || echo "brew not found")"
fi
