#!/bin/sh
# Prints the YNAB PAT from the Proton Pass Dev vault for chezmoi templating.
# Referenced by private_dot_hermes/private_config.yaml via the `output` template fn.
# Lives in .chezmoiscripts/ WITHOUT a run_ prefix, so chezmoi never executes it
# as a lifecycle script — it is only called from templates.
set -eu
export PROTON_PASS_KEY_PROVIDER=fs
exec "$HOME/.local/bin/pass-cli" item get pass://Dev/YNAB --output json \
  | jq -r '.item.content.extra_fields[] | select(.name=="PAT") | .content.Hidden'
