#!/bin/bash
# =============================================================================
# CARAPACE COMPLETION BRIDGE (cross-shell compatible)
# =============================================================================

if command -v carapace >/dev/null 2>&1; then
    if [[ "$CURRENT_SHELL" == "zsh" ]]; then
        export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
        zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
        source <(carapace _carapace)
    elif [[ "$CURRENT_SHELL" == "bash" ]]; then
        export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
        source <(carapace _carapace)
    fi
fi

if [[ -n "$SHELL_DEBUG" ]]; then
    echo "[DEBUG] 25_completions/carapace.sh loaded - carapace completion bridge"
fi
