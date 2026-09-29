#!/bin/bash
# Seed ~/.hermes/config.yaml on first install only.
# config.yaml is intentionally NOT managed by chezmoi (see
# private_dot_hermes/.chezmoiignore): hermes rewrites it at runtime and
# omarchy 4 theme sync (omarchy-theme-set-hermes) publishes/activates the
# omarchy skin. This script only renders the template on machines that have
# no config yet; afterwards hermes owns the file.
set -euo pipefail

hermes_home="${HERMES_HOME:-$HOME/.hermes}"
target="$hermes_home/config.yaml"

[[ -f "$target" ]] && exit 0

template="$(chezmoi source-path)/private_dot_hermes/private_config.yaml.tmpl"
mkdir -p "$hermes_home"
umask 077
tmp="$(mktemp "$hermes_home/.config.yaml.XXXXXX")"
trap 'rm -f "$tmp"' EXIT
chezmoi execute-template < "$template" > "$tmp"
mv -f "$tmp" "$target"
trap - EXIT
