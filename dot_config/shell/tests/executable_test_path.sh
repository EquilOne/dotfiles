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

echo ""
echo "path_dedup Function"
echo "-------------------"
# Inline path_dedup since it is unset after 20_path.sh loads
_path_dedup_test() {
    local new_path="" entry
    while IFS= read -r entry; do
        [[ -z "$entry" ]] && continue
        if [[ ":$new_path:" != *":$entry:"* ]]; then
            new_path="${new_path:+$new_path:}$entry"
        fi
    done <<< "$(echo "$1" | tr ':' '\n')"
    echo "$new_path"
}

# Test: removes duplicate entries
_result=$(_path_dedup_test "/a:/b:/a:/c")
if [[ "$_result" == "/a:/b:/c" ]]; then
    pass "path_dedup removes duplicate entries"
else
    fail "path_dedup duplicate removal failed (got: $_result)"
fi

# Test: preserves first-occurrence order
_result=$(_path_dedup_test "/z:/a:/b:/a:/z")
if [[ "$_result" == "/z:/a:/b" ]]; then
    pass "path_dedup preserves first-occurrence order"
else
    fail "path_dedup order preservation failed (got: $_result)"
fi

# Test: no-op on already-clean PATH
_result=$(_path_dedup_test "/a:/b:/c")
if [[ "$_result" == "/a:/b:/c" ]]; then
    pass "path_dedup is a no-op on clean PATH"
else
    fail "path_dedup modified a clean PATH (got: $_result)"
fi

# Test: strips empty entries
_result=$(_path_dedup_test "/a::/b")
if [[ "$_result" == "/a:/b" ]]; then
    pass "path_dedup strips empty entries"
else
    fail "path_dedup did not strip empty entries (got: $_result)"
fi

unset -f _path_dedup_test
unset _result
