#!/bin/bash
# =============================================================================
# ROSE PINE MOON COLOR PALETTE (loads early with 00_ prefix)
# =============================================================================
# Reference: https://rosepinetheme.com/palette/ingredients/

# Base colors
export ROSE_PINE_BASE='#232136'        # Main background
export ROSE_PINE_SURFACE='#2a273f'    # Secondary background
export ROSE_PINE_OVERLAY='#393552'    # Highlight background
export ROSE_PINE_MUTED='#6e6a86'      # Inactive foreground
export ROSE_PINE_SUBTLE='#908caa'     # Comments
export ROSE_PINE_TEXT='#e0def4'       # Primary foreground
export ROSE_PINE_LOVE='#eb6f92'       # Red/pink
export ROSE_PINE_GOLD='#f6c177'       # Yellow/warning
export ROSE_PINE_ROSE='#ea9a97'       # Light red/rose
export ROSE_PINE_PINE='#3e8fb0'       # Cyan/info
export ROSE_PINE_FOAM='#9ccfd8'       # Teal/success
export ROSE_PINE_IRIS='#c4a7e7'       # Purple/special
export ROSE_PINE_HIGHLIGHT_LOW='#2a283e'   # Subtle highlight
export ROSE_PINE_HIGHLIGHT_MED='#44415a'   # Medium highlight  
export ROSE_PINE_HIGHLIGHT_HIGH='#56526e'  # Strong highlight

# FZF integration - pre-configured color scheme
export FZF_DEFAULT_OPTS="\
--color=bg+:$ROSE_PINE_OVERLAY,bg:$ROSE_PINE_SURFACE\
,spinner:$ROSE_PINE_ROSE,hl:$ROSE_PINE_GOLD\
,fg:$ROSE_PINE_TEXT,header:$ROSE_PINE_IRIS\
,info:$ROSE_PINE_PINE,pointer:$ROSE_PINE_ROSE\
,marker:$ROSE_PINE_GOLD,fg+:$ROSE_PINE_TEXT\
,prompt:$ROSE_PINE_PINE,hl+:$ROSE_PINE_GOLD\
,border:$ROSE_PINE_HIGHLIGHT_LOW,preview-bg:$ROSE_PINE_BASE"

# Debug output
if [[ -n "$SHELL_DEBUG" ]]; then
    echo "🔍 00_rose_pine_colors.sh loaded - theme ready"
fi
