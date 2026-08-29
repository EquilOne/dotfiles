# BLE.SH — enhanced bash line editor (vi mode, syntax highlighting)
# https://github.com/akinomyoga/ble.sh
# Bash-only. Settings mirror 05_zsh_vi_mode.sh: vi mode, start in insert,
# mode-aware cursor. Runs late (30_tools) so all other bashrc config is in place.

# Install: built from source (github.com/akinomyoga/ble.sh) -> ~/.local/share/blesh/
BLESH_SRC="$HOME/.local/share/blesh/ble.sh"

if [[ "$CURRENT_SHELL" == "bash" ]]; then
  if [[ ! -f "$BLESH_SRC" ]]; then
    echo "[30_tools] ble.sh not found at $BLESH_SRC (skip)"
  else
    # Default attach strategy: attaches before first prompt via PROMPT_COMMAND.
    # ble.sh no-ops itself in non-interactive/subshell contexts.
    source "$BLESH_SRC" --noattach

    if [[ -n "${BLE_VERSION:-}" ]]; then
      # --- Settings -----------------------------------------------------------
      bleopt default_keymap=vi                  # vi mode (replaces `set -o vi`)
      bleopt keymap_vi_mode_update_prompt=1     # prompt redraws per mode
      bleopt cursor_xterm_mode=1
      bleopt keymap_vi_mode_cursor_insert=6     # beam in insert
      bleopt keymap_vi_mode_cursor_normal=2     # block in normal
      bleopt complete_auto_complete=0           # no auto popup; Tab completes

      # --- Post-load hook (runs when keymap_vi loads at attach) ---------------
      function _blesh_post_load {
        # Always start in insert mode (like zsh-vi-mode)
        ble/keymap:vi/edit_and_mode/insert

        # bash-completion + fzf bridges from contrib
        local contrib="$HOME/.local/share/blesh/contrib/integration"
        [[ -f $contrib/bash-completion.bash ]] && source "$contrib/bash-completion.bash"
        if command -v fzf >/dev/null 2>&1 && [[ -f $contrib/fzf-key-bindings.bash ]]; then
          source "$contrib/fzf-key-bindings.bash"
        fi
      }
      blehook/eval-after-load keymap_vi _blesh_post_load

      [[ -n "${SHELL_DEBUG:-}" ]] && \
        echo "[DEBUG] 30_tools/06_blesh.sh - ble.sh $BLE_VERSION active"
    elif [[ -n "${SHELL_DEBUG:-}" ]]; then
      echo "[DEBUG] 30_tools/06_blesh.sh - ble.sh skipped (non-interactive context)"
    fi
  fi
fi
