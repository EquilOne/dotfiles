# =============================================================================
# 00_CORE ENVIRONMENT CONFIGURATION (loads first)
# =============================================================================

# XDG Base Dirs
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Project dirs
export WORKSPACE="$HOME/workspace"

# Tool-specific config dirs
export EZA_CONFIG_DIR="$XDG_CONFIG_HOME/eza"
export YAZI_CONFIG_DIR="$XDG_CONFIG_HOME/yazi"
export FZF_BASE="$XDG_CONFIG_HOME/fzf"
export BAT_CONFIG_DIR="$XDG_CONFIG_HOME/bat"

# Chezmoi
export CHEZMOI_DOTFILES="$XDG_DATA_HOME/chezmoi"

# Editor Config
export VISUAL="${VISUAL:-nvim}"
export EDITOR="$VISUAL"

# Node.js package managers
export PNPM_HOME="$HOME/.local/share/pnpm"
export BUN_INSTALL="$HOME/.bun"

# Go install location
export GOPATH="$HOME/go"

# OpenCode: enable EXA web search (required when not using OpenCode provider)
export OPENCODE_ENABLE_EXA=1

# Proton Pass CLI: use the filesystem key provider; the default kernel
# keyring is revoked in SSH/headless sessions, which otherwise breaks
# `chezmoi apply` (protonPass render) with NoStorageAccess(KeyRevoked).
export PROTON_PASS_KEY_PROVIDER=fs

# Debug: Show what loaded
if [[ -n "$SHELL_DEBUG" ]]; then
  echo "🔍 00_env.sh loaded - XDG_CONFIG_HOME=$XDG_CONFIG_HOME"
fi
