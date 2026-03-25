
if command -v direnv >/dev/null 2>&1; then
    [[ "$CURRENT_SHELL" == "bash" ]] && eval "$(direnv hook bash)"
    [[ "$CURRENT_SHELL" == "zsh" ]] && eval "$(direnv hook zsh)"
fi
