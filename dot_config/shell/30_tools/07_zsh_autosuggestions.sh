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
    autosuggest-accept-next-word
)

# Tab: accept the next section of the suggestion — fish-style: leading
# whitespace + one word, or one path component INCLUDING its trailing '/'
# per press ("ools ~/.config/" from "ools ~/.config/shell/25_completions").
# NOTE: zsh-autosuggestions' partial-accept wrapper folds the ghost into
# BUFFER before this widget runs (POSTDISPLAY is still set, and original
# buffer end = $#BUFFER - $#POSTDISPLAY), so we slice the folded BUFFER and
# advance CURSOR directly instead of using forward-word, whose boundaries
# stop at hyphens/dots (one tiny fragment per press). The wrapper clips
# BUFFER at the new cursor position and re-fetches the ghost.
# CRITICAL: the remainder after an accepted section usually STARTS WITH A
# SPACE — if the slice were cut at the first whitespace, that case would
# collapse to empty and wrongly fall back to completion (menu), which caused
# the "first Tab does nothing / Tab cycles the menu" bug. Leading whitespace
# is therefore part of the next section and accepted with it.
# With no suggestion showing, fall back to normal Tab completion.
function _autosuggest_accept_next_word() {
    if [[ -n "$POSTDISPLAY" ]] && (( CURSOR >= $#BUFFER - $#POSTDISPLAY )); then
        local rest=${BUFFER:$CURSOR}
        # Leading whitespace belongs to the next section (fish accepts " word").
        local lead=${rest%%[![:space:]]*}
        local word=${rest:$#lead}
        word=${word%%[[:space:]]*}
        local -i n=$(( $#lead + $#word ))
        if (( n > 0 )); then
            local tail=${word:1}
            if [[ $tail == */* ]]; then
                # One path section per press: stop after the first '/' that
                # has content before it ("tmp" from "tmp/sddm-auth-…" →
                # accept "tmp/").
                n=$(( $#lead + ${#tail%%/*} + 2 ))
            fi
            (( CURSOR += n ))
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

# ---------------------------------------------------------------------------
# Source the plugin
# ---------------------------------------------------------------------------
source "$_zsh_as_plugin"

# ---------------------------------------------------------------------------
# Stale-ghost guard: hardened _zsh_autosuggest_suggest
# ---------------------------------------------------------------------------
# Override of the plugin's _zsh_autosuggest_suggest, which does
# POSTDISPLAY="${suggestion#$BUFFER}" — but in zsh ${var#pattern} returns the
# WHOLE string when the pattern doesn't match the string's beginning, so an
# async response arriving after the buffer changed (typing ahead, Tab fold;
# atuin's subprocess-per-keystroke strategy widens this window) appends the
# FULL stale command — which starts with the same alias, rendering a doubled
# line ("gs    gs agents/…"). The plugin's fetch_suggestion guards against the
# REQUEST buffer inside the forked child, but nothing re-checks at response
# time. Here: only set POSTDISPLAY when the suggestion still starts with the
# current BUFFER; otherwise clear it. Safe because every non-race flow yields
# a suggestion aligned with BUFFER (fetch_suggestion enforces it against the
# request buffer), so the mismatch branch fires only on stale/misaligned
# arrivals — those show no ghost, and the next keystroke's fetch refreshes it.
_zsh_autosuggest_suggest() {
	emulate -L zsh

	local suggestion="$1"

	if [[ -n "$suggestion" ]] && (( $#BUFFER )) && [[ "$suggestion" == "$BUFFER"* ]]; then
		POSTDISPLAY="${suggestion#$BUFFER}"
	else
		POSTDISPLAY=
	fi
}

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

    # viins: C-e opens the menu (toggle-on; the C-e close side lives in menuselect).
    # The user navigates with vi `$`, so vicmd ^E (end-of-line) stays untouched.
    # menu-expand-or-complete jumps STRAIGHT into menu selection — plain
    # expand-or-complete cycles through zsh's stages (common prefix → "do you
    # wish to see all N possibilities?" list prompt → menu), which made C-e
    # toggle through junk states instead of menu on/off.
    bindkey -M viins '^E' menu-expand-or-complete
    bindkey -M viins '^N' menu-expand-or-complete
    bindkey -M viins '^P' reverse-menu-complete

    # menuselect: all menu-open behavior. Defaults already give arrows (up/down =
    # up/down-line-or-history item nav); C-n/C-p match them per the keymap table.
    # Enter/C-y/Tab accept the highlighted item and return to the line without
    # executing (accept-line semantics inside menu selection) — via
    # autosuggest-menu-accept, which strips the ghost around the accept (see the
    # #649/#747 block above; accept-line alone is NOT enough, it is already in
    # the plugin's default clear list and the doubling still happens). ^M/^J
    # default to accept-line in menuselect (zsh/complist), so they get the same
    # wrapper — same accept semantics, only the ghost is cleared around it.
    # send-break aborts the menu and restores the line (toggle-off).
    # backward-char/forward-char keep ^B/^F from inserting junk; in zsh they
    # only move the cursor/selection.
    bindkey -M menuselect '^E' send-break
    bindkey -M menuselect '^N' down-line-or-history
    bindkey -M menuselect '^P' up-line-or-history
    bindkey -M menuselect '^Y' autosuggest-menu-accept
    bindkey -M menuselect '^I' autosuggest-menu-accept
    bindkey -M menuselect '^M' autosuggest-menu-accept
    bindkey -M menuselect '^J' autosuggest-menu-accept
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

# ---------------------------------------------------------------------------
# Completion menu (fish/blink-style) — C-e toggle, C-n/C-p item navigation
# ---------------------------------------------------------------------------
# zsh has no persistent menu-state API: the interactive menu exists only while
# zle runs the `menuselect` keymap (created by zsh/complist; requires menu
# select zstyle — set in 21_zsh_completions.sh). The conditional keymap layers
# give the fish/blink behavior emergently:
#
#   menu closed (viins)                menu open (menuselect)
#   C-e / C-n  menu-expand-or-         ^E  send-break        (toggle off)
#              complete (opens menu    ^N  down-line-or-history (next item)
#              directly, 1st item)
#   C-p        reverse-menu-complete   ^P  up-line-or-history   (prev item)
#              (opens menu, last item) ^M/^J menu-accept        (accept item,
#   Enter      menu-accept (execute)         returns to line, NO execute;
#              via default ^M/^J accept-     ghost cleared, #649/#747)
#              line semantics, wrapped
#   Tab        autosuggest-accept-     ^I  menu-accept          (accept item)
#              next-word (existing)    ^Y  menu-accept          (accept item)
#   C-y        autosuggest-accept      ^B/^F backward-char/forward-char (no
#              (existing, unchanged)         page scroll in zsh menus)
#
# Limitations vs ble.sh: no auto-popup (menu opens only via C-e/C-n/C-p/S-TAB),
# no description pane, no page scrolling, and huge candidate lists first show
# zsh's "do you wish to see all N possibilities?" prompt.
# (All bindkey calls live in _zsh_as_apply_keybindings above, applied via
# zvm_after_init when zsh-vi-mode is active — see the IMPORTANT note at top.)

unset _zsh_as_plugin

[[ -n "$SHELL_DEBUG" ]] && echo "[DEBUG] 07_zsh_autosuggestions.sh loaded - zsh-autosuggestions active"
