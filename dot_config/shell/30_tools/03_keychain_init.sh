#!/bin/bash
# =============================================================================
# SSH AGENT SOCKET — keys served by the pass-cli SSH agent daemon
# =============================================================================
# The daemon runs as a systemd user unit (pass-ssh-agent.service) and serves
# keys from the Proton Pass 'ssh-keys' vault. This hook only points
# SSH_AUTH_SOCK at its socket — no agent startup, no key loading, no cost.

PASS_AGENT_SOCK="$HOME/.ssh/proton-pass-agent.sock"

if [[ -S "$PASS_AGENT_SOCK" ]]; then
    export SSH_AUTH_SOCK="$PASS_AGENT_SOCK"
fi

if [[ -n "$SHELL_DEBUG" ]]; then
    echo "[DEBUG] 30_tools/keychain_init.sh loaded - SSH_AUTH_SOCK=${SSH_AUTH_SOCK:-<unset>}"
fi
