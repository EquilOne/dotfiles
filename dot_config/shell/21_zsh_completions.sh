#!/usr/bin/env zsh
# =============================================================================
# ZSH COMPLETIONS (zsh-specific)
# =============================================================================

if [[ "$CURRENT_SHELL" == "zsh" ]]; then
  # Initialize completion system before tool inits
  zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'm:{a-zA-Z}={A-Za-z} r:|[._-]=* r:|=*' 'm:{a-zA-Z}={A-Za-z} r:|[._-]=** r:|=**' 'm:{a-zA-Z}={A-Za-z} l:|=* r:|=*'
  zstyle ':completion:*' menu select
  zstyle ':completion:*' group-name ''
  # Raise the listing cap so zsh's "do you wish to see all N possibilities?"
  # gate (default 100 rows) doesn't interrupt the menu toggle (C-e in zsh).
  zstyle ':completion:*' list-max 500
  zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
  zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
  autoload -Uz compinit
  compinit
  # Add nocaseglob to completion options so compfiles enumerates files case-insensitively.
  # _comp_options is set by compinit and applied via setopt at the start of every completion
  # function - it does not inherit the shell's own options, so we must extend it explicitly.
  _comp_options+=(nocaseglob)
fi

if [[ -n "$SHELL_DEBUG" ]]; then
  echo "[DEBUG] 21_zsh_completions.sh loaded - zsh completion system initialized"
fi
