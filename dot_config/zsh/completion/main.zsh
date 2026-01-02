# Zsh completion system
autoload -Uz compinit
compinit

# ev package manager autocomplete comands
if command -v uv >/dev/null 2>&1 && eval "$(uv generate-shell-completion zsh 2>/dev/null)"; then
    [[ -n "$SHELL_DEBUG" ]] && echo "🔍 UV completions loaded"
else
    [[ -n "$SHELL_DEBUG" ]] && echo "🔍 UV completion setup failed"
fi
