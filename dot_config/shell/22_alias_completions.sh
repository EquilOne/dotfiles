# ~/.config/shell/26_alias_completions.sh

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
