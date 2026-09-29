#!/bin/bash
# =============================================================================
# STARSHIP PROMPT INITIALIZATION (cross-shell compatible, device-aware)
# =============================================================================
# Width-tiered prompt router — each machine class has its own variant set:
#   Omarchy machines:   starship_minimal / starship_narrow / starship_omarchy
#   PineTab (foot):     starship_foot_minimal / starship_foot_narrow / starship_foot
#   Other non-omarchy
#   (equil-remote):     starship_minimal / starship_narrow / starship.toml
# The foot set deploys only on the pinetab and the omarchy set only on omarchy
# machines (see .chezmoiignore), so file presence identifies the machine class
# at runtime; every STARSHIP_CONFIG path must therefore point at a deployed file.

set_starship_width() {
    local columns="${COLUMNS:-80}"
    local minimal narrow wide

    if [[ -d /usr/share/omarchy || -d ~/.local/share/omarchy ]]; then
        minimal=starship_minimal.toml
        narrow=starship_narrow.toml
        wide=starship_omarchy.toml
    elif [[ -f "$XDG_CONFIG_HOME/starship/starship_foot.toml" ]]; then
        minimal=starship_foot_minimal.toml
        narrow=starship_foot_narrow.toml
        wide=starship_foot.toml
    else
        minimal=starship_minimal.toml
        narrow=starship_narrow.toml
        wide=starship.toml
    fi

    if (( columns < 40 )); then
        export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/$minimal"
    elif (( columns < 80 )); then
        export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/$narrow"
    else
        export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/$wide"
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
