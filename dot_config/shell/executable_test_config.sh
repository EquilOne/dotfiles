#!/bin/bash
# =============================================================================
# SHELL CONFIGURATION TEST RUNNER
# =============================================================================
# Usage: ~/.config/shell/test_config.sh
# Runs the modular test suite in tests/ and prints a final summary.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_DIR="$SCRIPT_DIR/tests"

if [[ ! -d "$TESTS_DIR" ]]; then
    echo "[ERROR] tests/ directory not found at $TESTS_DIR"
    exit 1
fi

# Load helpers (defines counters, assert_*, load_config, summary)
source "$TESTS_DIR/helpers.sh"

# Load all shell config files once, shared across all test files
load_config

echo "Shell Configuration Test Suite"
echo "==============================="

source "$TESTS_DIR/test_env.sh"
source "$TESTS_DIR/test_functions.sh"
source "$TESTS_DIR/test_path.sh"
source "$TESTS_DIR/test_zsh_completions.sh"

summary
