#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:/home/linuxbrew/.linuxbrew/bin:/usr/local/bin:/usr/bin:/bin${PATH:+:$PATH}"
if ! command -v herdr >/dev/null 2>&1; then
  echo "ide-pane-move: herdr not found in PATH — install herdr or add its bin dir to PATH" >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "ide-pane-move: jq not found in PATH" >&2
  exit 1
fi

SESSION=ide
SOCK_DIR="${HERDR_CONFIG_PATH:-$HOME/.config/herdr}/sessions/$SESSION"
SOCK="$SOCK_DIR/herdr.sock"

if [[ ! -S "$SOCK" ]]; then
  echo "ide-pane-move: no server socket at $SOCK — launch the IDE first" >&2
  exit 1
fi

H=herdr
MODE=new-tab
PANE_OVERRIDE=""

usage() {
  echo "usage: ide-pane-move.sh [--new-tab | --next | --prev] [--pane PANE_ID]" >&2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --new-tab) MODE=new-tab ;;
    --next) MODE=next ;;
    --prev) MODE=prev ;;
    --pane) PANE_OVERRIDE=${2:-}; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ide-pane-move: unknown argument '$1'" >&2; usage; exit 1 ;;
  esac
  shift
done

pane_out=$($H --session "$SESSION" pane list 2>/dev/null)

if [[ -n "$PANE_OVERRIDE" ]]; then
  PANE_ID=$PANE_OVERRIDE
else
  PANE_ID=$(printf '%s' "$pane_out" | jq -r '[.result.panes[]? | select(.focused == true)][0].pane_id // empty')
fi
if [[ -z "$PANE_ID" ]]; then
  echo "ide-pane-move: no focused pane found" >&2
  exit 1
fi

cur=$(printf '%s' "$pane_out" | jq -r --arg p "$PANE_ID" \
  '[.result.panes[]? | select(.pane_id == $p)][0] // empty')
if [[ -z "$cur" ]]; then
  echo "ide-pane-move: pane '$PANE_ID' not found in session '$SESSION'" >&2
  exit 1
fi
cur_tab=$(printf '%s' "$cur" | jq -r '.tab_id')
ws_id=$(printf '%s' "$cur" | jq -r '.workspace_id')

# Native behavior notes:
# - --new-tab: pane keeps its identity (process + scrollback); a new tab is
#   created and the emptied source tab is auto-closed by the server. Moving
#   the only pane of a tab therefore relocates that tab's sole pane to a new
#   tab slot — no manual cleanup needed.
# - --tab requires a split direction: the pane is inserted as a split in the
#   target tab (this is the only existing-tab destination the CLI offers).
move_result() {
  local pane=$1 dest=$2
  case "$dest" in
    new-tab)
      $H --session "$SESSION" pane move "$pane" --new-tab --focus 2>&1
      ;;
    tab:*)
      $H --session "$SESSION" pane move "$pane" --tab "${dest#tab:}" --split right --focus 2>&1
      ;;
  esac
}

if [[ "$MODE" == "new-tab" ]]; then
  out=$(move_result "$PANE_ID" new-tab) || {
    echo "ide-pane-move: pane move failed: $out" >&2
    exit 1
  }
  printf '%s' "$out" | jq -e '.result.move_result.changed == true' >/dev/null 2>&1 || {
    echo "ide-pane-move: pane move did not apply: $out" >&2
    exit 1
  }
  exit 0
fi

# next / prev: pick the neighboring tab (by tab number) in the same workspace.
tab_list=$($H --session "$SESSION" tab list --workspace "$ws_id" 2>/dev/null)
target=$(printf '%s' "$tab_list" | jq -r \
  --arg tab "$cur_tab" --arg mode "$MODE" \
  '.result.tabs
   | sort_by(.number)
   | to_entries
   | (map(select(.value.tab_id == $tab)) | .[0].key) as $i
   | if $i == null then empty
     elif $mode == "next" then (.[($i + 1)].value.tab_id // empty)
     elif $i == 0 then empty
     else .[($i - 1)].value.tab_id // empty end')

if [[ -z "$target" ]]; then
  if [[ "$MODE" == "next" ]]; then
    echo "ide-pane-move: no tab after the current one — nothing to move into" >&2
  else
    echo "ide-pane-move: no tab before the current one — nothing to move into" >&2
  fi
  exit 0
fi

out=$(move_result "$PANE_ID" "tab:$target") || {
  echo "ide-pane-move: pane move failed: $out" >&2
  exit 1
}
printf '%s' "$out" | jq -e '.result.move_result.changed == true' >/dev/null 2>&1 || {
  echo "ide-pane-move: pane move did not apply: $out" >&2
  exit 1
}