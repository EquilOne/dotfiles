#!/usr/bin/env bash
# Sync edited config files into chezmoi source via `chezmoi re-add`.
# Template files (.tmpl) are reported but not synced — use `chezmoi edit`.
#
# Exit codes:
#   0  all files processed (synced, already-in-sync, unmanaged, or template)
#   1  one or more re-add operations failed
#   2  pre-flight warning: autoCommit on + dirty source tree; use --force
#
# Usage: chezmoi-sync.sh [--force] FILE [FILE...]

set -euo pipefail

usage() {
  echo "Usage: $0 [--force] FILE [FILE...]" >&2
  exit 64
}

FORCE=0
files=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --force) FORCE=1; shift ;;
    -h|--help) usage ;;
    --) shift; while [ "$#" -gt 0 ]; do files+=("$1"); shift; done ;;
    -*) echo "unknown flag: $1" >&2; usage ;;
    *) files+=("$1"); shift ;;
  esac
done
[ ${#files[@]} -eq 0 ] && usage

if ! command -v chezmoi >/dev/null 2>&1; then
  echo "chezmoi not installed" >&2
  exit 127
fi

# --- Pre-flight: detect autoCommit + dirty source tree ---
# Fail-safe: default to ON (the dangerous case). If we can't determine
# the autoCommit state, we prefer to warn rather than silently let a
# dirty-tree bundling happen.
autocommit="true"
autopush="true"

if data=$(chezmoi data 2>/dev/null); then
  if command -v jq >/dev/null 2>&1; then
    val=$(echo "$data" | jq -r '.git.autocommit // empty' 2>/dev/null)
    [ -n "$val" ] && autocommit="$val"
    val=$(echo "$data" | jq -r '.git.autopush // empty' 2>/dev/null)
    [ -n "$val" ] && autopush="$val"
  else
    # Case-insensitive grep fallback — chezmoi may use camelCase or lowercase
    val=$(echo "$data" | grep -ioE '"autoCommit"\s*:\s*(true|false)' | head -1 | sed 's/.*: *//')
    [ -n "$val" ] && autocommit="$val"
    val=$(echo "$data" | grep -ioE '"autoPush"\s*:\s*(true|false)' | head -1 | sed 's/.*: *//')
    [ -n "$val" ] && autopush="$val"
  fi
fi

if [ "$autocommit" = "true" ] && [ "$FORCE" -eq 0 ]; then
  pending=$(chezmoi git -- status --porcelain 2>/dev/null || true)
  if [ -n "$pending" ]; then
    echo "WARNING: chezmoi autoCommit is enabled and the source tree has" >&2
    echo "uncommitted changes. Running re-add will bundle ALL of these into" >&2
    echo "one auto-commit with a default concatenated message." >&2
    echo "" >&2
    echo "Pending changes:" >&2
    echo "$pending" | sed 's/^/  /' >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  1. Commit these first: chezmoi git -- commit -am \"<message>\"" >&2
    echo "  2. Proceed anyway: re-run with --force" >&2
    exit 2
  fi
fi

# --- Sync loop ---
synced=()
already_in_sync=()
unmanaged=()
templates=()
errors=()

for raw in "${files[@]}"; do
  # Expand ~ and resolve to absolute path
  file=$(realpath -m -- "$raw" 2>/dev/null || echo "$raw")

  # chezmoi source-path prints error to stderr + exits non-zero if unmanaged
  src=$(chezmoi source-path -- "$file" 2>/dev/null || true)

  if [ -z "$src" ]; then
    unmanaged+=("$file")
    continue
  fi

  case "$src" in
    *.tmpl)
      templates+=("$file -> $src")
      continue
      ;;
  esac

  # Verbose: stream chezmoi re-add output as it runs.
  echo "--- $file ---"
  output=$(chezmoi re-add -- "$file" 2>&1) || {
    errors+=("$file")
    echo "$output" >&2
    continue
  }
  echo "$output"

  # Parse commit hash + push from output
  hash=$(echo "$output" | grep -oE '\[[a-zA-Z0-9._/-]+ [a-f0-9]+\]' | grep -oE '[a-f0-9]{7,}' | head -1)
  if [ -n "$hash" ]; then
    if [ "$autopush" = "true" ]; then
      synced+=("$file -> $src (commit $hash, pushed)")
    else
      synced+=("$file -> $src (commit $hash)")
    fi
  else
    already_in_sync+=("$file")
  fi
done

echo
if [ ${#synced[@]} -gt 0 ]; then
  echo "synced:"
  printf '  %s\n' "${synced[@]}"
fi
if [ ${#already_in_sync[@]} -gt 0 ]; then
  echo "already in sync:"
  printf '  %s\n' "${already_in_sync[@]}"
fi
if [ ${#unmanaged[@]} -gt 0 ]; then
  echo "not managed:"
  printf '  %s\n' "${unmanaged[@]}"
fi
if [ ${#templates[@]} -gt 0 ]; then
  echo "templates (use \`chezmoi edit\`):"
  printf '  %s\n' "${templates[@]}"
fi
if [ ${#errors[@]} -gt 0 ]; then
  echo "errors:" >&2
  printf '  %s\n' "${errors[@]}" >&2
fi

if [ ${#errors[@]} -gt 0 ]; then
  exit 1
fi
exit 0
