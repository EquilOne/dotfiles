#!/bin/bash
# =============================================================================
# STARSHIP PROMPT INITIALIZATION (cross-shell compatible)
# =============================================================================

if command -v starship >/dev/null 2>&1; then
    [[ "$CURRENT_SHELL" == "bash" ]] && eval "$(starship init bash)"
    [[ "$CURRENT_SHELL" == "zsh" ]]  && eval "$(starship init zsh)"
fi

# Set prompt config by column width
set_starship_width() {
    if (( COLUMNS < 40 )); then
        export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship_minimal.toml"
    elif (( COLUMNS < 80 )); then
        export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship_narrow.toml"
    else
        export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
    fi
}

if [[ -n "$SHELL_DEBUG" ]]; then
    echo "[DEBUG] 15_functions/01_starship.sh loaded - starship prompt"
fi
