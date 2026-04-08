#!/bin/bash
# =============================================================================
# TESTS: ZSH COMPLETION PATTERNS (21_zsh_completions.sh)
# =============================================================================
# Tests validate:
#   - Syntax of 21_zsh_completions.sh
#   - Presence and structure of the 4-step matcher-list
#   - Each step's pattern is present (interactive behavior must be tested manually)
#
# Note: separator-ignoring without typing a separator (e.g. gamee → game_events)
# is not achievable via matcher-list alone and requires a fuzzy plugin (fzf-tab).
#
# Manual verification steps (requires interactive zsh):
#   mkdir -p /tmp/completion_test && cd /tmp/completion_test
#   touch game_events.json Game_Events.json game-of-events.txt
#   Then press TAB after: game_events  Game_Events  game_e  vents

echo ""
echo "Zsh Completions"
echo "---------------"

_COMPLETIONS_FILE="$HOME/.config/shell/21_zsh_completions.sh"

# ── Syntax ────────────────────────────────────────────────────────────────────

if zsh -n "$_COMPLETIONS_FILE" 2>/dev/null; then
  pass "21_zsh_completions.sh syntax is valid"
else
  fail "21_zsh_completions.sh has syntax errors"
fi

# ── File structure ────────────────────────────────────────────────────────────

if grep -q "matcher-list" "$_COMPLETIONS_FILE"; then
  pass "matcher-list is configured"
else
  fail "matcher-list is missing"
fi

if grep -q 'CURRENT_SHELL.*zsh' "$_COMPLETIONS_FILE"; then
  pass "zsh-only guard is present"
else
  fail "zsh-only guard is missing"
fi

if grep -q 'SHELL_DEBUG' "$_COMPLETIONS_FILE"; then
  pass "SHELL_DEBUG trace line is present"
else
  fail "SHELL_DEBUG trace line is missing"
fi

# ── 4-step matcher patterns ───────────────────────────────────────────────────
# Verify each step's distinguishing pattern exists in the matcher-list.

# Step 1: exact (empty string matcher)
if grep -q "''" "$_COMPLETIONS_FILE"; then
  pass "step 1 (exact): empty matcher present"
else
  fail "step 1 (exact): empty matcher missing"
fi

# Step 2: case-insensitive
if grep -q "m:{a-zA-Z}={A-Za-z}" "$_COMPLETIONS_FILE"; then
  pass "step 2 (case-insensitive): m:{} matcher present"
else
  fail "step 2 (case-insensitive): m:{} matcher missing"
fi

# Step 3: separator-aware partial (r: anchor on separator)
if grep -qF 'r:|[._-]=* r:|=*' "$_COMPLETIONS_FILE"; then
  pass "step 3 (sep-aware partial): r:|[._-]=* r:|=* matcher present"
else
  fail "step 3 (sep-aware partial): r:|[._-]=* r:|=* matcher missing"
fi

# Step 4: substring anywhere (l:|=* r:|=*)
if grep -qF 'l:|=* r:|=*' "$_COMPLETIONS_FILE"; then
  pass "step 4 (substring anywhere): l:|=* r:|=* matcher present"
else
  fail "step 4 (substring anywhere): l:|=* r:|=* matcher missing"
fi

# Steps 2-4: case-insensitivity inherited (each active step includes the m:{} map)
_ci_count=$(grep -o "m:{a-zA-Z}={A-Za-z}" "$_COMPLETIONS_FILE" | wc -l)
if (( _ci_count >= 4 )); then
  pass "steps 2-4 all include case-insensitive m:{} map ($_ci_count occurrences)"
else
  fail "case-insensitive m:{} map not present in all steps (found $_ci_count, expected >= 4)"
fi

# ── Separator-ignoring limitation documented ──────────────────────────────────

if grep -q "fzf" "$_COMPLETIONS_FILE"; then
  pass "separator-ignoring limitation and fzf-tab noted in comments"
else
  skip "fzf-tab comment not found (optional)"
fi

# ── Interactive behavior (requires zsh + pty; skipped in script context) ──────

skip "step 1 runtime: game_events → game_events.json (interactive only)"
skip "step 2 runtime: Game_Events → game_events.json (interactive only)"
skip "step 3 runtime: game_e      → game_events.json (interactive only)"
skip "step 4 runtime: vents       → game_events.json (interactive only)"
skip "edge case: mixed separators game-of-events (interactive only)"
skip "edge case: all-caps GAME_EVENTS (interactive only)"
skip "not achievable via matcher-list: gamee → game_events.json (needs fzf-tab)"
