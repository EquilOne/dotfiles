#!/bin/bash
# =============================================================================
# KEYCHAIN INITIALIZATION — persistent ssh-agent; keys come from Proton Pass
# =============================================================================

if [[ -t 0 && -t 1 ]] && command -v keychain >/dev/null 2>&1; then
    # Start (or reuse) a persistent agent, loading no on-disk keyfiles:
    # SSH keys are stored in the Proton Pass 'ssh-keys' vault and loaded below.
    eval "$(keychain --eval --quiet)"
    # Load Proton-stored keys into the agent exactly once per agent lifetime
    # (ssh-add -l returns non-zero when the agent holds no identities).
    if command -v pass-cli >/dev/null 2>&1 && ! ssh-add -l >/dev/null 2>&1; then
        pass-cli ssh-agent load --vault-name ssh-keys >/dev/null 2>&1 || true
    fi
fi

if [[ -n "$SHELL_DEBUG" ]]; then
    echo "[DEBUG] 30_tools/keychain_init.sh loaded - keychain initialized"
fi
