if command -v uv >/dev/null 2>&1; then
  if [[ "$CURRENT_SHELL" == "zsh" ]]; then
    eval "$(uv generate-shell-completion zsh 2>/dev/null)"
  elif [[ "$CURRENT_SHELL" == "bash" ]]; then
    eval "$(uv generate-shell-completion bash 2>/dev/null)"
  fi
fi

if [[ -n "$SHELL_DEBUG" ]]; then
  echo "[DEBUG] 25_completions/uv.sh loaded - UV completions initialized"
fi
