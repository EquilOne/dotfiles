#!/bin/bash
# =============================================================================
# TESTS: SHELL FUNCTIONS AND ALIASES
# =============================================================================

echo ""
echo "path_prepend Logic"
echo "------------------"

# Test path_prepend in isolation - source 20_path.sh already ran path_prepend
# and unset it, so redefine it here to unit-test the logic directly
_path_prepend_test() {
    if [[ -d "$1" && ":$PATH:" != *":$1:"* ]]; then
        export PATH="$1:$PATH"
    fi
}

# Should add an existing directory
_tmp_dir="$(mktemp -d)"
_saved_path="$PATH"
_path_prepend_test "$_tmp_dir"
if [[ ":$PATH:" == *":$_tmp_dir:"* ]]; then
    pass "path_prepend adds existing directory"
else
    fail "path_prepend did not add existing directory"
fi
rmdir "$_tmp_dir"
export PATH="$_saved_path"

# Should silently ignore a non-existent directory
_fake_dir="/this/does/not/exist/xyz123"
_path_prepend_test "$_fake_dir"
if [[ ":$PATH:" != *":$_fake_dir:"* ]]; then
    pass "path_prepend rejects non-existent directory"
else
    fail "path_prepend added non-existent directory"
    export PATH="$_saved_path"
fi

# Should not create duplicate entries
_first_entry="${PATH%%:*}"
_count_before=$(echo "$PATH" | tr ':' '\n' | wc -l)
_path_prepend_test "$_first_entry"
_count_after=$(echo "$PATH" | tr ':' '\n' | wc -l)
if (( _count_before == _count_after )); then
    pass "path_prepend prevents duplicate entries"
else
    fail "path_prepend added a duplicate entry"
fi
unset -f _path_prepend_test
unset _tmp_dir _saved_path _fake_dir _first_entry _count_before _count_after

echo ""
echo "set_starship_width"
echo "------------------"
if command -v starship >/dev/null 2>&1; then
    assert_command set_starship_width

    COLUMNS=30
    set_starship_width
    if [[ "$STARSHIP_CONFIG" == *"starship_minimal.toml" ]]; then
        pass "set_starship_width: COLUMNS=30 → minimal config"
    else
        fail "set_starship_width: COLUMNS=30 → expected minimal, got '$STARSHIP_CONFIG'"
    fi

    COLUMNS=60
    set_starship_width
    if [[ "$STARSHIP_CONFIG" == *"starship_narrow.toml" ]]; then
        pass "set_starship_width: COLUMNS=60 → narrow config"
    else
        fail "set_starship_width: COLUMNS=60 → expected narrow, got '$STARSHIP_CONFIG'"
    fi

    COLUMNS=100
    set_starship_width
    if [[ "$STARSHIP_CONFIG" == *"starship.toml" && "$STARSHIP_CONFIG" != *"minimal"* && "$STARSHIP_CONFIG" != *"narrow"* ]]; then
        pass "set_starship_width: COLUMNS=100 → full config"
    else
        fail "set_starship_width: COLUMNS=100 → expected full, got '$STARSHIP_CONFIG'"
    fi
else
    skip "set_starship_width tests (starship not installed)"
fi

echo ""
echo "Custom Functions"
echo "----------------"
if command -v yazi >/dev/null 2>&1; then
    assert_command y
else
    skip "y (yazi not installed)"
fi

if command -v yazi >/dev/null 2>&1 && command -v fzf >/dev/null 2>&1; then
    assert_command fy
else
    skip "fy (yazi or fzf not installed)"
fi

if command -v yazi >/dev/null 2>&1 && command -v zoxide >/dev/null 2>&1; then
    assert_command zy
else
    skip "zy (yazi or zoxide not installed)"
fi

if command -v fzf >/dev/null 2>&1 && command -v rg >/dev/null 2>&1; then
    assert_command rgf
else
    skip "rgf (fzf or rg not installed)"
fi

if command -v fzf >/dev/null 2>&1 && command -v git >/dev/null 2>&1; then
    assert_command fgb
else
    skip "fgb (fzf or git not installed)"
fi

echo ""
echo "Aliases"
echo "-------"
# Git aliases - git is expected to always be present
assert_command g
assert_command gs
assert_command gc
assert_command gst
assert_command gl

# ls aliases - always defined (fall back to system ls if eza absent)
assert_command ls
assert_command ll
assert_command la
assert_command lla

# Navigation
if command -v zoxide >/dev/null 2>&1; then
    assert_command zi
else
    skip "zi (zoxide not installed)"
fi

# cat → bat only when bat is installed
if command -v bat >/dev/null 2>&1; then
    assert_command cat
else
    skip "cat alias (bat not installed)"
fi
