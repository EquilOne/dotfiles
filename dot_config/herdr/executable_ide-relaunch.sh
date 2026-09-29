#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:/home/linuxbrew/.linuxbrew/bin:/usr/local/bin:/usr/bin:/bin${PATH:+:$PATH}"
if ! command -v herdr >/dev/null 2>&1; then
  echo "ide-relaunch: herdr not found in PATH — install herdr or add its bin dir to PATH" >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "ide-relaunch: jq not found in PATH" >&2
  exit 1
fi

SESSION=ide
SOCK_DIR="${HERDR_CONFIG_PATH:-$HOME/.config/herdr}/sessions/$SESSION"
SOCK="$SOCK_DIR/herdr.sock"
LAYOUT="$HOME/.config/herdr/ide-layout.json"

if [[ ! -S "$SOCK" ]]; then
  echo "ide-relaunch: no server socket at $SOCK — launch the IDE first" >&2
  exit 1
fi

H=herdr

focused_ws=$( \
  $H --session "$SESSION" workspace list 2>/dev/null | \
  jq -r '.result.workspaces[]? | select(.focused == true) | .workspace_id' \
)
if [[ -z "$focused_ws" ]]; then
  echo "ide-relaunch: no focused workspace in session '$SESSION'" >&2
  exit 1
fi

pane_out=$($H --session "$SESSION" pane list 2>/dev/null)

resolve_from() {
  printf '%s' "$1" | jq -r \
    --arg ws "$focused_ws" --arg label "$2" \
    '[.result.panes[]? | select(.workspace_id == $ws and .label == $label)][0].pane_id // empty'
}

resolve_pane() {
  resolve_from "$pane_out" "$1"
}

is_running() {
  local pane=$1 app=$2
  $H --session "$SESSION" pane process-info --pane "$pane" 2>/dev/null | \
    jq -e --arg app "$app" \
    '.result.process_info.foreground_processes[]? | (.name | ascii_downcase) == $app' >/dev/null 2>&1
}

run_in_pane() {
  $H --session "$SESSION" pane run "$1" "$2" >/dev/null 2>&1 || true
}

editor_pane=$(resolve_pane editor)
shell_pane=$(resolve_pane shell)
opencode_pane=$(resolve_pane opencode)

used_relayout=0
recreated=0

# Panes moved into other tabs (pane-move feature) cannot be recombined into
# one tab surgically — go straight to relayout.
ntabs=$(printf '%s' "$pane_out" | jq -r --arg ws "$focused_ws" \
  '[.result.panes[]?
    | select(.workspace_id == $ws)
    | select(.label == "editor" or .label == "shell" or .label == "opencode")
    | .tab_id] | unique | length')
if [[ "$ntabs" -gt 1 ]]; then
  used_relayout=1
fi

# Canonical fractions come from the layout template, not hardcoded.
ratio_right=$(jq -r '.root.ratio // 0.68' "$LAYOUT")
ratio_left=$(jq -r '.root.first.ratio // 0.75' "$LAYOUT")

# Canonical geometry check: after any recreation, the focused tab must match
# ide-layout.json (left column 68% width: editor 75% height top / shell 25%
# bottom; opencode right 32% full height). Tolerance in cells for rounding.
geometry_ok() {
  local list e s o tab_e tab_s tab_o edges
  list=$($H --session "$SESSION" pane list 2>/dev/null)
  e=$(resolve_from "$list" editor)
  s=$(resolve_from "$list" shell)
  o=$(resolve_from "$list" opencode)
  [[ -n "$e" && -n "$s" && -n "$o" ]] || return 1
  tab_e=$(printf '%s' "$list" | jq -r --arg p "$e" '[.result.panes[]? | select(.pane_id == $p)][0].tab_id // empty')
  tab_s=$(printf '%s' "$list" | jq -r --arg p "$s" '[.result.panes[]? | select(.pane_id == $p)][0].tab_id // empty')
  tab_o=$(printf '%s' "$list" | jq -r --arg p "$o" '[.result.panes[]? | select(.pane_id == $p)][0].tab_id // empty')
  [[ "$tab_e" == "$tab_s" && "$tab_s" == "$tab_o" ]] || return 1
  edges=$($H --session "$SESSION" pane edges --pane "$e" 2>/dev/null)
  printf '%s' "$edges" | jq -e --arg e "$e" --arg s "$s" --arg o "$o" \
    --argjson rw "$ratio_right" --argjson rh "$ratio_left" '
    def near(a; b; t): ((a - b) * (if a > b then 1 else -1 end)) <= t;
    .result.edges.layout.area as $a
    | .result.edges.layout.panes as $p
    | ($p[] | select(.pane_id == $e) | .rect) as $er
    | ($p[] | select(.pane_id == $s) | .rect) as $sr
    | ($p[] | select(.pane_id == $o) | .rect) as $or
    | near($er.x; 0; 2) and near($er.y; 0; 2)
      and near($er.width; $a.width * $rw; 3)
      and near($er.height; $a.height * $rh; 3)
      and near($sr.x; 0; 2) and near($sr.y; $a.height * $rh; 3)
      and near($sr.width; $a.width * $rw; 3)
      and near($sr.height; $a.height * (1 - $rh); 3)
      and near($or.x; $a.width * $rw; 3) and near($or.y; 0; 2)
      and near($or.width; $a.width * (1 - $rw); 3)
      and near($or.height; $a.height; 2)' >/dev/null 2>&1
}

# cwd for any recreated pane: take it from a surviving sibling pane, else $HOME.
ws_cwd=$HOME
for p in "$editor_pane" "$shell_pane" "$opencode_pane"; do
  if [[ -n "$p" ]]; then
    found=$(printf '%s' "$pane_out" | jq -r --arg p "$p" \
      '[.result.panes[]? | select(.pane_id == $p)][0].cwd // empty')
    if [[ -n "$found" && "$found" != "null" ]]; then
      ws_cwd=$found
      break
    fi
  fi
done

send_json() {
  local line=$1
  if command -v nc >/dev/null 2>&1; then
    printf '%s\n' "$line" | timeout 10 nc -U "$SOCK"
  elif command -v socat >/dev/null 2>&1; then
    printf '%s\n' "$line" | timeout 10 socat - "UNIX-CONNECT:$SOCK"
  fi
}

# layout.apply has no merge flag, so it replaces the whole tab tree and
# restarts live panes. Last resort only.
full_relayout() {
  local tab_id
  tab_id=$(printf '%s' "$pane_out" | jq -r --arg ws "$focused_ws" \
    '[.result.panes[]? | select(.workspace_id == $ws)][0].tab_id // empty')
  local params
  params=$(jq -c \
    --arg wid "$focused_ws" \
    --arg tid "$tab_id" \
    --arg cwd "$ws_cwd" \
    'if $tid != "" then del(.workspace_id) | .tab_id = $tid
     else .workspace_id = $wid end
     | (.root |= walk(if type == "object" and has("type") and .type == "pane" then .cwd = $cwd else . end))' \
    "$LAYOUT")
  local resp
  resp=$(send_json "$(jq -cn --argjson params "$params" '{id: "ide-relaunch-layout", method: "layout.apply", params: $params}')")
  printf '%s' "$resp" | jq -e '.result.type == "layout_apply"' >/dev/null 2>&1
}

# Split semantics (verified live): --direction only supports right/down, the
# ratio is the EXISTING pane's fraction, and new panes auto-start the user's
# default interactive shell. Splitting a leaf replaces it with a split node
# spanning the leaf's rect, so siblings always match the split pane's other
# dimension — recreate the full-height right column before narrowing the
# left column.
split_pane() {
  local pane=$1 dir=$2 ratio=$3
  $H --session "$SESSION" pane split "$pane" --direction "$dir" --ratio "$ratio" --no-focus --cwd "$ws_cwd" 2>/dev/null | \
    jq -r '.result.pane.pane_id // empty'
}

swap_panes() {
  $H --session "$SESSION" pane swap --source-pane "$1" --target-pane "$2" >/dev/null 2>&1 || true
}

rename_pane() {
  $H --session "$SESSION" pane rename "$1" "$2" >/dev/null 2>&1 || true
}

# Guards first: surviving panes get their app relaunched if it exited.
if [[ -n "$editor_pane" ]] && ! is_running "$editor_pane" nvim; then
  run_in_pane "$editor_pane" 'sh -lc nvim'
fi
if [[ -n "$opencode_pane" ]] && ! is_running "$opencode_pane" opencode; then
  run_in_pane "$opencode_pane" 'sh -lc opencode'
fi

used_relayout=0

# Skip surgery entirely when the cross-tab pre-check already forced relayout.
if [[ "$used_relayout" == 0 ]]; then

if [[ -z "$editor_pane" && -z "$shell_pane" ]]; then
  # Left column gone. If opencode survives, rebuild the left column
  # surgically without touching it: split opencode right, swap so the new
  # pane takes the full-height left column, then split it down into
  # editor/shell. Splitting a 75%-height pane would cap opencode's height,
  # so this must happen while opencode spans the full tab.
  if [[ -n "$opencode_pane" ]]; then
    tmp=$(split_pane "$opencode_pane" right 0.68)
    if [[ -n "$tmp" ]]; then
      swap_panes "$tmp" "$opencode_pane"
      rename_pane "$tmp" editor
      editor_pane=$tmp
      new_shell=$(split_pane "$tmp" down 0.75)
      rename_pane "$new_shell" shell
      shell_pane=$new_shell
      run_in_pane "$tmp" 'sh -lc nvim'
      recreated=1
    else
      used_relayout=1
    fi
  else
    used_relayout=1
  fi
elif [[ -z "$editor_pane" ]]; then
  # Shell survives. Recreate opencode first if it is missing too — the
  # split-right anchor must be a full-height pane, and the editor recreation
  # below consumes the shell's full height.
  if [[ -z "$opencode_pane" ]]; then
    tmp=$(split_pane "$shell_pane" right 0.68)
    rename_pane "$tmp" opencode
    opencode_pane=$tmp
    run_in_pane "$tmp" 'sh -lc opencode'
    recreated=1
  fi
  # Recreate editor on top of the shell: split down 0.75 (shell keeps the
  # top 75%), swap so the new pane is the top editor and shell sits at 25%.
  new_editor=$(split_pane "$shell_pane" down 0.75)
  swap_panes "$new_editor" "$shell_pane"
  rename_pane "$new_editor" editor
  editor_pane=$new_editor
  run_in_pane "$new_editor" 'sh -lc nvim'
  recreated=1
elif [[ -z "$shell_pane" ]]; then
  # Editor survives. Recreate opencode first while the editor spans the
  # full tab (full-height right column), then split the editor down for the
  # shell (editor keeps 75% top, new shell 25% bottom).
  if [[ -z "$opencode_pane" ]]; then
    tmp=$(split_pane "$editor_pane" right 0.68)
    rename_pane "$tmp" opencode
    opencode_pane=$tmp
    run_in_pane "$tmp" 'sh -lc opencode'
    recreated=1
  fi
  new_shell=$(split_pane "$editor_pane" down 0.75)
  rename_pane "$new_shell" shell
  shell_pane=$new_shell
  recreated=1
elif [[ -z "$opencode_pane" ]]; then
  # Editor and shell survive, opencode missing. Splitting the 75%-height
  # editor right yields a top-right opencode capped at 75% height (the
  # bottom-left shell is wider); the CLI cannot build a full-height right
  # column here without restarting live panes, so this is verified below
  # and falls back to full_relayout when it is not canonical.
  tmp=$(split_pane "$editor_pane" right 0.68)
  rename_pane "$tmp" opencode
  opencode_pane=$tmp
  run_in_pane "$tmp" 'sh -lc opencode'
  recreated=1
fi # end case tree
fi # end skip-surgery wrapper

# Verify-then-fix: any surgical recreation must end in canonical geometry.
# On mismatch (e.g. a non-canonical tab tree from earlier pane moves), the
# layout is rebuilt from the template — this restarts live nvim/opencode
# panes and is the accepted fallback when surgery cannot produce the
# canonical layout.
if [[ "$recreated" == 1 ]] && ! geometry_ok; then
  used_relayout=1
fi

if [[ "$used_relayout" == 1 ]]; then
  if full_relayout; then
    exit 0
  fi
  echo "ide-relaunch: no IDE panes left to anchor on and layout.apply failed" >&2
  exit 1
fi