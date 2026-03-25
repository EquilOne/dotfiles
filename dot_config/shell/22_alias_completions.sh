#!/bin/bash
# =============================================================================
# ALIAS COMPLETIONS (zsh-specific)
# =============================================================================

if [[ "$CURRENT_SHELL" == "zsh" ]]; then
  # Inherit eza completions for ls aliases
  command -v eza &>/dev/null && {
    compdef ls=eza
    compdef la=eza
    compdef ll=eza
    compdef lla=eza
    compdef lt=eza
    compdef lta=eza
    compdef ltl=eza
    compdef ltla=eza
    compdef lzr=eza
    compdef lzs=eza
    compdef lzg=eza
  }

  # Add more alias completions as needed
fi

if [[ -n "$SHELL_DEBUG" ]]; then
    echo "[DEBUG] 22_alias_completions.sh loaded - alias completions configured"
fi
