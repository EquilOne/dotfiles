#!/bin/bash
# =============================================================================
# UNIFIED SHELL CONFIGURATION LOADER (with debug mode)
# =============================================================================
# Usage: source ~/.config/shell/loader.sh
# Debug: export SHELL_DEBUG=1 before sourcing

# Early exit if not interactive
[[ $- != *i* ]] && return

# Only load files for the current shell
CURRENT_SHELL="${ZSH_VERSION:+zsh}${BASH_VERSION:+bash}"
CURRENT_SHELL="${CURRENT_SHELL:-unknown}"
export CURRENT_SHELL

CONFIG_DIR="$HOME/.config/shell"

# Debug mode
if [[ -n "$SHELL_DEBUG" ]]; then
	echo "🔍 Loader starting in debug mode"
	echo "🔍 Default Shell (\$SHELL): $SHELL"
	echo "🔍 Active Shell: $CURRENT_SHELL"
	echo "🔍 Config dir: $CONFIG_DIR"
fi

# Enable null globbing, both shells
if [[ "$CURRENT_SHELL" == "zsh" ]]; then
	shopt() { :; }
	setopt local_options null_glob
elif [[ "$CURRENT_SHELL" == "bash" ]]; then
	shopt -s nullglob
fi

# Load numbered items (files and dirs) in order
for item in "$CONFIG_DIR"/[0-9][0-9]*; do
	[[ -e "$item" ]] || continue

    	if [[ -f "$item" && "$item" == *.sh ]]; then
        	[[ -n "$SHELL_DEBUG" ]] && echo "🔍 Loading core file: $item"
        	source "$item"
	elif [[ -d "$item" ]]; then
		[[ -n "$SHELL_DEBUG" ]] && echo "🔍 Loading directory: $item"
		for file in "$item"/*.sh; do
			[[ -f "$file" && "$file" == *.sh ]] || continue
			[[ -n "$SHELL_DEBUG" ]] && echo "🔍   ├─ Loading: $file"
			source "$file"
		done
        fi
done

# Load shell-specific files
SHELL_SPECIFIC_DIR="$CONFIG_DIR/${CURRENT_SHELL}_specific"
if [[ -d "$SHELL_SPECIFIC_DIR" ]]; then
    if [[ -n "$SHELL_DEBUG" ]]; then
        echo "🔍 Loading shell-specific files from: $SHELL_SPECIFIC_DIR"
    fi
    for file in "$SHELL_SPECIFIC_DIR"/*.sh; do
        [[ -f "$file" ]] || continue
        [[ -n "$SHELL_DEBUG" ]] && echo "🔍 Loading specific: $file"
        source "$file"
    done
fi

# Restore default bash glob behavior
if [[ "$CURRENT_SHELL" == "bash" ]]; then
    shopt -u nullglob
fi

if [[ -n "$SHELL_DEBUG" ]]; then
    echo "🔍 Loader completed successfully"
fi

# Cleanup
unset SHELL_DEBUG CONFIG_DIR SHELL_SPECIFIC_DIR item file
unset -f shopt
