#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:/home/linuxbrew/.linuxbrew/bin:/usr/local/bin:/usr/bin:/bin${PATH:+:$PATH}"
if ! command -v herdr >/dev/null 2>&1; then
  echo "ide: herdr not found in PATH — install herdr or add its bin dir to PATH" >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "ide: jq not found in PATH" >&2
  exit 1
fi

SESSION=ide
SOCK_DIR="${HERDR_CONFIG_PATH:-$HOME/.config/herdr}/sessions/$SESSION"
SOCK="$SOCK_DIR/herdr.sock"
LAYOUT="$HOME/.config/herdr/ide-layout.json"

project_dir() {
  if [[ $# -ge 1 && -n "$1" ]]; then
    printf '%s' "$1"
  elif [[ "$PWD" != "$HOME" ]]; then
    printf '%s' "$PWD"
  elif [[ -d "$HOME/workspace" ]]; then
    printf '%s' "$HOME/workspace"
  else
    printf '%s' "$HOME"
  fi
}

DIR=$(project_dir "$@")
DIR=$(realpath -m "$DIR" 2>/dev/null || realpath "$DIR")

session_running() {
  herdr session list 2>/dev/null | awk -v s="$SESSION" '$1==s && $2=="running" {found=1} END {exit !found}'
}

if session_running; then
  exec herdr --session "$SESSION"
fi

herdr --session "$SESSION" server >/dev/null 2>&1 &
SRV_PID=$!
trap 'kill "$SRV_PID" 2>/dev/null || true' EXIT

for _ in $(seq 1 50); do
  if [[ -S "$SOCK" ]]; then break; fi
  sleep 0.2
done
if [[ ! -S "$SOCK" ]]; then
  echo "ide: server socket did not appear at $SOCK" >&2
  exit 1
fi

ws_out=$(herdr --session "$SESSION" workspace create --cwd "$DIR" --label ide --no-focus)
ws_id=$(printf '%s' "$ws_out" | jq -r '.result.workspace.workspace_id')
if [[ -z "$ws_id" || "$ws_id" == "null" ]]; then
  echo "ide: workspace create failed: $ws_out" >&2
  exit 1
fi

layout_params=$(jq -c \
  --arg wid "$ws_id" \
  --arg cwd "$DIR" \
  '.workspace_id = $wid | (.root |= walk(if type == "object" and has("type") and .type == "pane" then .cwd = $cwd else . end))' \
  "$LAYOUT")
request=$(jq -cn --argjson params "$layout_params" '{id: "ide-layout-apply", method: "layout.apply", params: $params}')

send_json() {
  local line=$1
  if command -v nc >/dev/null 2>&1; then
    printf '%s\n' "$line" | timeout 10 nc -U "$SOCK"
  elif command -v socat >/dev/null 2>&1; then
    printf '%s\n' "$line" | timeout 10 socat - "UNIX-CONNECT:$SOCK"
  fi
}

apply_layout() {
  local resp
  resp=$(send_json "$request")
  printf '%s' "$resp" | jq -e '.result.type == "layout_apply"' >/dev/null 2>&1
}

if ! apply_layout; then
  echo "ide: layout.apply failed, falling back to CLI splits" >&2
  root=$(printf '%s' "$ws_out" | jq -r '.result.root_pane.pane_id')
  shell=$(herdr --session "$SESSION" pane split "$root" --direction down --ratio 0.75 --no-focus | jq -r '.result.pane.pane_id')
  opencode=$(herdr --session "$SESSION" pane split "$root" --direction right --ratio 0.68 --no-focus | jq -r '.result.pane.pane_id')
  herdr --session "$SESSION" pane run "$root" 'sh -lc nvim' >/dev/null 2>&1 || true
  herdr --session "$SESSION" pane run "$opencode" 'sh -lc opencode' >/dev/null 2>&1 || true
  herdr --session "$SESSION" pane focus --direction left --pane "$opencode" >/dev/null 2>&1 || true
fi

trap - EXIT
exec herdr --session "$SESSION"
