# Carapace register completions
if [[ "$CURRENT_SHELL" == "zsh" ]]; then
  export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
  zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
  source <(carapace _carapace)
elif [[ "$CURRENT_SHELL" == "bash" ]]; then
  export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
  source <(carapace _carapace)
fi

