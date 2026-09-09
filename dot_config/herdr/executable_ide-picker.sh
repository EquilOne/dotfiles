#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:/home/linuxbrew/.linuxbrew/bin:/usr/local/bin:/usr/bin:/bin${PATH:+:$PATH}"
for bin in herdr jq ghostty; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "ide-picker: $bin not found in PATH" >&2
    exit 1
  fi
done

SESSION=ide
HERDR_CONFIG_DIR="${HERDR_CONFIG_PATH:-$HOME/.config/herdr}"
SOCK="$HERDR_CONFIG_DIR/sessions/$SESSION/herdr.sock"
SELF="$HOME/.config/herdr/ide.sh"

MENU_BIN=""
for candidate in walker rofi tofi dmenu; do
  if command -v "$candidate" >/dev/null 2>&1; then
    MENU_BIN=$candidate
    break
  fi
done
if [[ -z "$MENU_BIN" ]]; then
  echo "ide-picker: no menu binary found (walker, rofi, tofi, dmenu)" >&2
  exit 1
fi

launch_ide() {
  nohup ghostty -e "$SELF" "$@" >/dev/null 2>&1 &
  disown
}

list_workspaces() {
  herdr --session "$SESSION" workspace list 2>/dev/null \
    | jq -r '.result.workspaces[]? | "\(.number)\t\(.label)"' | sort -n
}

entries=$(list_workspaces || true)
if [[ -z "$entries" ]]; then
  # Session not running, list failed, or no workspaces: fall back to default IDE launch.
  launch_ide
  exit 0
fi

case "$MENU_BIN" in
  walker)
    selection=$(printf '%s\n' "$entries" | walker -d -p "ide workspaces") || exit 0
    ;;
  rofi)
    selection=$(printf '%s\n' "$entries" | rofi -dmenu -i -p "ide workspaces") || exit 0
    ;;
  tofi)
    selection=$(printf '%s\n' "$entries" | tofi --prompt-text "ide workspaces: ") || exit 0
    ;;
  dmenu)
    selection=$(printf '%s\n' "$entries" | dmenu -i -p "ide workspaces") || exit 0
    ;;
esac

if [[ -z "${selection:-}" ]]; then
  exit 0
fi

label=$(printf '%s' "$selection" | cut -f2-)
if [[ -z "$label" ]]; then
  echo "ide-picker: could not parse label from selection: $selection" >&2
  exit 1
fi

launch_ide --attach "$label"
