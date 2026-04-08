#!/bin/bash
# =============================================================================
# CARAPACE COMPLETION BRIDGE (cross-shell compatible)
# =============================================================================

if command -v carapace >/dev/null 2>&1; then
  if [[ "$CURRENT_SHELL" == "zsh" ]]; then
    export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
    export CARAPACE_MATCH=1
    export CARAPACE_LENIENT=1
    export CARAPACE_HIDDEN=1
    export CARAPACE_ENV=1
    export CARAPACE_COLOR=1
    zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
    zstyle ':completion:*:git:*' group-order 'main commands' 'alias commands' 'external commands'
    source <(carapace _carapace)
  elif [[ "$CURRENT_SHELL" == "bash" ]]; then
    export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
    export CARAPACE_MATCH=1
    export CARAPACE_LENIENT=1
    export CARAPACE_HIDDEN=1
    export CARAPACE_ENV=1
    source <(carapace _carapace)
  fi
fi

if [[ -n "$SHELL_DEBUG" ]]; then
  echo "[DEBUG] 25_completions/carapace.sh loaded - carapace completion bridge"
fi
