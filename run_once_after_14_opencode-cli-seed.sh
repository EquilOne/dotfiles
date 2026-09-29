#!/bin/bash
# Manage ~/.config/opencode/cli.json as "hard config injected by chezmoi,
# app-written toggleables left alone": opencode rewrites some keys at runtime
# (e.g. session.permissions), so cli.json is NOT a managed source file. This
# run_once_after script re-runs whenever its content changes and deep-merges
# the embedded HARD config into the live file: hard keys win conflicts,
# live-only keys (session.permissions, anything else opencode writes) are
# preserved. This script must NEVER fail a chezmoi apply: any internal
# failure warns on stderr and exits 0, leaving the live file untouched.
set -euo pipefail
umask 077

HARD="$(cat <<'JSON'
{
  "$schema": "https://opencode.ai/v2/cli.json",
  "theme": {
    "name": "rosepine"
  },
  "keybinds": {
    "leader": "ctrl+space",
    "app.exit": "<leader>q",
    "command.palette.show": "ctrl+p",
    "prompt.editor": "<leader>e",
    "session.sidebar.toggle": "<leader>b",
    "session.toggle.scrollbar": "none",
    "opencode.status": "<leader>s",
    "session.export": "none",
    "session.new": "<leader>n",
    "session.list": "<leader>l",
    "session.timeline": "<leader>g",
    "session.fork": "none",
    "session.rename": "none",
    "session.share": "none",
    "session.unshare": "none",
    "session.interrupt": "escape",
    "session.compact": "<leader>c",
    "session.background": "<leader>f",
    "session.child.first": "<leader>t",
    "session.child.next": "<leader>]",
    "session.child.previous": "<leader>[",
    "session.parent": "<leader>p",
    "model.list": "<leader>m",
    "model.cycle_recent": "f2",
    "model.cycle_recent_reverse": "shift+f2",
    "model.cycle_favorite": "none",
    "model.cycle_favorite_reverse": "none",
    "agent.list": "<leader>a",
    "agent.cycle": "tab",
    "agent.cycle.reverse": "shift+tab",
    "variant.cycle": "ctrl+t",
    "session.page.up": "ctrl+alt+u",
    "session.page.down": "ctrl+f",
    "session.line.up": "ctrl+alt+y",
    "session.line.down": "ctrl+alt+e",
    "session.half.page.up": "ctrl+u",
    "session.half.page.down": "ctrl+d",
    "session.first": "ctrl+g,home",
    "session.last": "ctrl+alt+g,end",
    "session.message.next": "none",
    "session.message.previous": "none",
    "session.messages_last_user": "none",
    "messages.copy": "<leader>y",
    "session.undo": "<leader>u",
    "session.redo": "<leader>r",
    "session.toggle.thinking": "none",
    "prompt.clear": "ctrl+c",
    "prompt.paste": "ctrl+v",
    "input.submit": "return",
    "input.newline": "shift+return,ctrl+return,alt+return,ctrl+j",
    "input.move.left": "left",
    "input.move.right": "right",
    "input.move.up": "up",
    "input.move.down": "down",
    "input.select.left": "shift+left",
    "input.select.right": "shift+right",
    "input.select.up": "shift+up",
    "input.select.down": "shift+down",
    "input.line.home": "ctrl+alt+a",
    "input.line.end": "ctrl+e",
    "input.select.line.home": "ctrl+shift+a",
    "input.select.line.end": "ctrl+shift+e",
    "input.visual.line.home": "alt+a",
    "input.visual.line.end": "alt+e",
    "input.select.visual.line.home": "alt+shift+a",
    "input.select.visual.line.end": "alt+shift+e",
    "input.buffer.home": "home",
    "input.buffer.end": "end",
    "input.select.buffer.home": "shift+home",
    "input.select.buffer.end": "shift+end",
    "input.delete.line": "ctrl+shift+d",
    "input.delete.to.line.end": "ctrl+k",
    "input.delete.to.line.start": "ctrl+u",
    "input.backspace": "backspace,shift+backspace",
    "input.delete": "delete,shift+delete",
    "input.undo": "ctrl+-,super+z",
    "input.redo": "ctrl+.,super+shift+z",
    "input.word.forward": "alt+f,alt+right,ctrl+right",
    "input.word.backward": "alt+b,alt+left,ctrl+left",
    "input.select.word.forward": "alt+shift+f,alt+shift+right",
    "input.select.word.backward": "alt+shift+b,alt+shift+left",
    "input.delete.word.forward": "alt+d,alt+delete,ctrl+delete",
    "input.delete.word.backward": "ctrl+w,ctrl+backspace,alt+backspace",
    "prompt.history.previous": "up",
    "prompt.history.next": "down",
    "terminal.suspend": "ctrl+z",
    "terminal.title.toggle": "none"
  },
  "scroll": {
    "acceleration": true
  },
  "diffs": {
    "wrap": "word"
  },
  "session": {
    "sidebar": "auto",
    "scrollbar": false,
    "thinking": "hide"
  },
  "tabs": {
    "mode": "on"
  },
  "animations": true
}
JSON
)"

target="$HOME/.config/opencode/cli.json"

trap 'printf "opencode-cli-seed: warning: internal failure near line %s (status %s); leaving things as they are\n" "${BASH_LINENO[0]:-?}" "$?" >&2; exit 0' ERR

warn() { printf 'opencode-cli-seed: %s\n' "$1" >&2; }

# Atomic write: mktemp in the target dir (same filesystem), 0600, mv.
write_atomic() {
  local dir tmp
  dir="$(dirname "$target")"
  mkdir -p "$dir"
  tmp="$(mktemp "$dir/.cli.json.XXXXXX")"
  trap 'rm -f "$tmp"' EXIT
  printf '%s\n' "$1" > "$tmp"
  chmod 600 "$tmp"
  mv -f "$tmp" "$target"
  trap - EXIT
}

# Deep-merge hard INTO live: recursive object merge, hard wins conflicts.
# (jq `*` gives the right operand precedence, so the file order is hard first,
# live second and the filter multiplies `.[1] * .[0]` = live * hard.)
merge_jq() {
  jq -s '.[1] * .[0]' <(printf '%s' "$HARD") "$target"
}

merge_py() {
  HARD="$HARD" python3 - "$target" <<'PY'
import json, os, sys

hard = json.loads(os.environ["HARD"])
with open(sys.argv[1]) as fh:
    live = json.load(fh)

def merge(h, l):
    if isinstance(h, dict) and isinstance(l, dict):
        out = dict(l)
        for k, v in h.items():
            cur = out.get(k)
            out[k] = merge(v, cur) if isinstance(cur, dict) and isinstance(v, dict) else v
        return out
    return h

json.dump(merge(hard, live), sys.stdout, indent=2)
sys.stdout.write("\n")
PY
}

if [[ ! -f "$target" ]]; then
  write_atomic "$HARD"
  exit 0
fi

merged=""
if command -v jq >/dev/null 2>&1; then
  merged="$(merge_jq)" || merged=""
elif command -v python3 >/dev/null 2>&1; then
  merged="$(merge_py)" || merged=""
else
  warn "neither jq nor python3 available; leaving $target untouched"
  exit 0
fi

if [[ -z "$merged" ]]; then
  # Merge failed — almost certainly invalid JSON in the live file (opencode
  # crashed mid-write). Move the broken file aside and reseed from hard.
  corrupt="$target.corrupt-$(date +%s)"
  mv -f "$target" "$corrupt"
  warn "could not parse/merge $target; moved to $corrupt and reseeded from hard config"
  write_atomic "$HARD"
  exit 0
fi

write_atomic "$merged"
exit 0