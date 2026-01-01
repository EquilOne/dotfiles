# ~/.config/shell/25_zsh_completion.sh (or use Chezmoi template)

if [[ "$CURRENT_SHELL" == "zsh" ]]; then
  # Initialize completion system before tool inits
  autoload -Uz compinit
  compinit
fi
