#!/bin/bash
# =============================================================================
# OMARCHY THEME INTEGRATION (loads after 00_env.sh)
# =============================================================================
# Omarchy owns terminal/desktop theming via ~/.local/state/omarchy/current/theme
# (rewritten on `omarchy theme set`). This file bridges the active theme name to
# programs Omarchy does not theme natively, mapping rose-pine variants onto the
# vendored assets that already ship in the dotfiles. Everything else keeps its
# own config: starship variants are width-based (15_functions/01_starship.sh),
# and yazi/tuicr/jolt/mdt/tmux themes are config-file-only with no env hook.

# Only meaningful on an Omarchy system.
if [[ ! -r "${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/current/theme.name" ]]; then
  return 0
fi

# Ordering contract: 01_theme.sh defines omarchy_theme_apply, 09_omarchy.sh
# re-applies it after Omarchy's rc chain (which sets BAT_THEME=ansi).
omarchy_theme_apply() {
  _omarchy_theme_name="$(<"${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/current/theme.name")"
  export OMARCHY_THEME="$_omarchy_theme_name"
  unset _omarchy_theme_name

  case "$OMARCHY_THEME" in
    rose-pine* | rosepine*)
      # bat: vendored rose-pine-moon theme in $BAT_CONFIG_DIR/themes (00_env.sh)
      if [[ -f "${BAT_CONFIG_DIR:-$XDG_CONFIG_HOME/bat}/themes/rose-pine-moon.tmTheme" ]]; then
        export BAT_THEME="rose-pine-moon"
      fi
      ;;
  esac
}

omarchy_theme_apply

if [[ -n "$SHELL_DEBUG" ]]; then
  echo "🔍 01_theme.sh loaded - OMARCHY_THEME=$OMARCHY_THEME BAT_THEME=${BAT_THEME:-unset}"
fi
