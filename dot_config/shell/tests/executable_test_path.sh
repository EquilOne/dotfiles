#!/bin/bash
# =============================================================================
# TESTS: PATH INTEGRITY
# =============================================================================

echo ""
echo "PATH Entries"
echo "------------"

# Always expected
assert_path_contains "$HOME/.local/bin"

# Conditional on tool installation
if [[ -d "$HOME/.cargo/bin" ]]; then
    assert_path_contains "$HOME/.cargo/bin"
else
    skip ".cargo/bin (cargo not installed)"
fi

if [[ -d "$GOPATH/bin" ]]; then
    assert_path_contains "$GOPATH/bin"
else
    skip "go/bin (go not installed)"
fi

if [[ -d "$BUN_INSTALL/bin" ]]; then
    assert_path_contains "$BUN_INSTALL/bin"
else
    skip ".bun/bin (bun not installed)"
fi

if [[ -d "$PNPM_HOME" ]]; then
    assert_path_contains "$PNPM_HOME"
else
    skip "pnpm home (pnpm not installed)"
fi

echo ""
echo "PATH Duplicates"
echo "---------------"
_dup_count=$(echo "$PATH" | tr ':' '\n' | sort | uniq -d | wc -l)
if (( _dup_count == 0 )); then
    pass "No duplicate entries in PATH"
else
    fail "Found $_dup_count duplicate PATH entries: $(echo "$PATH" | tr ':' '\n' | sort | uniq -d | tr '\n' ' ')"
fi
unset _dup_count
