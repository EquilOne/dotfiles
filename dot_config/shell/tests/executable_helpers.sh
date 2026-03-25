#!/bin/bash
# =============================================================================
# SHELL CONFIGURATION TEST HELPERS
# =============================================================================

# Counters (avoid `let` for portability)
_TOTAL=0
_PASSED=0
_FAILED=0
_SKIPPED=0

pass() {
    local desc="$1"
    echo "  [PASS] $desc"
    (( _PASSED++ )); (( _TOTAL++ ))
}

fail() {
    local desc="$1"
    echo "  [FAIL] $desc"
    (( _FAILED++ )); (( _TOTAL++ ))
}

skip() {
    local desc="$1"
    echo "  [SKIP] $desc"
    (( _SKIPPED++ )); (( _TOTAL++ ))
}

# Assert an environment variable is non-empty
assert_set() {
    local var="$1"
    local value="${!var}"   # bash indirect expansion - no eval needed
    if [[ -n "$value" ]]; then
        pass "$var is set"
    else
        fail "$var is not set"
    fi
}

# Assert a command / function / alias is defined
assert_command() {
    local cmd="$1"
    local kind
    kind="$(type -t "$cmd" 2>/dev/null)"
    if [[ -n "$kind" ]]; then
        pass "$cmd is defined ($kind)"
    else
        fail "$cmd is not defined"
    fi
}

# Assert a file exists
assert_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        pass "$file exists"
    else
        fail "$file does not exist"
    fi
}

# Assert PATH contains an exact colon-delimited entry
assert_path_contains() {
    local str="$1"
    if [[ ":$PATH:" == *":$str:"* ]]; then
        pass "$str in PATH"
    else
        fail "$str not in PATH"
    fi
}

# Print totals and exit non-zero on any failure
summary() {
    echo ""
    echo "==============================="
    echo "Results: $_PASSED passed  $_FAILED failed  $_SKIPPED skipped  (total: $_TOTAL)"
    echo "==============================="
    [[ $_FAILED -gt 0 ]] && exit 1 || exit 0
}

# Source all config files individually in the correct load order,
# bypassing the interactive-only guard in loader.sh
load_config() {
    # Enable alias expansion in non-interactive scripts
    shopt -s expand_aliases
    export CURRENT_SHELL="bash"
    local confdir="$HOME/.config/shell"

    # Mirror the numeric load order from loader.sh
    local configs=(
        "00_env.sh"
        "00_rose_pine_colors.sh"
        "05_brew.sh"
        "10_aliases.sh"
        "15_functions/01_starship.sh"
        "15_functions/02_yazi_shell_wrapper.sh"
        "15_functions/fzf_functions.sh"
        "15_functions/yazi_integration.sh"
        "20_path.sh"
        "21_zsh_completions.sh"
        "22_alias_completions.sh"
        "25_completions/carapace.sh"
        "30_tools/direnv_init.sh"
        "30_tools/fzf_init.sh"
        "30_tools/zoxide_init.sh"
    )

    for conf in "${configs[@]}"; do
        [[ -f "$confdir/$conf" ]] && source "$confdir/$conf" 2>/dev/null
    done
}
