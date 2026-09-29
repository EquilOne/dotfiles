#!/bin/bash
# =============================================================================
# 06_HERDR - herdr wrapper: force TerminalAnsi encoding + server keybindings
# =============================================================================
# Ghostty 1.3.1 crashes on herdr's SemanticFrame render stream when attaching
# to a remote. TerminalAnsi (server-side ANSI diff) avoids the crash.
# Local herdr sessions keep SemanticFrame (default) since they work fine.
# https://github.com/ghostty-org/ghostty
#
# Remote attaches also default to --remote-keybindings server: the 0.9.x
# client silently drops plugin_action keybindings (herdr-splits nav) in
# local mode, and the launcher overwrites any inherited
# HERDR_REMOTE_KEYBINDINGS env value, so the flag must be on the command
# line. An explicit --remote-keybindings is left untouched.
# See herdrdev/herdr#1598.

if command -v herdr >/dev/null 2>&1; then
  herdr() {
    if [[ "$1" == "--remote" ]]; then
      if [[ " $* " == *" --remote-keybindings "* ]]; then
        HERDR_RENDER_ENCODING=terminal-ansi command herdr "$@"
      else
        HERDR_RENDER_ENCODING=terminal-ansi command herdr "$@" --remote-keybindings server
      fi
    else
      command herdr "$@"
    fi
  }
fi
