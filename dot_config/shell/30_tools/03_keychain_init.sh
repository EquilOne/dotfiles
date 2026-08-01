#!/bin/bash
# =============================================================================
# KEYCHAIN INITIALIZATION
# =============================================================================

if [[ -t 0 && -t 1 ]] && command -v keychain >/dev/null 2>&1; then
  eval "$(keychain --eval --quiet id_ed25519)"
fi
if [[ -n "$SHELL_DEBUG" ]]; then
  echo "[DEBUG] 30_tools/keychain_init.sh loaded - keychain initialized"
fi
