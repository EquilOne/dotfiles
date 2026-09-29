#!/bin/bash
# =============================================================================
# STARSHIP PROMPT INITIALIZATION (cross-shell compatible, device-aware)
# =============================================================================
# Omarchy machines use B's starship_minimal/starship_narrow/starship configs.
# Non-omarchy (pinetab) machines use starship_foot_minimal/starship_foot_narrow
# and default to starship.toml (foot terminal tuned configs).

# Set prompt config by column width before Starship initializes.
set_starship_width() {
    local columns="${COLUMNS:-80}"

    if [[ -d /usr/share/omarchy ]]; then
        if (( columns < 40 )); then
            export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship_minimal.toml"
        elif (( columns < 80 )); then
            export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship_narrow.toml"
        else
            export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship_omarchy.toml"
        fi
    else
        if (( columns < 40 )); then
            export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship_foot_minimal.toml"
        elif (( columns < 80 )); then
            export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship_foot_narrow.toml"
        else
            export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
        fi
    fi
}

set_starship_width

# Resolve starship even before 20_path.sh runs (installer puts it in ~/.local/bin)
STARSHIP_BIN="$(command -v starship 2>/dev/null)"
if [[ -z "$STARSHIP_BIN" && -x "$HOME/.local/bin/starship" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
    STARSHIP_BIN="$HOME/.local/bin/starship"
fi
unset STARSHIP_BIN

if command -v starship >/dev/null 2>&1; then
    [[ "$CURRENT_SHELL" == "bash" ]] && eval "$(starship init bash)"
    [[ "$CURRENT_SHELL" == "zsh" ]]  && eval "$(starship init zsh)"
fi

if [[ -n "$SHELL_DEBUG" ]]; then
    echo "[DEBUG] 15_functions/01_starship.sh loaded - starship prompt"
fi
