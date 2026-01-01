#!/bin/bash
# =============================================================================
# SHELL CONFIGURATION TEST SCRIPT (Combined Best Practices)
# =============================================================================

#Enable alias expansion
shopt -s expand_aliases
# Make the loader work in non-interactive mode
# Modify the loader temporarily to skip interactive check
sed 's/^\[\[ \$- != \*i\* \]\] && return/# &/' "$HOME/.config/shell/loader.sh" > /tmp/loader_test.sh

# Source the modified loader
if [[ -f /tmp/loader_test.sh ]]; then
    source /tmp/loader_test.sh 2>/dev/null
    rm /tmp/loader_test.sh
else
    echo "❌ ERROR: Could not create test loader"
    exit 1
fi

echo "🧪 Testing Shell Configuration..."
echo "=================================="

# Test 1: Tool Availability
echo -e "\n📦 Tool Availability:"
tools=("fzf" "fd" "rg" "eza" "yazi" "zoxide" "bat" "starship")
for tool in "${tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "  ✅ $tool: $(command -v "$tool")"
    else
        echo "  ❌ $tool: Not found"
    fi
done

# Test 2: Configuration Files
echo -e "\n📄 Configuration Files:"
configs=(
    "shell/loader.sh"
    "shell/00_env.sh"
    "shell/00_rose_pine_colors.sh"
    "shell/20_path.sh"
    "shell/30_tools/fzf_init.sh"
    "shell/30_tools/zoxide_init.sh"
)
for config in "${configs[@]}"; do
    [[ -f "$HOME/.config/$config" ]] && echo "  ✅ $config" || echo "  ❌ $config - MISSING"
done

# Test 3: Environment Variables (safe method for all bash versions)
echo -e "\n🌍 Environment Variables:"
check_var() {
    local varname="$1"
    local value
    eval "value=\$$varname"
    if [[ -n "$value" ]]; then
        echo "  ✅ $varname=$value"
    else
        echo "  ❌ $varname - NOT SET"
    fi
}

vars=("XDG_CONFIG_HOME" "XDG_DATA_HOME" "GOPATH" "PNPM_HOME" "BUN_INSTALL" "CURRENT_SHELL")
for v in "${vars[@]}"; do check_var "$v"; done

# Test 4: Rose Pine Colors
echo -e "\n🎨 Rose Pine Colors:"
colors=("ROSE_PINE_TEXT" "ROSE_PINE_FOAM" "ROSE_PINE_GOLD" "ROSE_PINE_BASE")
for c in "${colors[@]}"; do check_var "$c"; done

# Test 5: Functions & Aliases (using type -t for better detection)
echo -e "\n🎯 Commands & Functions:"
commands=("z" "zi" "rgf" "fgb" "fy" "zy" "y" "ls" "ll" "la")
for cmd in "${commands[@]}"; do
    ctype=$(type -t "$cmd" 2>/dev/null)
    if [[ -n "$ctype" ]]; then
        echo "  ✅ $cmd ($ctype)"
    else
        echo "  ❌ $cmd - Not found"
    fi
done

# Test 6: PATH Check (improved logic)
echo -e "\n🛣️  PATH Check:"
path_items=(".cargo/bin" "go/bin" "pnpm" ".local/bin")
for item in "${path_items[@]}"; do
    if [[ "$PATH" == *"$item"* ]]; then
        echo "  ✅ $item in PATH"
    else
        echo "  ⚠️  $item not in PATH"
    fi
done

# Test 7: FZF Configuration
echo -e "\n🔍 FZF Configuration:"
if [[ -n "$FZF_DEFAULT_OPTS" ]]; then
    color_count=$(echo "$FZF_DEFAULT_OPTS" | grep -o "color=" | wc -l)
    echo "  ✅ FZF_DEFAULT_OPTS ($color_count colors)"
else
    echo "  ❌ FZF_DEFAULT_OPTS not set"
fi

[[ -n "$FZF_DEFAULT_COMMAND" ]] && \
    echo "  ✅ FZF_DEFAULT_COMMAND: $FZF_DEFAULT_COMMAND" || \
    echo "  ❌ FZF_DEFAULT_COMMAND not set"

# Summary
echo -e "\n🏁 Test Complete!"
echo "Summary: ❌ = needs attention, ⚠️ = optional/OK"
