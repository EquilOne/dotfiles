if command -v herdr >/dev/null 2>&1; then
  if [[ "$CURRENT_SHELL" == "zsh" ]]; then
    eval "$(herdr completion zsh 2>/dev/null)"
  elif [[ "$CURRENT_SHELL" == "bash" ]]; then
    eval "$(herdr completion bash 2>/dev/null)"
  fi
fi

if [[ -n "$SHELL_DEBUG" ]]; then
  echo "[DEBUG] 25_completions/herdr.sh loaded - herdr completions initialized"
fi
