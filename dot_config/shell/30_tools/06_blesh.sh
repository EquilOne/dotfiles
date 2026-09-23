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
      # Core options (declared in core load) — OK before attach.
      bleopt default_keymap=vi                  # vi mode (replaces `set -o vi`)
      bleopt complete_auto_complete=1           # fish-style ghost suggestion (C-y accepts)
      bleopt complete_auto_wordbreaks="$IFS/:=@" # Tab accepts up to next path segment/delimiter
      # Fish/blink-style auto-popup completion menu: shows the candidate menu
      # (desc style when candidates carry descriptions) after `complete_auto_menu`
      # ms of input idle, alongside the ghost suggestion. Declared in ble.sh core
      # (ble.sh:29031-29035), so safe to set before attach.
      bleopt complete_auto_menu=300
      bleopt complete_menu_maxlines=10

      # Auto-complete suggestion accepts, mirroring nvim blink.cmp (super-tab):
      # C-y = accept whole suggestion, Tab = accept next word (falls back to
      # normal Tab completion when no suggestion is showing).
      # NOTE: the auto-complete module loads lazily and its widgets only exist
      # then; binds that reference them directly error at attach ("Unknown
      # widget") and the mid-render output duplicates the first prompt. Use an
      # after-load hook, and a proper ble/widget/ function for the Tab fallback.
      function ble/widget/accept-word-or-complete {
        if ble/is-function ble/widget/auto_complete/insert-word; then
          ble/widget/auto_complete/insert-word
        else
          ble/widget/complete
        fi
      }
      # C-y wrapper: accepts the ghost suggestion when the auto_complete module
      # is loaded (lazy — its widgets only exist then), no-op otherwise.
      # (blehook/eval-after-load auto_complete errors "hook not defined" at
      # config time because the module registers its load hook later.)
      function ble/widget/accept-suggestion {
        ble/is-function ble/widget/auto_complete/insert && ble/widget/auto_complete/insert
      }
      # --- fish/blink-style completion menu ---------------------------------
      # Widgets for the menu keymap (C-e toggle, C-n/C-p navigation). Defined
      # at config time so ble-bind never sees an "Unknown widget"; they call
      # lazily-loaded complete-module widgets only at invocation time.
      #
      # ble.sh internals (lib/core-complete.sh, 0.4.0-devel4):
      # - `ble/widget/complete enter_menu` generates candidates, shows the
      #   menu and pushes the interactive `menu_complete` keymap with the
      #   first item selected ("insert-selection": the selected item is live-
      #   previewed in the line, core-complete.sh:6346 menu-complete/enter).
      #   Plain `complete show_menu` (S-TAB) only displays the menu with no
      #   selection and pushes no keymap, so toggle uses enter_menu instead.
      # - Selection CANNOT be driven while the auto_complete ghost overlay is
      #   active: menu-complete.class/onselect (core-complete.sh:5395) only
      #   rewrites the region up to the cursor and leaves the ghost suffix in
      #   place, corrupting the line (verified: "start" + stale ghost). So
      #   nav widgets cancel the overlay first, then enter the menu.
      # - ac-menu-nav/ac-enter/ac-complete must only pop the overlay when it
      #   is actually on the keymap stack (auto_complete/cancel pops
      #   unconditionally), and route through vi_imap/complete in vi insert
      #   mode to keep vi undo/repeat intact (cf. vi_imap/complete,
      #   lib/keymap.vi.sh:184).
      function ble/widget/ac-complete {
        if [[ $_ble_decode_keymap == vi_imap ]]; then
          ble/widget/vi_imap/complete "$@"
        else
          ble/widget/complete "$@"
        fi
      }
      function ble/widget/complete-toggle-menu {
        if [[ $_ble_complete_menu_active ]]; then
          ble/widget/menu_complete/toggle-hidden
        else
          ble/widget/ac-complete enter_menu
        fi
      }
      # C-n/C-p (and Down/Up while a menu is showing): from the ghost overlay,
      # cancel it first so selection goes through menu-complete/enter; from a
      # plain prompt just enter the menu. "backward" = start from the last item.
      function ble/widget/ac-menu-nav {
        [[ $_ble_decode_keymap == auto_complete ]] && ble/widget/auto_complete/cancel
        ble/widget/ac-complete "enter_menu${1:+:$1}"
      }
      # Enter: menu open -> accept the selected item only (enter + accept,
      # never executes); menu closed -> cancel + redispatch so the base
      # Enter (execute) is unchanged.
      function ble/widget/ac-menu-enter {
        if [[ $_ble_complete_menu_active ]]; then
          [[ $_ble_decode_keymap == auto_complete ]] && ble/widget/auto_complete/cancel
          ble/widget/ac-complete enter_menu
          [[ $_ble_decode_keymap == menu_complete ]] && ble/widget/menu_complete/accept
        else
          ble/widget/auto_complete/cancel
          ble/decode/widget/redispatch
        fi
      }
      # The ghost suggestion is accepted through a dedicated `auto_complete`
      # keymap that shadows vi_imap while a suggestion is active, so C-y/Tab
      # must be bound there. That keymap is defined when the complete module
      # lazy-loads (hook name: `complete`; there is no auto_complete_load hook).
      function _blesh_bind_ac_overlay {
        ble-bind -m auto_complete -f C-y auto_complete/insert
        ble-bind -m auto_complete -f C-i auto_complete/insert-word
        ble-bind -m auto_complete -f Tab auto_complete/insert-word
        # Menu keys while the ghost overlay is up (auto-menu shown or not).
        # C-y/Tab keep the ghost-accept binds above; C-e/C-n/C-p/RET handle the
        # menu conditionally (see widgets above). Up/Down only hijack when a
        # menu is actually showing, else cancel+redispatch keeps base behavior.
        ble-bind -m auto_complete -f C-e complete-toggle-menu
        ble-bind -m auto_complete -f C-n ac-menu-nav
        ble-bind -m auto_complete -f C-p 'ac-menu-nav backward'
        ble-bind -m auto_complete -f RET ac-menu-enter
        ble-bind -m auto_complete -f C-m ac-menu-enter
        ble-bind -m auto_complete -f up 'ac-menu-nav backward'
        ble-bind -m auto_complete -f down ac-menu-nav
        # Interactive menu (menu_complete keymap, pushed by menu-complete/enter).
        # Defaults already cover C-n/C-p/up/down (item nav), C-m/RET (accept
        # item without executing) and prior/next (pages); C-y/Tab are re-pointed
        # at accept per the fish/blink keymap, C-b/C-f page-scroll (defaults are
        # column moves), and C-e toggles the menu visibility in place.
        ble-bind -m menu_complete -f C-e complete-toggle-menu
        ble-bind -m menu_complete -f C-y menu_complete/accept
        ble-bind -m menu_complete -f Tab menu_complete/accept
        ble-bind -m menu_complete -f C-b menu/backward-page
        ble-bind -m menu_complete -f C-f menu/forward-page
      }
      blehook/eval-after-load complete _blesh_bind_ac_overlay
      ble-bind -f C-y accept-suggestion
      ble-bind -f Tab accept-word-or-complete
      # Menu toggle / item navigation on the default (emacs) keymap as well,
      # mirroring the C-y/Tab binds above. C-e must not reach the module's
      # auto_complete overlay default (auto_complete/@end insert) — the
      # overlay keymap rebind for C-e in _blesh_bind_ac_overlay wins.
      ble-bind -f C-e complete-toggle-menu
      ble-bind -f C-n ac-menu-nav
      ble-bind -f C-p 'ac-menu-nav backward'
      # Shift+Tab (backtab, \e[Z -> key name "S-TAB" in init-cmap.sh) = force
      # the normal completion menu even while a ghost suggestion is showing
      # (same widget as the default M-? bind). When a suggestion is active the
      # auto_complete overlay's __default__ cancels it and redispatches the
      # key here. Key name is S-TAB, not STab.
      ble-bind -f S-TAB 'complete show_menu'

      # --- Post-load hook (runs when keymap_vi loads at attach) ---------------
      # Note: keymap_vi_* options are declared lazily in lib/keymap.vi.sh, which
      # loads at attach time. Setting them before attach errors with "not found".
      function _blesh_post_load {
        # keymap_vi_mode_update_prompt: leave at default (empty). It makes every
        # mode switch erase + re-render the whole prompt (ble/prompt/clear),
        # multiplying redraw glitches. The mode indicator + cursor shape update
        # without it. (Prompt-line duplication was separately caused by
        # Ghostty's shell integration OSC 133 marks; fixed via
        # shell-integration = none in ghostty config.)

        # Mode-aware cursor via DECSCUSR code (replaces removed
        # keymap_vi_mode_cursor_* / cursor_xterm_mode bleopts):
        ble-bind -m vi_imap --cursor 6            # steady beam in insert
        ble-bind -m vi_nmap --cursor 2            # steady block in normal
        # Re-bind suggestion accepts in vi_imap — the core C-y/Tab binds only
        # apply to the default (emacs) keymap, and vi_imap has its own C-y
        # (yank from line above) that would shadow them.
        ble-bind -m vi_imap -f C-y accept-suggestion
        ble-bind -m vi_imap -f Tab accept-word-or-complete
        # Shift+Tab: force normal completion menu (overrides the default
        # 'vi_imap/menu-complete backward'); vi_imap/complete is the vi-mode
        # wrapper around ble/widget/complete that keeps undo/repeat intact.
        ble-bind -m vi_imap -f S-TAB 'vi_imap/complete show_menu'
        # Menu keys in vi insert mode. ac-menu-nav / ac-complete route through
        # vi_imap/complete (checked at call time) for undo/repeat intactness.
        ble-bind -m vi_imap -f C-e complete-toggle-menu
        ble-bind -m vi_imap -f C-n ac-menu-nav
        ble-bind -m vi_imap -f C-p 'ac-menu-nav backward'
        # Always start in insert mode (like zsh-vi-mode)
        ble/widget/vi_nmap/.insert-mode

        # bash-completion + fzf bridges from contrib
        local contrib="$HOME/.local/share/blesh/contrib/integration"
        [[ -f $contrib/bash-completion.bash ]] && source "$contrib/bash-completion.bash"
        if command -v fzf >/dev/null 2>&1 && [[ -f $contrib/fzf-key-bindings.bash ]]; then
          source "$contrib/fzf-key-bindings.bash"
        fi
      }
      blehook/eval-after-load keymap_vi _blesh_post_load

      # --noattach requires an explicit attach (ble.sh >= 0.4 no longer
      # auto-installs a PROMPT_COMMAND attach for --noattach). This also
      # triggers the keymap_vi load, which fires _blesh_post_load above.
      ble-attach

      [[ -n "${SHELL_DEBUG:-}" ]] && \
        echo "[DEBUG] 30_tools/06_blesh.sh - ble.sh $BLE_VERSION active"
    elif [[ -n "${SHELL_DEBUG:-}" ]]; then
      echo "[DEBUG] 30_tools/06_blesh.sh - ble.sh skipped (non-interactive context)"
    fi
  fi
fi
