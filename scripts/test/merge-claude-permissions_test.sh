#!/bin/bash
#
# Plain-bash tests for scripts/merge-claude-permissions.sh.
# No test framework: only bash + jq (which install.sh already requires).
#
# Run: ./scripts/test/merge-claude-permissions_test.sh
# Exits non-zero if any case fails.

set -u

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
merge="${script_dir}/../merge-claude-permissions.sh"

work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT

pass=0
fail=0

# Compare two JSON strings after canonical sorting so key/array order and
# whitespace do not matter.
assert_json_eq() {
    local desc="$1" expected="$2" actual="$3"
    local e a
    e="$(printf '%s' "${expected}" | jq -S . 2>/dev/null)"
    a="$(printf '%s' "${actual}" | jq -S . 2>/dev/null)"
    if [ "${e}" = "${a}" ]; then
        pass=$((pass + 1))
        echo "ok   - ${desc}"
    else
        fail=$((fail + 1))
        echo "FAIL - ${desc}"
        echo "  expected: ${e}"
        echo "  actual:   ${a}"
    fi
}

assert_exit() {
    local desc="$1" want="$2" got="$3"
    if [ "${want}" = "${got}" ]; then
        pass=$((pass + 1))
        echo "ok   - ${desc}"
    else
        fail=$((fail + 1))
        echo "FAIL - ${desc} (want exit ${want}, got ${got})"
    fi
}

# Helper: write $1 to a temp file and echo its path.
mkjson() {
    local f
    f="$(mktemp "${work}/XXXXXX.json")"
    printf '%s' "$1" >"${f}"
    printf '%s' "${f}"
}

incoming='{"permissions":{"allow":["Bash(ls:*)","Bash(cat:*)"]}}'

# --- Case 1: preserve other top-level keys, union allow, keep deny --------
cur="$(mkjson '{"model":"x","env":{"A":"1"},"permissions":{"allow":["Bash(mycmd:*)"],"deny":["Bash(rm:*)"]}}')"
inc="$(mkjson "${incoming}")"
out="$("${merge}" "${cur}" "${inc}")"
assert_json_eq "preserves top-level keys and unions allow, keeps deny" \
    '{"model":"x","env":{"A":"1"},"permissions":{"allow":["Bash(cat:*)","Bash(ls:*)","Bash(mycmd:*)"],"deny":["Bash(rm:*)"]}}' \
    "${out}"

# --- Case 2: deduplicate overlapping allow entries -----------------------
cur="$(mkjson '{"permissions":{"allow":["Bash(ls:*)","Bash(cat:*)"]}}')"
out="$("${merge}" "${cur}" "${inc}")"
assert_json_eq "deduplicates overlapping allow entries" \
    '{"permissions":{"allow":["Bash(cat:*)","Bash(ls:*)"]}}' \
    "${out}"

# --- Case 3: empty current object gets incoming permissions --------------
cur="$(mkjson '{}')"
out="$("${merge}" "${cur}" "${inc}")"
assert_json_eq "empty settings receives incoming permissions" \
    '{"permissions":{"allow":["Bash(cat:*)","Bash(ls:*)"]}}' \
    "${out}"

# --- Case 4: current without a permissions key ---------------------------
cur="$(mkjson '{"model":"y"}')"
out="$("${merge}" "${cur}" "${inc}")"
assert_json_eq "adds permissions when absent, keeps existing keys" \
    '{"model":"y","permissions":{"allow":["Bash(cat:*)","Bash(ls:*)"]}}' \
    "${out}"

# --- Case 5: no empty ask/deny arrays are injected -----------------------
cur="$(mkjson '{"permissions":{"allow":["Bash(ls:*)"]}}')"
out="$("${merge}" "${cur}" "${inc}")"
has_ask="$(printf '%s' "${out}" | jq 'has("permissions") and (.permissions | has("ask") or has("deny"))')"
assert_json_eq "does not inject empty ask/deny arrays" "false" "${has_ask}"

# --- Case 6: idempotent (merging the result again is a no-op) ------------
first="$(mkjson "${out}")"
out2="$("${merge}" "${first}" "${inc}")"
assert_json_eq "merge is idempotent" "${out}" "${out2}"

# --- Case 7: wrong argument count exits 2 --------------------------------
"${merge}" "${cur}" >/dev/null 2>&1
assert_exit "errors on wrong argument count" "2" "$?"

echo "-----------------------------------------"
echo "passed: ${pass}, failed: ${fail}"
[ "${fail}" -eq 0 ]
