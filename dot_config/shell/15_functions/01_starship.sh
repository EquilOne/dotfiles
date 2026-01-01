# Initialize Starship
if command -v starship >/dev/null 2>&1; then
	[[ "$CURRENT_SHELL" == "bash" ]] && eval "$(starship init bash)"
	[[ "$CURRENT_SHELL" == "zsh" ]] && eval "$(starship init zsh)"
fi

# Set prompt config by column width
function set_starship_width() {
  if [ "$COLUMNS" -lt 40 ]; then
    export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship_minimal.toml"
  elif [ "$COLUMNS" -lt 80 ]; then
    export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship_narrow.toml"
  else
    export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
  fi
}
