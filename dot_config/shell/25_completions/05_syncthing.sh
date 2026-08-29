# Syncthing shell completions
# `syncthing install-completions` prints these exact lines; see its PR #9226.
if command -v syncthing >/dev/null 2>&1; then
  if [[ "$CURRENT_SHELL" == "zsh" ]]; then
    autoload -U +X bashcompinit && bashcompinit
    complete -C /usr/bin/syncthing syncthing
  elif [[ "$CURRENT_SHELL" == "bash" ]]; then
    complete -C /usr/bin/syncthing syncthing
  fi
fi

if [[ -n "$SHELL_DEBUG" ]]; then
  echo "[DEBUG] 25_completions/05_syncthing.sh loaded - syncthing completions initialized"
fi
