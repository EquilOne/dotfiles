#!/bin/bash
# =============================================================================
# PASS-CLI HELPERS — session health check + quick login
# =============================================================================

# pass-check: quiet when healthy, warning when the agent has no keys.
#   pass-check        — check and print status
#   pass-check -q     — exit 0/1 only, no output (for prompts/scripts)
pass_check() {
    local sock="$HOME/.ssh/proton-pass-agent.sock"
    local quiet=""
    [[ "${1:-}" == "-q" ]] && quiet=1

    if [[ ! -S "$sock" ]]; then
        [[ -z "$quiet" ]] && echo "✗ pass-ssh-agent daemon not running (systemctl --user start pass-ssh-agent)"
        return 1
    fi
    if SSH_AUTH_SOCK="$sock" ssh-add -l >/dev/null 2>&1; then
        [[ -z "$quiet" ]] && echo "✓ pass-cli agent OK ($(SSH_AUTH_SOCK="$sock" ssh-add -l | wc -l) key(s))"
        return 0
    fi
    [[ -z "$quiet" ]] && echo "⚠ pass-cli session dead or keys unloaded — run: pass-login"
    return 1
}

# pass-login: re-authenticate pass-cli via browser, then bounce the daemon
# so it picks up the fresh session immediately (no waiting for refresh).
pass_login() {
    pass-cli login seanchasekelly || return 1
    systemctl --user restart pass-ssh-agent.service
    sleep 3
    pass_check
}

# Dash-named convenience names (functions can't contain '-')
alias pass-check='pass_check'
alias pass-login='pass_login'
