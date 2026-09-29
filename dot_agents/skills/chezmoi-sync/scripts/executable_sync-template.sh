#!/usr/bin/env bash
# Sync a destination-file edit back into a chezmoi TEMPLATE source.
#
# `chezmoi re-add` refuses to overwrite templates (rightly — it would bake
# rendered values in). This script does the safe version of that:
#
#   1. Copy the destination file over the .tmpl source.
#   2. Re-insert template directives from the PREVIOUS template: for every
#      old line containing {{...}}, find the matching rendered line in the
#      new copy (comparing the line with the directive stripped) and restore
#      the directive. Template-only lines (bare {{ if }} etc.) and unmatched
#      directives cause a revert with a report — never a silent corruption.
#   3. Verify: `chezmoi cat <dest>` must render byte-identical to the live
#      destination file. On any failure the original template is restored.
#
# Usage: sync-template.sh DEST_FILE
# Exit codes: 0 synced+verified; 1 verification failed (template reverted,
#             do the merge manually); 64 usage error; 65 not managed /
#             not a template.
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 DEST_FILE" >&2
  exit 64
fi

dest=$(realpath -m -- "$1")
command -v chezmoi >/dev/null 2>&1 || { echo "chezmoi not installed" >&2; exit 127; }

src=$(chezmoi source-path -- "$dest" 2>/dev/null || true)
if [ -z "$src" ]; then
  echo "not managed by chezmoi: $dest" >&2
  exit 65
fi
case "$src" in
  *.tmpl) ;;
  *) echo "not a template (use \`chezmoi re-add\` instead): $src" >&2; exit 65 ;;
esac

backup=$(mktemp)
trap 'rm -f "$backup"' EXIT
cp -- "$src" "$backup"

python3 - "$backup" "$src" "$dest" <<'PYEOF'
import re, sys

backup, src, dest = sys.argv[1], sys.argv[2], sys.argv[3]
old = open(backup, encoding="utf-8").read().splitlines()
new = open(dest, encoding="utf-8").read().splitlines()

directive = re.compile(r"\{\{.*?\}\}")

def literal_fragments(line):
    """Literal text pieces around directives, whitespace-collapsed.

    A template line 'a {{ x }} b' matches a rendered line if all its
    literal fragments appear in the rendered line in order.
    """
    parts = directive.split(line)
    frags = [re.sub(r"\s+", " ", p).strip() for p in parts]
    return [f for f in frags if f]

def matches(tmpl_line, rendered_line):
    pos = 0
    rendered = rendered_line
    for frag in literal_fragments(tmpl_line):
        idx = rendered.find(frag, pos)
        if idx < 0:
            return False
        pos = idx + len(frag)
    return True

def is_bare_template(line):
    """True if the line contains only template syntax (no literal text)."""
    return directive.sub("", line).strip() == "" and directive.search(line)

old_directive_lines = []
unmatched = []
for i, line in enumerate(old):
    if not directive.search(line):
        continue
    if is_bare_template(line):
        unmatched.append((i + 1, line))  # no rendered counterpart
        continue
    old_directive_lines.append(line)

merged = list(new)
used = set()
missing = []
for tmpl_line in old_directive_lines:
    candidates = [i for i, line in enumerate(new) if i not in used and matches(tmpl_line, line)]
    if not candidates:
        missing.append(tmpl_line)
        continue
    i = candidates[0]
    used.add(i)
    merged[i] = tmpl_line

if missing or unmatched:
    print("UNMERGED TEMPLATE DIRECTIVES — merge manually with chezmoi edit:", file=sys.stderr)
    for line in missing + [l for _, l in unmatched]:
        print("  " + line, file=sys.stderr)
    sys.exit(1)

open(src, "w", encoding="utf-8").write("\n".join(merged) + "\n")
print(f"merged template directives into {src}")
PYEOF
merged=$?

if [ $merged -ne 0 ]; then
  cp -- "$backup" "$src"
  echo "template restored to previous state (nothing written)" >&2
  exit 1
fi

# Verify: rendered output must be byte-identical to the live destination.
rendered=$(mktemp)
trap 'rm -f "$backup" "$rendered"' EXIT
if chezmoi cat -- "$dest" > "$rendered" 2>/dev/null && cmp -s -- "$rendered" "$dest"; then
  echo "verified: chezmoi cat $dest == live file"
  exit 0
else
  cp -- "$backup" "$src"
  echo "VERIFICATION FAILED — render does not match destination; template reverted to previous state." >&2
  echo "Resolve manually: chezmoi edit -- $dest, then chezmoi cat to verify." >&2
  exit 1
fi
