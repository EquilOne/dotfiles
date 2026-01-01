#!/bin/bash
# =============================================================================
# 10_USER ALIASES (cross-shell compatible)
# =============================================================================

# System
alias shutdown='sudo shutdown now'
alias restart='sudo reboot'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ~='cd ~'

# eza, add icons, group by directory
alias eza='eza --icons=always --color=always --group-directories-first'

# eza to ls when eza availble
if command -v eza >/dev/null 2>&1; then
  # ls replacements
  alias ls='eza -F auto'
  alias la='eza -AF auto'
  alias ll='eza -lhF auto'
  alias lla='eza -lhAF auto'
  # tree
  alias lt='eza -TF auto -L 3'
  alias lta='eza -ATF auto -L 3'
  alias ltl='eza -lhTF auto -L 3'
  alias ltla='eza -lhATF auto -L 3'
  # helpers (ls + eza = lz)
  alias lzr='ll -F auto --color=always --sort=modified --reverse | head -20'          # Recent files
  alias lzs='ll -F auto --color=always --total-size --sort=size --reverse | head -20' # File sizes
  alias lzg='ll -F auto --git --git-repos --git-ignore 2>/dev/null || ll'             # Git files
  alias lzgt='ll -TF auto --git --git-repos --git-ignore 2>/dev/null || ltl'          # Git files tree view
else
  alias ls='ls -F --color=auto'
  alias la='ls -AF --color=auto'
  alias ll='ls -lhF --color=auto'
  alias lla='ls -lahF --color=auto'
  alias lt='tree -FC -L 3'
  alias lta='tree -aFC -L 3'
  alias lzr='ls -lt | head -20'
  alias lzs='du -sh * | sort -hr | head -20'
  alias lzg='ls -lh'
fi

# Grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Git
alias g='git'
alias gs='git switch'
alias gsc='git switch -c'
alias ga='git add'
alias gwd='git add .'
alias gc='git commit -v'
alias gcm='git commit -m'
alias gst='git status'
alias gps='git push'
alias gpl='git pull'
alias gl='git log --oneline'
alias gll='git log'
alias glg='git log --oneline --graph'
alias glten='git log --oneline -n 10'
alias glgten='git log --oneline --graph -n 10'

# Chezmoi
alias ch='chezmoi'
alias cha='chezmoi add'
alias che='chezmoi edit'
alias chd='chezmoi diff'
alias chu='chezmoi update'
alias chst='chezmoi status'
alias chap='chezmoi apply'
alias chz='chezmoi cd'

# Cat --> Bat
alias cat='bat'

# Yazi enhancements
if command -v yazi >/dev/null 2>&1; then
  alias yz='yazi'
  alias yw='yazi "$WORKSPACE"'
  alias yah='yazi "$(history 1 | awk "{print \$2}")"'
fi

# Debug: Show what loaded
if [[ -n "$SHELL_DEBUG" ]]; then
  echo "🔍 10_aliases.sh loaded - $(command -v eza >/dev/null 2>&1 && echo 'eza' || echo 'ls') ready"
fi
