#!/bin/bash
# =============================================================================
# YAZI SHELL WRAPPER (AUTO-CD ON EXIT) (cross-shell compatible)
# =============================================================================

if ! command -v yazi >/dev/null 2>&1; then
    return
fi

# Launch yazi and cd into the last directory on exit
y() {
    local tmp cwd
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [[ -n "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}

if [[ -n "$SHELL_DEBUG" ]]; then
    echo "[DEBUG] 15_functions/02_yazi_shell_wrapper.sh loaded - yazi auto-cd wrapper (y)"
fi
