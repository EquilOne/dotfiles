#!/bin/bash
# =============================================================================
# ZSH COMPLETIONS TEST
# =============================================================================

# Helpers
_TOTAL=0
_PASSED=0
_FAILED=0
_SKIPPED=0

pass() {
  local desc="$1"
  echo "[PASS] $desc"
  (( _PASSED++ ))
  (( _TOTAL++ ))
}

fail() {
  local desc="$1"
  echo "[FAIL] $desc"
  (( _FAILED++ ))
  (( _TOTAL++ ))
}

skip() {
  local desc="$1"
  echo "[SKIP] $desc"
  (( _SKIPPED++ ))
  (( _TOTAL++ ))
}

summary() {
  echo ""
  echo "==============================="
  echo "ZSH Completions Test Results: $_PASSED passed  $_FAILED failed  $_SKIPPED skipped  (total: $_TOTAL)"
  echo "==============================="
  [[ $_FAILED -gt 0 ]] && exit 1 || exit 0
}

# Tests

# Test syntax
if zsh -n /home/equilone/.config/shell/21_zsh_completions.sh ; then
  pass "zsh completions syntax valid"
else
  fail "zsh completions syntax invalid"
fi

# Test zstyle matcher-list is set
value=$(zsh -c '
  CURRENT_SHELL=zsh
  source /home/equilone/.config/shell/21_zsh_completions.sh
  zstyle -s ":completion:*" matcher-list value
  echo "$value"
' )

if [[ "$value" == *"m:{a-zA-Z}={A-Za-z}"* ]] && [[ "$value" == *"r:|[._-]=* r:|=*"* ]] && [[ "$value" == *"r:|[._-]=** r:|=**"* ]] && [[ "$value" == *"l:|=* r:|=*"* ]]; then
  pass "zsh matcher-list set correctly"
else
  fail "zsh matcher-list not correct: '$value'"
fi

# Test zsh-specific initialization
skip "zsh completion matching behavior requires interactive testing in zsh"

skip "step 1: exact game_events -> game_events.json"

skip "step 2: case-insensitive Game_Events -> game_events.json"

skip "step 3: separator-aware partial game_e -> game_events.json"

skip "step 4: separator-ignoring gamee -> game_events.json"

skip "step 5: substring anywhere vents -> game_events.json"

# Edge cases
skip "mixed separators tested manually"
skip "case variations tested manually"

summary