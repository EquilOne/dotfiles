#!/bin/bash
# =============================================================================
# OMARCHY BASH COMPATIBILITY (bash-only)
# =============================================================================
# Loads Omarchy's default bash aliases/functions so they survive the
# unified-shell bashrc. User's 10_aliases.sh loads AFTER this, so user
# aliases override Omarchy's.

# Bash-only: CURRENT_SHELL is set by loader.sh before this file loads
if [[ "${CURRENT_SHELL:-}" != "bash" ]]; then
  return 0
fi

# Only proceed on an Omarchy system
if [[ -z "${OMARCHY_PATH:-}" && ! -r /etc/omarchy.conf ]]; then
  return 0
fi
: "${OMARCHY_PATH:=/usr/share/omarchy}"
if [[ ! -r "$OMARCHY_PATH/default/bash/rc" ]]; then
  return 0
fi

# Replicate Omarchy's interactive rc chain (skips env-bootstrap: the system
# layer already handles it via /etc/profile.d, double-sourcing is redundant)
[[ -r "$OMARCHY_PATH/default/bash/envs" ]] && source "$OMARCHY_PATH/default/bash/envs"
[[ -r "$OMARCHY_PATH/default/bash/shell" ]] && source "$OMARCHY_PATH/default/bash/shell"
[[ -r "$OMARCHY_PATH/default/bash/aliases" ]] && source "$OMARCHY_PATH/default/bash/aliases"
[[ -r "$OMARCHY_PATH/default/bash/functions" ]] && source "$OMARCHY_PATH/default/bash/functions"
[[ -r "$OMARCHY_PATH/default/bash/init" ]] && source "$OMARCHY_PATH/default/bash/init"
[[ $- == *i* ]] && bind -f "$OMARCHY_PATH/default/bash/inputrc"

# Ordering contract: Omarchy's envs set BAT_THEME=ansi; re-apply the dotfiles'
# theme mapping (defined in 01_theme.sh) so rose-pine wins over the default.
[[ "$(declare -F omarchy_theme_apply)" ]] && omarchy_theme_apply

if [[ -n "$SHELL_DEBUG" ]]; then
  echo "[DEBUG] 09_omarchy.sh loaded - OMARCHY_PATH=$OMARCHY_PATH"
fi
