#!/bin/bash
# =============================================================================
# ZSH COMPLETIONS (zsh-specific)
# =============================================================================

if [[ "$CURRENT_SHELL" == "zsh" ]]; then
  # Initialize completion system before tool inits
  autoload -Uz compinit
  compinit
fi

if [[ -n "$SHELL_DEBUG" ]]; then
    echo "[DEBUG] 21_zsh_completions.sh loaded - zsh completion system initialized"
fi
