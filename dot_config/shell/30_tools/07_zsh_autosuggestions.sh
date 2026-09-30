#!/usr/bin/env zsh
# =============================================================================
# ZSH-AUTOSUGGESTIONS INITIALIZATION (zsh-only)
# =============================================================================
# Fish-style ghost text autosuggestions for zsh.
# https://github.com/zsh-users/zsh-autosuggestions
#
# Install: pacman (zsh-autosuggestions) or git clone into
# ~/.local/share/zsh-autosuggestions
#
# Keybindings mirror 06_blesh.sh (ble.sh auto-complete accepts):
#   -> / End / vi-mode equivalents = accept whole suggestion
#   M-f / forward-word widgets     = partial accept (next word)
#   C-y                            = accept whole suggestion
#   Tab                            = accept next word, else normal completion
#
# Must run AFTER 05_zsh_vi_mode.sh (if installed, it re-binds keys on init).
# The plugin re-wraps widgets on every precmd, so late changes to the widget
# lists still take effect.
#
# IMPORTANT: zsh-vi-mode defers its real init to the FIRST PROMPT (it appends
# zvm_init to precmd_functions when ZVM_INIT_MODE != sourcing), where it runs
# `bindkey -v` and its own `zvm_bindkey viins ...` defaults — wiping any
# bindkey set at source time (at source time they appear to work; the first
# prompt silently replaces them). All keybinding calls in this file therefore
# run from `zvm_after_init` (executed by zvm_init AFTER its own binds) when
# zsh-vi-mode is active, and immediately otherwise.
# =============================================================================

if [[ "$CURRENT_SHELL" != "zsh" ]]; then
    [[ -n "$SHELL_DEBUG" ]] && echo "[DEBUG] 07_zsh_autosuggestions.sh skipped - not zsh"
    return
fi

# ---------------------------------------------------------------------------
# Locate plugin: pacman path first, git-clone fallback second
# ---------------------------------------------------------------------------
typeset _zsh_as_plugin=""
for _zsh_as_plugin in \
    /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
    "$HOME/.local/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
do
    [[ -f "$_zsh_as_plugin" ]] && break
    _zsh_as_plugin=""
done

if [[ -z "$_zsh_as_plugin" ]]; then
    [[ -n "$SHELL_DEBUG" ]] && echo "[WARN] 07_zsh_autosuggestions.sh - plugin not found"
    return
fi

# ---------------------------------------------------------------------------
# Configuration (must be set BEFORE sourcing the plugin)
# ---------------------------------------------------------------------------
# Strategy order is first-match. 08_atuin.sh prepends atuin's strategy at
# runtime, so the effective order is: atuin -> history -> match_prev_cmd.
# The plugin's `completion` strategy is intentionally NOT used: it runs the
# completion system in a zpty worker per fetch (78-98 ms), and that worker
# crashes zsh 5.9.2 (SIGFPE, division-by-zero in printfmt() when the pty has
# 0 columns). Command-semantic completion is covered by the C-e/Shift-Tab
# menu (carapace-backed) below, which runs on the foreground shell.
ZSH_AUTOSUGGEST_STRATEGY=(history match_prev_cmd)

# Explicit accept lists (includes plugin defaults + both keymaps), so
# suggestions behave identically in insert and normal vi mode.
typeset -ga ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(
    forward-char
    end-of-line
    vi-forward-char
    vi-end-of-line
    vi-add-eol
    vi-add-next
)
typeset -ga ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(
    forward-word
    emacs-forward-word
    vi-forward-word
    vi-forward-word-end
    vi-forward-blank-word
    vi-forward-blank-word-end
    vi-find-next-char
    vi-find-next-char-skip
)

# Tab: accept the next section of the suggestion — fish-style: leading
# whitespace + one word, or one path component INCLUDING its trailing '/'
# per press ("ools ~/.config/" from "ools ~/.config/shell/25_completions").
# This widget is NOT run through the plugin's partial-accept wrapper (it is
# in ZSH_AUTOSUGGEST_IGNORE_WIDGETS below): zle defers the zle-line-pre-redraw
# hook — the plugin's fetch point — while input is pending, and herdr remote
# bridges deliver keystrokes as coalesced bursts, so Tab can land with
# POSTDISPLAY empty (fetch never ran for the burst's tail) or stale/misaligned
# (leading-space ghost behind a buffer that already ends with a space; the
# wrapper would pre-fold that ghost into BUFFER and produce double spaces).
# Instead the widget sees the unfolded BUFFER/POSTDISPLAY, synchronously
# refetches when POSTDISPLAY is empty or leading-space-misaligned (atuin
# strategy: ~8-15 ms; the plugin's default suggest then sets POSTDISPLAY
# from the response — stale/misaligned async arrivals can still append the
# full stale command, accepted per user decision in exchange for ghost
# text that actually shows while typing), and accepts directly from
# POSTDISPLAY. Fallback contract is unchanged: with nothing to accept, run
# normal Tab completion (expand-or-complete).
function _autosuggest_accept_next_word() {
    # Refetch when POSTDISPLAY is unusable: empty (fetch skipped by coalesced
    # input) or starting with whitespace while BUFFER already ends with one
    # (stale leading-space case).
    if [[ -z "$POSTDISPLAY" || ( -n "$POSTDISPLAY" && "$POSTDISPLAY" == ' '* && "$BUFFER" == *' ' ) ]]; then
        if (( ${+functions[_zsh_autosuggest_fetch_suggestion]} )); then
            _zsh_autosuggest_fetch_suggestion "$BUFFER"
            if (( ${+widgets[autosuggest-suggest]} )); then
                # Plugin wrapper widget: runs the plugin's suggest (sets
                # POSTDISPLAY) plus highlight reset/apply and zle -R (keeps
                # the ghost styled).
                zle autosuggest-suggest -- "$suggestion"
            elif (( ${+functions[_zsh_autosuggest_suggest]} )); then
                # Plugin's own suggest: POSTDISPLAY="${suggestion#$BUFFER}".
                _zsh_autosuggest_suggest "$suggestion"
            else
                [[ -n "$suggestion" ]] && POSTDISPLAY="${suggestion#$BUFFER}"
            fi
        fi
    fi
    # Accept directly from POSTDISPLAY (no folding): cursor sits at the end
    # of BUFFER, POSTDISPLAY is the authoritative ghost remainder.
    if [[ -n "$POSTDISPLAY" ]] && (( CURSOR == $#BUFFER )); then
        local pd="$POSTDISPLAY"
        # Leading whitespace belongs to the next section (fish accepts " word");
        # if it were cut off, the case would collapse to empty and wrongly fall
        # back to the completion menu ("first Tab does nothing" bug).
        local lead=${pd%%[![:space:]]*}
        local word=${pd:$#lead}
        word=${word%%[[:space:]]*}
        local -i n=$(( $#lead + $#word ))
        if (( n > 0 )); then
            local tail=${word:1}
            if [[ $tail == */* ]]; then
                # One path section per press: stop after the first '/' that
                # has content before it ("agents/" per press, not
                # "agents/interagent-collab").
                n=$(( $#lead + ${#tail%%/*} + 2 ))
            fi
            BUFFER="${BUFFER}${pd[1,n]}"
            CURSOR=$#BUFFER
            POSTDISPLAY="${pd:$n}"
            return
        fi
    fi
    zle expand-or-complete
}
zle -N autosuggest-accept-next-word _autosuggest_accept_next_word

# complist must be loaded before the menuselect binds below (and before the
# fallback direct call of _zsh_as_apply_keybindings).
zmodload zsh/complist 2>/dev/null

# ---------------------------------------------------------------------------
# Menu-accept ghost fix (zsh-users/zsh-autosuggestions #649 / #747 class)
# ---------------------------------------------------------------------------
# Symptom: opening the completion menu (C-e / C-n / C-p / Shift-Tab / Tab
# fallback) while a ghost suggestion is rendered, then accepting an item with
# ^I/^Y/Enter, leaves stale ghost text on the line and/or re-renders a freshly
# fetched suggestion below it — the line "doubles" on screen (the command
# buffer itself is never corrupted; POSTDISPLAY is not part of BUFFER and is
# never executed).
#
# Why the clear widget list alone is NOT sufficient (#747): the plugin's
# default ZSH_AUTOSUGGEST_CLEAR_WIDGETS ALREADY contains `accept-line`, and
# its `clear` wrapper only does POSTDISPLAY= before calling the original
# widget — yet the doubling still happens, because inside the menuselect
# session complist redraws while the ghost (and its region_highlight entry)
# is still on the line, and widgets wrapped as `modify` restore/refetch
# POSTDISPLAY when the buffer changes (e.g. the accepted match being
# inserted). Upstream fix pattern (#747): wrap the menu-accept widget so the
# ghost is explicitly cleared — POSTDISPLAY *and* its highlight entry —
# before and after the accept, then force a redraw.
#
# This widget MUST go into ZSH_AUTOSUGGEST_IGNORE_WIDGETS (below, after
# source): an unlisted user widget gets wrapped as `modify` on the next
# precmd, and the modify wrapper re-fetches a suggestion for the new buffer
# after the accept and re-renders the ghost right back (#649). Ignoring it
# leaves it unwrapped, so nothing re-adds the ghost around the accept.
# Menu-phase navigation is already safe without further IGNORE entries:
# up/down-line-or-history are in the plugin's default clear list, and
# backward-char/forward-char's modify wrapper restores the pre-menu
# (empty) POSTDISPLAY — no ghost is re-rendered during navigation.
function _zsh_as_menu_accept() {
    # Drop the ghost and its highlight entry before complist redraws.
    POSTDISPLAY=
    region_highlight=("${(@)region_highlight:#*"$ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE"}")
    # Same accept-line the keys were bound to: inside menuselect it accepts
    # the highlighted item and returns to the line WITHOUT executing; the
    # plugin's clear wrapper around it is idempotent (POSTDISPLAY already
    # empty), so chaining through it is safe.
    zle accept-line
    # The accept inserted the highlighted match into BUFFER; kill any ghost
    # the accept path refetched (#649) and redraw so only the accepted
    # buffer is on screen.
    POSTDISPLAY=
    region_highlight=("${(@)region_highlight:#*"$ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE"}")
    zle -R
}
zle -N autosuggest-menu-accept _zsh_as_menu_accept

# Status: the menuselect accept keys (^Y/^M/^J) now bind the special
# accept-line widget directly (see the bind block below), so this wrapper is
# no longer reachable from the menu — complist runs accept-line itself and
# ignores user widgets in menuselect. It stays defined and ignore-listed so a
# future re-bind keeps the ghost-strip behavior, and the doubling it guarded
# against cannot recur via accept-line: every menu-open path is in the plugin's
# clear list, so POSTDISPLAY is already empty during menu selection and nothing
# refetches until the next keystroke (the toggle wrappers below then refetch
# with an alignment check on exit).

# ---------------------------------------------------------------------------
# Menu toggle with ghost refetch (C-e/C-n open; close side lives in menuselect)
# ---------------------------------------------------------------------------
# complist runs menu selection synchronously inside the widget that started
# it, so a wrapper around menu-expand-or-complete / reverse-menu-complete
# regains control when menu selection exits — however it exits: send-break
# close (^E), accept (^Y/^M/^J), or a single-match completion. That exit
# point is the only place custom code can run after a send-break close:
# complist special-cases send-break/accept-line/movement widgets by widget
# name and runs them itself, while a user-defined widget bound in the
# menuselect keymap is IGNORED entirely (verified on zsh 5.9.2 — the key
# becomes undefined), so a "close" widget bound there can never fire.
#
# The refetch uses a one-shot local alignment check (NOT the removed global
# stale-ghost guard): fetch synchronously (atuin: ~8-15 ms), then show the
# ghost only when the suggestion still prefix-matches BUFFER.
function _zsh_as_menu_refetch() {
    (( $#BUFFER )) || return 0
    (( ${+functions[_zsh_autosuggest_fetch_suggestion]} )) || return 0
    local suggestion
    _zsh_autosuggest_fetch_suggestion "$BUFFER"
    if [[ "$suggestion" == "$BUFFER"* && "$suggestion" != "$BUFFER" ]]; then
        if (( ${+widgets[autosuggest-suggest]} )); then
            # Plugin wrapper widget: runs the plugin's suggest (sets
            # POSTDISPLAY) plus highlight reset/apply and zle -R.
            zle autosuggest-suggest -- "$suggestion"
        else
            POSTDISPLAY="${suggestion#$BUFFER}"
        fi
    else
        POSTDISPLAY=
    fi
}
function _zsh_as_menu_toggle() {
    zle menu-expand-or-complete
    _zsh_as_menu_refetch
}
function _zsh_as_menu_toggle_back() {
    zle reverse-menu-complete
    _zsh_as_menu_refetch
}
zle -N autosuggest-menu-toggle _zsh_as_menu_toggle
zle -N autosuggest-menu-toggle-back _zsh_as_menu_toggle_back

# ---------------------------------------------------------------------------
# Source the plugin
# ---------------------------------------------------------------------------
source "$_zsh_as_plugin"

# ---------------------------------------------------------------------------
# Keybindings — applied via apply_keybindings (see IMPORTANT note above)
# ---------------------------------------------------------------------------
function _zsh_as_apply_keybindings() {
    # C-y: accept whole suggestion (ble.sh: ble-bind -f C-y 'auto_complete/insert').
    # Bound in both vi keymaps (main keymap is viins via `bindkey -v` in .zshrc).
    bindkey -M viins '^Y' autosuggest-accept
    bindkey -M vicmd '^Y' autosuggest-accept

    # Tab in insert mode: partial accept / completion fallback.
    bindkey -M viins '^I' autosuggest-accept-next-word

    # Shift+Tab (backtab): force the normal completion menu (listed options) even
    # while a ghost suggestion is displayed. expand-or-complete IS wrapped by the
    # plugin now (added to ZSH_AUTOSUGGEST_CLEAR_WIDGETS below — the wrapper only
    # clears the ghost, never intercepts the menu). Not bound in vicmd (completion
    # menu from normal mode is unexpected).
    bindkey -M viins '\e[Z' expand-or-complete

    # viins: C-e/C-n open the menu through autosuggest-menu-toggle (wrapper
    # around menu-expand-or-complete; the C-e close side lives in menuselect
    # as send-break), C-p opens it on the last item via
    # autosuggest-menu-toggle-back (wrapper around reverse-menu-complete).
    # The wrappers regain control when menu selection exits — close via ^E,
    # accept via ^Y/^M/^J, or single-match completion — and synchronously
    # refetch the ghost: complist's send-break close itself does NOT
    # refetch, which used to leave POSTDISPLAY empty until the next
    # keystroke. The user navigates with vi `$`, so vicmd ^E (end-of-line)
    # stays untouched. The completion widgets (not the wrappers) jump
    # STRAIGHT into menu selection — plain expand-or-complete cycles through
    # zsh's stages (common prefix → "do you wish to see all N
    # possibilities?" list prompt → menu), which made C-e toggle through
    # junk states instead of menu on/off.
    bindkey -M viins '^E' autosuggest-menu-toggle
    bindkey -M viins '^N' autosuggest-menu-toggle
    bindkey -M viins '^P' autosuggest-menu-toggle-back

    # menuselect: all menu-open behavior. The bindings MUST stay on those
    # exact widget names — complist special-cases movement widgets
    # (down/up-line-or-history for ^N/^P, backward/forward-char for ^B/^F),
    # complete-word (^I: cycle to the NEXT item, wrapping at the list edges)
    # and accept-line (^Y/^M/^J: accept the highlighted match, return to the
    # line WITHOUT executing) and runs their menu semantics itself, no matter
    # what the widget name resolves to. Verified on zsh 5.9.2: a user-defined
    # widget bound in menuselect is IGNORED entirely (the key becomes
    # undefined), which is why the accept keys bind accept-line directly
    # instead of the autosuggest-menu-accept wrapper (kept defined +
    # ignore-listed above; its ghost-strip is unnecessary here because every
    # menu-open path is in the plugin's clear list, so POSTDISPLAY is already
    # empty during menu selection and nothing refetches until the next
    # keystroke — it also fixes a live bug: ^M/^J bound to a user widget
    # re-dispatched accept-line in viins AFTER complist accepted the match,
    # EXECUTING the line). send-break on ^E aborts the menu and restores the
    # line (toggle-off); the immediate ghost refetch after the close lives in
    # the autosuggest-menu-toggle widget that OPENED the menu (see above).
    bindkey -M menuselect '^E' send-break
    bindkey -M menuselect '^N' down-line-or-history
    bindkey -M menuselect '^P' up-line-or-history
    bindkey -M menuselect '^I' complete-word
    bindkey -M menuselect '^Y' accept-line
    bindkey -M menuselect '^M' accept-line
    bindkey -M menuselect '^J' accept-line
    bindkey -M menuselect '\e[Z' up-line-or-history
    bindkey -M menuselect '^B' backward-char
    bindkey -M menuselect '^F' forward-char
}

if (( ${+functions[zvm_after_init]} )); then
    # zsh-vi-mode active: hook the binds so they survive zvm_init's own
    # `bindkey -v` + default rebinds on the first prompt (see IMPORTANT note).
    # Chain: snapshot the existing zvm_after_init (05's fzf/zoxide/carapace
    # re-binds) and run it before ours, so our binds come last. The snapshot
    # guard also keeps a re-source of this file from chaining itself.
    if (( ! ${+functions[_zvm_after_init_prev]} )); then
        functions[_zvm_after_init_prev]=$functions[zvm_after_init]
    fi
    function zvm_after_init() {
        _zvm_after_init_prev
        _zsh_as_apply_keybindings
        [[ -n "$SHELL_DEBUG" ]] && echo "[DEBUG] 07: keybindings applied via zvm_after_init"
    }
else
    _zsh_as_apply_keybindings
fi

# The ghost must clear when the menu opens: the menu widgets are not in the
# plugin's default clear list, and it re-wraps widgets on every precmd, so
# appending here (after source) takes effect on the next precmd.
# menu-select / accept-and-menu-complete are not bound in this config but are
# the other menu-accept paths (#649); covering them is harmless (their clear
# wrapper only empties POSTDISPLAY before the original widget runs).
# autosuggest-menu-accept goes into IGNORE_WIDGETS instead of the clear list:
# the clear wrapper runs the original INSIDE the plugin's machinery, while
# the fix needs full control before AND after the accept — and an unlisted
# widget would otherwise be wrapped as modify, which re-fetches the ghost
# after the buffer changed (see the #649/#747 block above).
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(expand-or-complete reverse-menu-complete menu-expand-or-complete menu-select accept-and-menu-complete)
ZSH_AUTOSUGGEST_IGNORE_WIDGETS+=(autosuggest-menu-accept)
# autosuggest-accept-next-word is also IGNORED (never wrapped): the
# partial-accept wrapper would pre-fold a stale/empty POSTDISPLAY into
# BUFFER before the widget runs — see the Tab comment block above.
ZSH_AUTOSUGGEST_IGNORE_WIDGETS+=(autosuggest-accept-next-word)
# The menu toggle wrappers are IGNORED too: they must run exactly as written
# (open via the clear-wrapped completion widget, refetch on exit); a modify
# wrapper around them would refetch again after the refetch and re-fold
# POSTDISPLAY mid-toggle.
ZSH_AUTOSUGGEST_IGNORE_WIDGETS+=(autosuggest-menu-toggle autosuggest-menu-toggle-back)

# ---------------------------------------------------------------------------
# Completion menu (fish/blink-style) — C-e/C-n toggle, C-n/C-p item navigation
# ---------------------------------------------------------------------------
# zsh has no persistent menu-state API: the interactive menu exists only while
# zle runs the `menuselect` keymap (created by zsh/complist; requires menu
# select zstyle — set in 21_zsh_completions.sh). The conditional keymap layers
# give the fish/blink behavior emergently:
#
#   menu closed (viins)                menu open (menuselect)
#   C-e / C-n  autosuggest-menu-       ^E  send-break        (toggle off; ghost
#              toggle (opens menu          refetched on exit by the
#              directly, 1st item)         open-side wrapper)
#   C-p        autosuggest-menu-       ^N  down-line-or-history (next item)
#              toggle-back (opens      ^P  up-line-or-history   (prev item)
#              menu, last item)        ^Y/^M/^J accept-line  (accept item,
#   Enter      accept-line (execute)       returns to line, NO execute;
#              via default ^M/^J,          complist runs it itself, no
#              outside menu selection)     widget, no refetch — menu-open
#   Tab        autosuggest-accept-         paths are all clear-listed)
#              next-word (existing)    ^I  complete-word        (cycle to NEXT
#   C-y        autosuggest-accept          item, wraps at list edges)
#              (existing, unchanged)   ^B/^F backward-char/forward-char (no
#                                              page scroll in zsh menus)
#
# Limitations vs ble.sh: no auto-popup (menu opens only via C-e/C-n/C-p/S-TAB),
# no description pane, no page scrolling, and huge candidate lists first show
# zsh's "do you wish to see all N possibilities?" prompt.
# (All bindkey calls live in _zsh_as_apply_keybindings above, applied via
# zvm_after_init when zsh-vi-mode is active — see the IMPORTANT note at top.)

unset _zsh_as_plugin

[[ -n "$SHELL_DEBUG" ]] && echo "[DEBUG] 07_zsh_autosuggestions.sh loaded - zsh-autosuggestions active"
