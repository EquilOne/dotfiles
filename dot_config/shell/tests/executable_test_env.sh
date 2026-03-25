#!/bin/bash
# =============================================================================
# TESTS: ENVIRONMENT VARIABLES AND CONFIG FILES
# =============================================================================

echo ""
echo "Environment Variables"
echo "---------------------"

# XDG Base Directories
assert_set XDG_CONFIG_HOME
assert_set XDG_DATA_HOME
assert_set XDG_CACHE_HOME
assert_set XDG_STATE_HOME

# Editors and workspace
assert_set EDITOR
assert_set VISUAL
assert_set WORKSPACE

# Language / package manager homes
assert_set PNPM_HOME
assert_set BUN_INSTALL
assert_set GOPATH

# Shell detection
assert_set CURRENT_SHELL

echo ""
echo "Rose Pine Colors"
echo "----------------"
assert_set ROSE_PINE_BASE
assert_set ROSE_PINE_SURFACE
assert_set ROSE_PINE_OVERLAY
assert_set ROSE_PINE_MUTED
assert_set ROSE_PINE_SUBTLE
assert_set ROSE_PINE_TEXT
assert_set ROSE_PINE_LOVE
assert_set ROSE_PINE_GOLD
assert_set ROSE_PINE_ROSE
assert_set ROSE_PINE_PINE
assert_set ROSE_PINE_FOAM
assert_set ROSE_PINE_IRIS

echo ""
echo "FZF Configuration"
echo "-----------------"
assert_set FZF_DEFAULT_OPTS

echo ""
echo "Config Files Present"
echo "--------------------"
assert_file "$HOME/.config/shell/loader.sh"
assert_file "$HOME/.config/shell/00_env.sh"
assert_file "$HOME/.config/shell/00_rose_pine_colors.sh"
assert_file "$HOME/.config/shell/05_brew.sh"
assert_file "$HOME/.config/shell/10_aliases.sh"
assert_file "$HOME/.config/shell/20_path.sh"
assert_file "$HOME/.config/shell/15_functions/01_starship.sh"
assert_file "$HOME/.config/shell/15_functions/02_yazi_shell_wrapper.sh"
assert_file "$HOME/.config/shell/15_functions/fzf_functions.sh"
assert_file "$HOME/.config/shell/15_functions/yazi_integration.sh"
assert_file "$HOME/.config/shell/21_zsh_completions.sh"
assert_file "$HOME/.config/shell/22_alias_completions.sh"
assert_file "$HOME/.config/shell/25_completions/carapace.sh"
assert_file "$HOME/.config/shell/30_tools/direnv_init.sh"
assert_file "$HOME/.config/shell/30_tools/fzf_init.sh"
assert_file "$HOME/.config/shell/30_tools/zoxide_init.sh"
