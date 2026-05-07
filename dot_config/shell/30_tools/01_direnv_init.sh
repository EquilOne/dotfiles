#!/bin/bash
# =============================================================================
# DIRENV HOOK INITIALIZATION (cross-shell compatible)
# =============================================================================

if command -v direnv >/dev/null 2>&1; then
    [[ "$CURRENT_SHELL" == "bash" ]] && eval "$(direnv hook bash)"
    [[ "$CURRENT_SHELL" == "zsh" ]]  && eval "$(direnv hook zsh)"
fi

if [[ -n "$SHELL_DEBUG" ]]; then
    echo "[DEBUG] 30_tools/direnv_init.sh loaded - direnv hook"
fi
