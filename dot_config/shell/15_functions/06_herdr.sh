#!/bin/bash
# =============================================================================
# 06_HERDR - herdr wrapper: force TerminalAnsi encoding for --remote
# =============================================================================
# Ghostty 1.3.1 crashes on herdr's SemanticFrame render stream when attaching
# to a remote. TerminalAnsi (server-side ANSI diff) avoids the crash.
# Local herdr sessions keep SemanticFrame (default) since they work fine.
# https://github.com/ghostty-org/ghostty

if command -v herdr >/dev/null 2>&1; then
  herdr() {
    if [[ "$1" == "--remote" ]]; then
      HERDR_RENDER_ENCODING=terminal-ansi command herdr "$@"
    else
      command herdr "$@"
    fi
  }
fi