if [[ "$CURRENT_SHELL" == "zsh" ]]; then
  # Initialize completion system before tool inits
  autoload -Uz compinit
  compinit
fi
