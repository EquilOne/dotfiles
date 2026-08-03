#!/bin/bash
# =============================================================================
# STARSHIP PROMPT INITIALIZATION (cross-shell compatible)
# =============================================================================

# Set prompt config by column width before Starship initializes.
set_starship_width() {
    local columns="${COLUMNS:-80}"

    if (( columns < 40 )); then
        export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship_minimal.toml"
    elif (( columns < 80 )); then
        export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship_narrow.toml"
    else
        export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
    fi
}

set_starship_width

if command -v starship >/dev/null 2>&1; then
    [[ "$CURRENT_SHELL" == "bash" ]] && eval "$(starship init bash)"
    [[ "$CURRENT_SHELL" == "zsh" ]]  && eval "$(starship init zsh)"
fi

if [[ -n "$SHELL_DEBUG" ]]; then
    echo "[DEBUG] 15_functions/01_starship.sh loaded - starship prompt"
fi
