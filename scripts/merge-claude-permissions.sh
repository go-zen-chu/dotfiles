#!/bin/bash
#
# Merge a Claude permissions file into an existing settings.json and print the
# result to stdout. Pure (no side effects) so it can be unit tested directly.
#
# Usage: merge-claude-permissions.sh <current-settings.json> <permissions.json>
#
# Semantics:
#   - every existing top-level key in the current settings is preserved
#   - the allow/deny/ask lists under .permissions are unioned (deduped)
#   - empty permission lists are dropped rather than written back as []

set -eu

if [ "$#" -ne 2 ]; then
    echo "usage: $(basename "$0") <current-settings.json> <permissions.json>" >&2
    exit 2
fi

current="$1"
incoming="$2"

jq -n --slurpfile cur "${current}" --slurpfile new "${incoming}" '
    ($cur[0] // {}) as $c
    | ($new[0] // {}) as $n
    | ($c.permissions // {}) as $cp
    | ($n.permissions // {}) as $np
    | ($cp * $np
        | .allow = (($cp.allow // []) + ($np.allow // []) | unique)
        | .deny  = (($cp.deny  // []) + ($np.deny  // []) | unique)
        | .ask   = (($cp.ask   // []) + ($np.ask   // []) | unique)
        | with_entries(select(.value | (type != "array") or (length > 0)))
      ) as $mp
    | $c * { permissions: $mp }
'
